import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: root

    property string cfg_togglesOrder: "wifi:1,bluetooth:1,darkmode:1,home:1,screenshot:1,record:1,monitor:1,archdrop:1"
    property bool _initialized: false

    Component.onCompleted: initModel()
    onCfg_togglesOrderChanged: initModel()

    FileDialog {
        id: iconDialog
        title: "Choose Custom Icon"
        nameFilters: ["Images (*.svg *.png *.jpg *.jpeg)"]
        property int targetIndex: -1
        onAccepted: {
            if (targetIndex !== -1) {
                // Remove file:// prefix if present to make it cleaner, though QUrl works
                let urlStr = selectedFile.toString();
                if (urlStr.startsWith("file://")) urlStr = urlStr.substring(7);
                listModel.setProperty(targetIndex, "icon", urlStr);
                root.updateOrder();
            }
        }
    }

    function initModel() {
        if (!_initialized) {
            _initialized = true
            
            let orderStr = (cfg_togglesOrder === "") ? "wifi:1,bluetooth:1,darkmode:1,home:1,screenshot:1,record:1,monitor:1,archdrop:1" : cfg_togglesOrder
            let order = orderStr.split(",")
            
            let dict = {
                "wifi": { name: "WiFi", icon: "network-wireless-symbolic" },
                "bluetooth": { name: "Bluetooth", icon: "network-bluetooth-symbolic" },
                "darkmode": { name: "Dark Mode", icon: "contrast-symbolic" },
                "home": { name: "266_Home", icon: "network-wired-symbolic" },
                "screenshot": { name: "Screenshot", icon: "camera-photo-symbolic" },
                "record": { name: "Record", icon: "media-record-symbolic" },
                "monitor": { name: "Monitor", icon: "video-display-symbolic" },
                "archdrop": { name: "ArchDrop", icon: "document-send-symbolic" }
            }
            
            let added = {}
            for (let i = 0; i < order.length; ++i) {
                let parts = order[i].split(":")
                let id = parts[0].trim()
                let isEnabled = parts.length > 1 ? (parts[1] === "1") : true
                let customIcon = parts.length > 2 ? parts[2].trim() : ""
                
                if (dict[id]) {
                    listModel.append({ 
                        id: id, 
                        name: dict[id].name, 
                        icon: customIcon !== "" ? customIcon : dict[id].icon, 
                        defaultIcon: dict[id].icon,
                        isEnabled: isEnabled 
                    })
                    added[id] = true
                }
            }
            
            for (let key in dict) {
                if (!added[key]) {
                    listModel.append({ 
                        id: key, 
                        name: dict[key].name, 
                        icon: dict[key].icon, 
                        defaultIcon: dict[key].icon,
                        isEnabled: false 
                    })
                }
            }
        }
    }

    function updateOrder() {
        if (!_initialized) return;
        let order = []
        for (let i = 0; i < listModel.count; ++i) {
            let item = listModel.get(i)
            order.push(item.id + ":" + (item.isEnabled ? "1" : "0") + ":" + item.icon)
        }
        cfg_togglesOrder = order.join(",")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing
        
        Item { height: Kirigami.Units.largeSpacing } // Top margin spacer
        
        Controls.Label {
            text: "Click a toggle to enable/disable. Drag to reorder."
            font.bold: true
            Layout.margins: Kirigami.Units.smallSpacing
        }

        GridView {
            id: reorderList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: Kirigami.Units.gridUnit * 15
            interactive: false
            
            cellWidth: width / 4
            cellHeight: Kirigami.Units.gridUnit * 5
            
            model: ListModel {
                id: listModel
            }
            
            delegate: Item {
                id: delegateRoot
                width: reorderList.cellWidth
                height: reorderList.cellHeight
                z: dragArea.drag.active ? 2 : 1

                Item {
                    id: visualItem
                    width: parent.width
                    height: parent.height
                    x: 0
                    y: 0

                    Drag.active: dragArea.drag.active
                    Drag.hotSpot.x: width / 2
                    Drag.hotSpot.y: height / 2

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing
                        spacing: Kirigami.Units.smallSpacing
                        
                        Kirigami.ShadowedRectangle {
                            id: btnRect
                            Layout.alignment: Qt.AlignHCenter
                            width: 44
                            height: width
                            radius: width / 2
                            color: model.isEnabled ? Kirigami.Theme.highlightColor : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                            
                            shadow.size: 10
                            shadow.yOffset: 2
                            shadow.color: Qt.rgba(0, 0, 0, 0.3)
                            
                            opacity: dragArea.drag.active ? 0.8 : 1.0
                            
                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: "transparent"
                                border.color: Qt.rgba(255, 255, 255, 0.15)
                                border.width: 1
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: Qt.rgba(255, 255, 255, 0.25) }
                                    GradientStop { position: 0.3; color: Qt.rgba(255, 255, 255, 0.0) }
                                    GradientStop { position: 0.7; color: Qt.rgba(0, 0, 0, 0.0) }
                                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.15) }
                                }
                            }
                            
                            Kirigami.Icon {
                                anchors.centerIn: parent
                                source: model.icon
                                isMask: true
                                width: Kirigami.Units.iconSizes.medium
                                height: width
                                color: model.isEnabled ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            }
                        }
                        
                        Controls.Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: model.name
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            color: model.isEnabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
                            elide: Text.ElideRight
                            Layout.maximumWidth: delegateRoot.width - 8
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    PlasmaComponents.Menu {
                        id: contextMenu
                        PlasmaComponents.MenuItem {
                            text: "Change Custom Icon..."
                            icon.name: "document-open"
                            onClicked: {
                                iconDialog.targetIndex = index
                                iconDialog.open()
                            }
                        }
                        PlasmaComponents.MenuItem {
                            text: "Reset to Default Icon"
                            icon.name: "edit-undo"
                            onClicked: {
                                listModel.setProperty(index, "icon", model.defaultIcon)
                                root.updateOrder()
                            }
                        }
                    }

                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        drag.target: visualItem
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton) {
                                contextMenu.popup()
                            } else {
                                listModel.setProperty(index, "isEnabled", !model.isEnabled)
                                root.updateOrder()
                            }
                        }
                        
                        onPositionChanged: (mouse) => {
                            if (drag.active) {
                                // Use the exact mouse position mapped to the GridView
                                let pointInList = mapToItem(reorderList, mouse.x, mouse.y)
                                let newIndex = reorderList.indexAt(pointInList.x, pointInList.y)
                                if (newIndex !== -1 && newIndex !== index) {
                                    listModel.move(index, newIndex, 1)
                                }
                            }
                        }
                        
                        onReleased: {
                            // Snap exactly back to origin when released
                            visualItem.x = 0
                            visualItem.y = 0
                            root.updateOrder()
                        }
                    }
                }
            }
        }
    }
}
