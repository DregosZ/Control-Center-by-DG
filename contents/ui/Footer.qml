import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Effects
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

RowLayout {
    id: footer
    
    property string userName: "User"
    property string displayName: "User"

    // Command runner for Power Menu
    Plasma5Support.DataSource {
        id: powerCmd
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
        function runCmd(cmd) { if (cmd) connectSource(cmd) }
    }

    // Poller to get current username and display name dynamically
    Plasma5Support.DataSource {
        id: userPoller
        engine: "executable"
        connectedSources: ["sh -c 'echo \"$USER\"; getent passwd \"$USER\" | cut -d: -f5 | cut -d, -f1'"]
        onNewData: (sourceName, data) => {
            let lines = data.stdout.trim().split("\n");
            let u = lines[0] ? lines[0].trim() : "";
            let d = lines[1] ? lines[1].trim() : "";
            
            if (u) footer.userName = u;
            footer.displayName = (d !== "") ? d : footer.userName;
            
            disconnectSource(sourceName);
        }
    }

    // User Profile with Hidden Power Menu
    RowLayout {
        spacing: Kirigami.Units.smallSpacing
        
        Kirigami.ShadowedImage {
            id: userAvatar
            width: Kirigami.Units.iconSizes.large
            height: width
            radius: width / 2
            source: footer.userName !== "User" ? "file:///var/lib/AccountsService/icons/" + footer.userName : ""
            fillMode: Image.PreserveAspectCrop
            
            // Fallback for when there is no system avatar image
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Kirigami.Theme.highlightColor
                visible: userAvatar.status !== Image.Ready
                
                Kirigami.Icon {
                    anchors.centerIn: parent
                    source: "user-identity"
                    width: Kirigami.Units.iconSizes.medium
                    height: width
                    color: Kirigami.Theme.highlightedTextColor
                }
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: powerMenu.popup()
            }
            
            Controls.Menu {
                id: powerMenu
                
                Controls.MenuItem {
                    text: "Sleep"
                    icon.name: "system-suspend"
                    onTriggered: powerCmd.runCmd("systemctl suspend")
                }
                Controls.MenuItem {
                    text: "Log Out"
                    icon.name: "system-log-out"
                    onTriggered: powerCmd.runCmd("qdbus6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logout")
                }
                Controls.MenuItem {
                    text: "Restart"
                    icon.name: "system-reboot"
                    onTriggered: powerCmd.runCmd("qdbus6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logoutAndReboot")
                }
                Controls.MenuItem {
                    text: "Shut Down"
                    icon.name: "system-shutdown"
                    onTriggered: powerCmd.runCmd("qdbus6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logoutAndShutdown")
                }
            }
        }
        
        PlasmaComponents.Label {
            text: footer.displayName
            font.bold: true
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: powerMenu.popup()
            }
        }
    }

    Item { Layout.fillWidth: true } // Spacer

    // Creative Clock
    Item {
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: clockLayout.implicitWidth
        implicitHeight: clockLayout.implicitHeight

        ColumnLayout {
            id: clockLayout
            anchors.fill: parent
            spacing: -4 // Negative spacing to tighten the gap between time and date

            PlasmaComponents.Label {
                id: timeLabel
                Layout.alignment: Qt.AlignHCenter
                
                // Try to use a rounded, modern font. 
                // Fallback relies on system default if these aren't installed.
                font.family: "Quicksand"
                font.pixelSize: 26
                font.weight: Font.Black
                color: Kirigami.Theme.textColor
                
                function updateTime() {
                    text = Qt.formatDateTime(new Date(), "HH:mm")
                }
                Component.onCompleted: updateTime()
            }

            PlasmaComponents.Label {
                id: dateLabel
                Layout.alignment: Qt.AlignHCenter
                
                font.family: "Quicksand"
                font.pixelSize: 10
                font.weight: Font.Bold
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 1
                opacity: 0.6
                color: Kirigami.Theme.textColor
                
                function updateDate() {
                    text = Qt.formatDateTime(new Date(), "ddd, d MMM")
                }
                Component.onCompleted: updateDate()
            }
            
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    timeLabel.updateTime()
                    dateLabel.updateDate()
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            
            // Liquid Glass Hover Effect
            Rectangle {
                anchors.fill: parent
                anchors.margins: -Kirigami.Units.smallSpacing * 1.5
                radius: 12
                
                // Very subtle frost base instead of solid blue
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04)
                
                // Fine glassy edge
                border.color: Qt.rgba(255, 255, 255, 0.12)
                border.width: 1
                
                opacity: parent.containsMouse ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                
                // Glossy dome overlay
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    radius: parent.radius - 1
                    color: "transparent"
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(255, 255, 255, 0.15) } // Top shine
                        GradientStop { position: 0.3; color: Qt.rgba(255, 255, 255, 0.0) }
                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.1) } // Bottom shade
                    }
                }
            }

            onClicked: powerCmd.runCmd("kcmshell6 kcm_clock")
        }
    }

    Item { Layout.fillWidth: true } // Spacer

    // Settings Button
    PlasmaComponents.ToolButton {
        icon.name: "settings-configure"
        icon.width: Kirigami.Units.iconSizes.medium
        icon.height: Kirigami.Units.iconSizes.medium
        onClicked: plasmoid.internalAction("configure").trigger()
    }
}
