import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

GridLayout {
    id: quickToggles
    Layout.fillWidth: true
    columns: 5
    rowSpacing: Kirigami.Units.largeSpacing * 1.5
    columnSpacing: Kirigami.Units.smallSpacing // Will be distributed evenly by fillWidth

    // Command runner using Plasma5Support backward compatibility
    Plasma5Support.DataSource {
        id: cmdRunner
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
        }
        function runCmd(cmd) {
            if (cmd && cmd !== "") {
                connectSource(cmd)
            }
        }
    }

    Repeater {
        model: ListModel {
            id: toggleModel
            ListElement { name: "Loading..."; icon: ""; cmdToggle: ""; cmdSettings: ""; cmdCheck: "" }
        }

        Component.onCompleted: populateModel()

        property string togglesOrderTrigger: plasmoid.configuration.togglesOrder || ""
        onTogglesOrderTriggerChanged: populateModel()

        function populateModel() {
            toggleModel.clear()
            let orderStr = plasmoid.configuration.togglesOrder || "wifi:1,bluetooth:1,darkmode:1,home:1,screenshot:1,record:1,monitor:1,archdrop:1"
            let order = orderStr.split(",")
            
            let dict = {
                "wifi": { name: "WiFi", icon: "network-wireless-symbolic", cmdToggle: "sh -c 'nmcli radio wifi | grep -q enabled && nmcli radio wifi off || nmcli radio wifi on'", cmdSettings: "kcmshell6 kcm_networkmanagement", cmdCheck: "sh -c 'nmcli radio wifi | grep -q enabled && echo 1 || echo 0'" },
                "bluetooth": { name: "Bluetooth", icon: "network-bluetooth-symbolic", cmdToggle: "sh -c 'rfkill list bluetooth | grep -q \"Soft blocked: yes\" && rfkill unblock bluetooth || rfkill block bluetooth'", cmdSettings: "kcmshell6 kcm_bluetooth", cmdCheck: "sh -c 'rfkill list bluetooth | grep -q \"Soft blocked: yes\" && echo 0 || echo 1'" },
                "darkmode": { name: "Dark Mode", icon: "contrast-symbolic", cmdToggle: "sh -c 'kreadconfig6 --group General --key ColorScheme | grep -q Dark && plasma-apply-lookandfeel -a org.kde.breeze.desktop || plasma-apply-lookandfeel -a org.kde.breezedark.desktop'", cmdSettings: "kcmshell6 kcm_colors", cmdCheck: "sh -c 'kreadconfig6 --group General --key ColorScheme | grep -q Dark && echo 1 || echo 0'" },
                "home": { name: "266_Home", icon: "network-wired-symbolic", cmdToggle: "sh -c 'nmcli connection show --active | grep -q 266_Home && nmcli connection down 266_Home || nmcli connection up 266_Home'", cmdSettings: "kcmshell6 kcm_networkmanagement", cmdCheck: "sh -c 'nmcli connection show --active | grep -q 266_Home && echo 1 || echo 0'" },
                "screenshot": { name: "Screenshot", icon: "camera-photo-symbolic", cmdToggle: "spectacle", cmdSettings: "", cmdCheck: "echo 0" },
                "record": { name: "Record", icon: "media-record-symbolic", cmdToggle: "spectacle -R r", cmdSettings: "", cmdCheck: "sh -c 'pgrep -x spectacle > /dev/null && echo 1 || echo 0'" },
                "monitor": { name: "Monitor", icon: "video-display-symbolic", cmdToggle: "qdbus6 org.kde.kglobalaccel /component/org_kde_kscreen_desktop invokeShortcut 'ShowOSD'", cmdSettings: "kcmshell6 kcm_kscreen", cmdCheck: "echo 0" },
                "archdrop": { name: "ArchDrop", icon: "document-send-symbolic", cmdToggle: "archdrop", cmdSettings: "", cmdCheck: "sh -c 'pgrep -x archdrop > /dev/null && echo 1 || echo 0'" }
            }
            
            for (let i = 0; i < order.length; ++i) {
                let parts = order[i].split(":")
                let id = parts[0].trim()
                let isEnabled = parts.length > 1 ? (parts[1] === "1") : true
                let customIcon = parts.length > 2 ? parts[2].trim() : ""
                
                if (dict[id] && isEnabled) {
                    let itemData = dict[id]
                    if (customIcon !== "") itemData.icon = customIcon
                    toggleModel.append(itemData)
                }
            }
        }
        

        Item {
            Layout.fillWidth: true
            Layout.minimumWidth: 1
            implicitHeight: colLayout.implicitHeight

            property bool isActive: false

            // Poll the status every 2 seconds
            Plasma5Support.DataSource {
                engine: "executable"
                connectedSources: [model.cmdCheck]
                interval: 2000
                onNewData: (sourceName, data) => {
                    isActive = (data.stdout.trim() === "1")
                }
            }
            
            ColumnLayout {
                id: colLayout
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Kirigami.Units.smallSpacing

                Kirigami.ShadowedRectangle {
                    id: btnRect
                    Layout.alignment: Qt.AlignHCenter
                    width: 44
                    height: width
                    radius: width / 2
                    
                    // Smooth transition for background color and scale
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
                    
                    // Modern translucent background for inactive state
                    color: mouseArea.pressed ? Kirigami.Theme.highlightColor : 
                           isActive ? Kirigami.Theme.highlightColor :
                           (mouseArea.containsMouse ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15) : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08))
                    
                    // Drop shadow creates physical separation from the background card!
                    shadow.size: 10
                    shadow.yOffset: 2
                    shadow.color: Qt.rgba(0, 0, 0, 0.3)
                    
                    scale: mouseArea.pressed ? 0.9 : 1.0
                    
                    // Glossy Dome Overlay (creates the shiny 3D material look)
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
                        width: Kirigami.Units.iconSizes.medium
                        height: width
                        source: model.icon
                        isMask: true // Forces the icon to be completely flat/monochrome
                        color: (isActive || mouseArea.pressed) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) {
                                // Optimistically toggle state immediately for fast feedback
                                if (model.cmdCheck !== "echo 0") isActive = !isActive;
                                cmdRunner.runCmd(model.cmdToggle)
                            } else if (mouse.button === Qt.RightButton) {
                                cmdRunner.runCmd(model.cmdSettings)
                            }
                        }
                    }
                }
                
                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: model.name
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    elide: Text.ElideRight
                    Layout.maximumWidth: Kirigami.Units.iconSizes.huge * 1.5
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
