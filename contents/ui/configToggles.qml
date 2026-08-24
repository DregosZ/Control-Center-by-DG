import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: root

    property string cfg_togglesOrder: ""
    property int cfg_togglesColumns: 5
    property bool _initialized: false

    Component.onCompleted: initModel()
    onCfg_togglesOrderChanged: initModel()

    Plasma5Support.DataSource {
        id: cmdRunner
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            let output = data["stdout"]
            if (output) {
                let lines = output.trim().split("---")
                if (lines.length >= 3) {
                    addNameField.text = lines[0].trim()
                    addIconField.text = lines[1].trim()
                    addCmdField.text = lines[2].trim()
                }
            }
            disconnectSource(sourceName)
        }
    }

    FileDialog {
        id: iconDialog
        title: "Choose Custom Icon"
        nameFilters: ["Images (*.svg *.png *.jpg *.jpeg)"]
        property int targetIndex: -1
        onAccepted: {
            if (targetIndex !== -1) {
                let urlStr = selectedFile.toString();
                if (urlStr.startsWith("file://")) urlStr = urlStr.substring(7);
                listModel.setProperty(targetIndex, "icon", urlStr);
                root.updateOrder();
            }
        }
    }

    FileDialog {
        id: desktopAppDialog
        title: "Select an Application"
        currentFolder: "file:///usr/share/applications"
        nameFilters: ["Desktop Files (*.desktop)"]
        onAccepted: {
            let path = selectedFile.toString()
            if (path.startsWith("file://")) path = path.substring(7)
            let cmd = "grep '^Name=' '" + path + "' | head -n1 | cut -d= -f2- && echo '---' && grep '^Icon=' '" + path + "' | head -n1 | cut -d= -f2- && echo '---' && grep '^Exec=' '" + path + "' | head -n1 | cut -d= -f2- | sed -E 's/ %[uUfFcC]//g'"
            cmdRunner.connectSource(cmd)
        }
    }

    function getDefaultJSON() {
        return [
            {"id":"wifi","type":"system","name":"WiFi","icon":"network-wireless-symbolic","enabled":true},
            {"id":"bluetooth","type":"system","name":"Bluetooth","icon":"preferences-system-bluetooth","enabled":true},
            {"id":"darkmode","type":"system","name":"Dark Mode","icon":"weather-clear-night","enabled":true},
            {"id":"home","type":"system","name":"266_Home","icon":"network-server-symbolic","enabled":true},
            {"id":"screenshot","type":"system","name":"Screenshot","icon":"camera-photo-symbolic","enabled":true},
            {"id":"record","type":"system","name":"Record","icon":"media-record-symbolic","enabled":true},
            {"id":"monitor","type":"system","name":"Monitor","icon":"video-display-symbolic","enabled":true},
            {"id":"archdrop","type":"system","name":"ArchDrop","icon":"document-send-symbolic","enabled":false}
        ]
    }

    function initModel() {
        if (!_initialized) {
            _initialized = true
            listModel.clear()
            
            let configArray = []
            if (cfg_togglesOrder && cfg_togglesOrder.trim().startsWith("[")) {
                try {
                    configArray = JSON.parse(cfg_togglesOrder)
                } catch(e) {
                    configArray = getDefaultJSON()
                }
            } else {
                configArray = getDefaultJSON()
            }
            
            for (let i = 0; i < configArray.length; ++i) {
                let item = configArray[i]
                listModel.append({
                    id: item.id || ("custom_" + Date.now()),
                    type: item.type || "system",
                    name: item.name || "App",
                    icon: item.icon || "application-x-executable",
                    defaultIcon: item.icon || "application-x-executable",
                    cmdToggle: item.cmdToggle || "",
                    isEnabled: item.enabled !== false
                })
            }
        }
    }

    function updateOrder() {
        if (!_initialized) return;
        let arr = []
        for (let i = 0; i < listModel.count; ++i) {
            let item = listModel.get(i)
            arr.push({
                id: item.id,
                type: item.type,
                name: item.name,
                icon: item.icon,
                cmdToggle: item.cmdToggle,
                enabled: item.isEnabled
            })
        }
        cfg_togglesOrder = JSON.stringify(arr)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing
        
        RowLayout {
            Layout.fillWidth: true
            
            Controls.Button {
                text: "Add App / Command"
                icon.name: "list-add"
                onClicked: addDialog.open()
            }
            
            Item { width: Kirigami.Units.largeSpacing }
            
            Controls.Label { text: "Columns:" }
            Controls.SpinBox {
                from: 3
                to: 8
                value: cfg_togglesColumns
                onValueChanged: cfg_togglesColumns = value
                textFromValue: function(value, locale) {
                    if (value >= 7) return value + " (Fat Size)";
                    return value;
                }
            }
            
            Item { Layout.fillWidth: true }
            
            Controls.Button {
                text: "Reset Defaults"
                icon.name: "edit-undo"
                onClicked: {
                    cfg_togglesOrder = JSON.stringify(getDefaultJSON())
                    _initialized = false
                    initModel()
                }
            }
        }
        
        Controls.Label {
            text: "Click a toggle to enable/disable. Drag to reorder. Right-click to change icon or delete."
            font.bold: true
            Layout.margins: Kirigami.Units.smallSpacing
        }

        GridView {
            id: reorderList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: Kirigami.Units.gridUnit * 15
            interactive: false
            
            cellWidth: width / cfg_togglesColumns
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
                                isMask: model.icon.endsWith("-symbolic")
                                width: Kirigami.Units.iconSizes.medium
                                height: width
                                color: (isMask && model.isEnabled) ? Kirigami.Theme.highlightedTextColor : (isMask ? Kirigami.Theme.textColor : "transparent")
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
                        PlasmaComponents.MenuItem {
                            text: "Delete Toggle"
                            icon.name: "edit-delete"
                            onClicked: {
                                listModel.remove(index)
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
                            root.updateOrder()
                        }
                    }
                }
            }
        }
    }
    
    PlasmaComponents.Dialog {
        id: addDialog
        title: "Add App or Command"
        
        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing
            
            Controls.Button {
                text: "Browse System Apps..."
                icon.name: "system-search"
                Layout.fillWidth: true
                onClicked: desktopAppDialog.open()
            }
            
            Kirigami.FormLayout {
                Controls.TextField {
                    id: addNameField
                    Kirigami.FormData.label: "Display Name:"
                    placeholderText: "e.g., Firefox"
                    Layout.fillWidth: true
                }
                Controls.TextField {
                    id: addIconField
                    Kirigami.FormData.label: "Icon Name:"
                    placeholderText: "e.g., firefox"
                    text: "application-x-executable"
                    Layout.fillWidth: true
                }
                Controls.TextField {
                    id: addCmdField
                    Kirigami.FormData.label: "Command / Exec:"
                    placeholderText: "e.g., firefox"
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Controls.Button {
                    text: "Cancel"
                    onClicked: addDialog.close()
                }
                Controls.Button {
                    text: "Add"
                    icon.name: "list-add"
                    onClicked: {
                        if (addNameField.text !== "" && addCmdField.text !== "") {
                            listModel.append({
                                id: "custom_" + Date.now(),
                                type: "command",
                                name: addNameField.text,
                                icon: addIconField.text,
                                defaultIcon: addIconField.text,
                                cmdToggle: addCmdField.text,
                                isEnabled: true
                            })
                            root.updateOrder()
                            addDialog.close()
                            
                            // Reset fields
                            addNameField.text = ""
                            addIconField.text = "application-x-executable"
                            addCmdField.text = ""
                        }
                    }
                }
            }
        }
    }
}
