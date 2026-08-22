import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

Item {
    id: root

    property bool cfg_showMedia: true
    property bool cfg_showToggles: true
    property bool cfg_showSliders: true
    property bool cfg_showTray: true
    property string cfg_moduleOrder: "media,toggles,sliders,tray"
    property string cfg_panelIcon: "pan-up-symbolic"
    property bool _initialized: false

    Component.onCompleted: initModel()
    onCfg_moduleOrderChanged: initModel()

    FileDialog {
        id: iconDialog
        title: "Choose Custom Taskbar Icon"
        nameFilters: ["Images (*.svg *.png *.jpg *.jpeg)"]
        onAccepted: {
            let urlStr = selectedFile.toString();
            if (urlStr.startsWith("file://")) urlStr = urlStr.substring(7);
            root.cfg_panelIcon = urlStr;
        }
    }

    function initModel() {
        if (!_initialized) {
            _initialized = true
            let orderStr = (cfg_moduleOrder === "") ? "media,toggles,sliders,tray" : cfg_moduleOrder
            let order = orderStr.split(",")
            
            let dict = {
                "media": { name: "Media Player", icon: "media-playback-start", isEnabled: root.cfg_showMedia },
                "toggles": { name: "Quick Toggles", icon: "view-grid", isEnabled: root.cfg_showToggles },
                "sliders": { name: "System Sliders", icon: "audio-volume-high", isEnabled: root.cfg_showSliders },
                "tray": { name: "Background Apps", icon: "preferences-system-windows", isEnabled: root.cfg_showTray }
            }
            
            let added = {}
            for (let i = 0; i < order.length; ++i) {
                let id = order[i].trim()
                if (dict[id]) {
                    listModel.append({ id: id, name: dict[id].name, icon: dict[id].icon, isEnabled: dict[id].isEnabled })
                    added[id] = true
                }
            }
            
            for (let key in dict) {
                if (!added[key]) {
                    listModel.append({ id: key, name: dict[key].name, icon: dict[key].icon, isEnabled: false })
                }
            }
        }
    }

    function updateOrder() {
        if (!_initialized) return;
        let order = []
        for (let i = 0; i < listModel.count; ++i) {
            let item = listModel.get(i)
            order.push(item.id)
            
            if (item.id === "media") cfg_showMedia = item.isEnabled
            if (item.id === "toggles") cfg_showToggles = item.isEnabled
            if (item.id === "sliders") cfg_showSliders = item.isEnabled
            if (item.id === "tray") cfg_showTray = item.isEnabled
        }
        cfg_moduleOrder = order.join(",")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Controls.Label {
                text: "Taskbar Icon:"
                font.bold: true
            }
            
            Kirigami.Icon {
                source: root.cfg_panelIcon
                width: Kirigami.Units.iconSizes.medium
                height: width
            }

            Controls.Button {
                text: "Browse..."
                icon.name: "document-open"
                onClicked: iconDialog.open()
            }
            
            Controls.Button {
                text: "Reset"
                icon.name: "edit-undo"
                onClicked: root.cfg_panelIcon = "pan-up-symbolic"
            }
            
            Item { Layout.fillWidth: true }
        }
        
        Kirigami.Separator { Layout.fillWidth: true }
        
        Controls.Label {
            text: "Click a module to enable/disable. Drag to reorder."
            font.bold: true
        }

        ListView {
            id: reorderList
            Layout.fillWidth: true
            Layout.fillHeight: true
            interactive: false
            
            model: ListModel {
                id: listModel
            }
            
            delegate: Item {
                id: delegateRoot
                width: reorderList.width
                height: Kirigami.Units.gridUnit * 3
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

                    Kirigami.ShadowedRectangle {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing / 2
                        radius: Kirigami.Units.smallSpacing
                        
                        color: model.isEnabled ? Kirigami.Theme.highlightColor : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                        
                        shadow.size: dragArea.drag.active ? 15 : 5
                        shadow.yOffset: dragArea.drag.active ? 4 : 2
                        shadow.color: Qt.rgba(0, 0, 0, dragArea.drag.active ? 0.4 : 0.2)
                        
                        opacity: dragArea.drag.active ? 0.9 : 1.0
                        scale: dragArea.drag.active ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        
                        // Liquid Glass Overlay
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
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
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Kirigami.Units.largeSpacing
                            
                            Kirigami.Icon {
                                source: "handle-sort-symbolic" // Proper drag handle
                                width: Kirigami.Units.iconSizes.small
                                height: width
                                color: model.isEnabled ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                                opacity: 0.6
                            }
                            Kirigami.Icon {
                                source: model.icon
                                width: Kirigami.Units.iconSizes.medium
                                height: width
                                color: model.isEnabled ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            }
                            Controls.Label {
                                text: model.name
                                Layout.fillWidth: true
                                color: model.isEnabled ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                                font.bold: true
                                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                            }
                        }
                    }
                    
                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        drag.target: visualItem
                        drag.axis: Drag.YAxis
                        
                        onClicked: {
                            listModel.setProperty(index, "isEnabled", !model.isEnabled)
                            root.updateOrder()
                        }
                        
                        onPositionChanged: {
                            if (drag.active) {
                                let pointInList = mapToItem(reorderList, mouse.x, mouse.y)
                                let newIndex = reorderList.indexAt(pointInList.x, pointInList.y)
                                if (newIndex !== -1 && newIndex !== index) {
                                    listModel.move(index, newIndex, 1)
                                }
                            }
                        }
                        
                        onReleased: {
                            visualItem.x = 0
                            visualItem.y = 0
                            root.updateOrder() // save order when dropped
                        }
                    }
                }
            }
        }
    }
}
