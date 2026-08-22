import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: root
    implicitHeight: layout.implicitHeight
    
    // Ensure height collapses when no items
    visible: listModel.count > 0

    ListModel {
        id: listModel
    }

    Plasma5Support.DataSource {
        id: sniPoller
        engine: "executable"
        connectedSources: []
        
        onNewData: (sourceName, data) => {
            if (sourceName === "python3 " + scriptPath + " list") {
                try {
                    let items = JSON.parse(data.stdout);
                    // Update model cleanly to prevent UI jumping
                    // For simplicity in this implementation, we just rebuild if counts differ or ids mismatch.
                    let needsRebuild = false;
                    if (items.length !== listModel.count) {
                        needsRebuild = true;
                    } else {
                        for (let i = 0; i < items.length; i++) {
                            if (listModel.get(i).path !== items[i].path) {
                                needsRebuild = true;
                                break;
                            }
                        }
                    }
                    
                    if (needsRebuild) {
                        listModel.clear();
                        for (let i = 0; i < items.length; i++) {
                            listModel.append(items[i]);
                        }
                    }
                } catch (e) {
                    console.log("Error parsing SNI data:", e)
                }
            }
            disconnectSource(sourceName);
        }
    }

    property string scriptPath: "~/.local/share/plasma/plasmoids/com.dregosz.controlcenter/contents/scripts/sni_backend.py"

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            sniPoller.connectSource("python3 " + scriptPath + " list")
        }
    }
    
    Plasma5Support.DataSource {
        id: cmdRunner
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
    }

    RowLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Kirigami.Units.smallSpacing

        Repeater {
            model: listModel
            
            delegate: Rectangle {
                width: Kirigami.Units.iconSizes.medium + Kirigami.Units.largeSpacing
                height: width
                color: appMouseArea.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                radius: width / 2
                border.width: 1
                border.color: Kirigami.Theme.disabledTextColor
                
                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.smallMedium
                    height: width
                    source: model.icon
                }
                
                MouseArea {
                    id: appMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    
                    onClicked: (mouse) => {
                        let script = "python3 " + scriptPath
                        if (mouse.button === Qt.LeftButton) {
                            cmdRunner.connectSource(script + " show " + model.service + " " + model.path)
                        } else if (mouse.button === Qt.RightButton) {
                            appContextMenu.popup()
                        }
                    }
                    
                    Controls.Menu {
                        id: appContextMenu
                        Controls.MenuItem {
                            text: "Open / Restore"
                            icon.name: "window-restore"
                            onTriggered: {
                                let script = "python3 " + scriptPath
                                cmdRunner.connectSource(script + " show " + model.service + " " + model.path)
                            }
                        }
                        Controls.MenuItem {
                            text: "Quit / Kill"
                            icon.name: "application-exit"
                            onTriggered: {
                                let script = "python3 " + scriptPath
                                cmdRunner.connectSource(script + " quit " + model.service + " " + model.path)
                            }
                        }
                    }
                }
                
                Controls.ToolTip {
                    text: model.title
                    visible: appMouseArea.containsMouse
                }
            }
        }
        
        Item {
            Layout.fillWidth: true
        }
    }
}
