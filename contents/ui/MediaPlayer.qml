import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: root
    implicitHeight: mainLayout.implicitHeight
    
    property string mStatus: "Stopped"
    property string mTitle: "No Media Playing"
    property string mArtist: "..."
    property string mArtUrl: ""
    property real mVolume: 0.0
    property bool ignoreStatusUpdate: false
    
    // Timer to prevent flickering after optimistic UI update
    Timer {
        id: statusMaskTimer
        interval: 1200
        repeat: false
        onTriggered: root.ignoreStatusUpdate = false
    }

    property string scriptPathGet: "~/.local/share/plasma/plasmoids/com.dregosz.controlcenter/contents/scripts/get_media_metadata.py"
    property string scriptPathSet: "~/.local/share/plasma/plasmoids/com.dregosz.controlcenter/contents/scripts/set_media_volume.py"

    // Helper to prioritize Spotify, fallback to active player
    function getPlayerCmd(action) {
        return "sh -c 'if playerctl -p spotify status >/dev/null 2>&1; then playerctl -p spotify " + action + "; else playerctl " + action + "; fi'";
    }

    Plasma5Support.DataSource {
        id: cmdRunner
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
        function runCmd(cmd) { if (cmd) connectSource(cmd) }
    }

    // MPRIS Poller using python script
    Plasma5Support.DataSource {
        id: mprisPoller
        engine: "executable"
        connectedSources: ["python3 " + scriptPathGet]
        interval: 500 // Reduced from 1000ms for faster UI updates
        onNewData: (sourceName, data) => {
            let out = data.stdout.trim();
            if (out === "" || out === "Stopped" || out === "No players found") {
                if (!root.ignoreStatusUpdate) mStatus = "Stopped";
                mTitle = "No Media Playing";
                mArtist = "";
                mArtUrl = "";
                return;
            }
            
            let parts = out.split("%|%");
            if (parts.length >= 4) {
                if (!root.ignoreStatusUpdate) {
                    mStatus = parts[0];
                }
                mTitle = parts[1] || "Unknown Title";
                mArtist = parts[2] || "Unknown Artist";
                
                // Keep image cache from refreshing unnecessarily
                let rawUrl = parts[3];
                if (rawUrl !== mArtUrl) mArtUrl = rawUrl;
                
                // Volume parsing
                if (parts.length >= 5 && !appVolumeSlider.pressed) {
                    let vol = parseFloat(parts[4]);
                    if (!isNaN(vol)) mVolume = vol;
                }
            }
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            // Album Art
            Rectangle {
                width: Kirigami.Units.iconSizes.huge
                height: width
                radius: Kirigami.Units.smallSpacing
                color: Kirigami.Theme.alternateBackgroundColor
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.mArtUrl
                    fillMode: Image.PreserveAspectCrop
                    visible: root.mArtUrl !== ""
                }
                
                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.medium
                    height: width
                    source: "multimedia-audio-player"
                    visible: root.mArtUrl === ""
                    opacity: 0.5
                }
            }

            // Track Info
            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0 // Prevent text from forcing parent width
                spacing: 0

                // Scrolling Title
                Item {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    height: titleLabel.implicitHeight
                    clip: true

                    PlasmaComponents.Label {
                        id: titleLabel
                        text: root.mTitle
                        font.weight: Font.Bold
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                        x: 0
                        
                        // Fallback elide if animation doesn't run
                        width: isLong ? implicitWidth : parent.width
                        elide: isLong ? Text.ElideNone : Text.ElideRight
                        
                        property bool isLong: implicitWidth > parent.width && parent.width > 0

                        SequentialAnimation on x {
                            loops: Animation.Infinite
                            running: titleLabel.isLong
                            
                            // Reset to start
                            PropertyAction { value: 0 }
                            PauseAnimation { duration: 2000 }
                            NumberAnimation {
                                from: 0
                                to: -(titleLabel.implicitWidth - titleLabel.parent.width)
                                duration: (titleLabel.implicitWidth - titleLabel.parent.width) * 20
                            }
                            PauseAnimation { duration: 2000 }
                            // Snap back to start instead of scrolling backwards
                            PropertyAction { value: 0 }
                        }
                    }
                }

                // Scrolling Artist
                Item {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    height: artistLabel.implicitHeight
                    clip: true

                    PlasmaComponents.Label {
                        id: artistLabel
                        text: root.mArtist
                        opacity: 0.7
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        x: 0
                        
                        width: isLong ? implicitWidth : parent.width
                        elide: isLong ? Text.ElideNone : Text.ElideRight
                        
                        property bool isLong: implicitWidth > parent.width && parent.width > 0

                        SequentialAnimation on x {
                            loops: Animation.Infinite
                            running: artistLabel.isLong
                            
                            PropertyAction { value: 0 }
                            PauseAnimation { duration: 2000 }
                            NumberAnimation {
                                from: 0
                                to: -(artistLabel.implicitWidth - artistLabel.parent.width)
                                duration: (artistLabel.implicitWidth - artistLabel.parent.width) * 20
                            }
                            PauseAnimation { duration: 2000 }
                            PropertyAction { value: 0 }
                        }
                    }
                }
            }

            // Playback Controls
            RowLayout {
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.ToolButton {
                    icon.name: "media-skip-backward"
                    onClicked: cmdRunner.runCmd(getPlayerCmd("previous"))
                }

                PlasmaComponents.ToolButton {
                    icon.name: root.mStatus === "Playing" ? "media-playback-pause" : "media-playback-start"
                    onClicked: {
                        // Optimistic UI update: instantly flip the icon before the background script confirms it
                        root.ignoreStatusUpdate = true;
                        statusMaskTimer.restart();
                        root.mStatus = (root.mStatus === "Playing") ? "Paused" : "Playing";
                        cmdRunner.runCmd(getPlayerCmd("play-pause"));
                    }
                }

                PlasmaComponents.ToolButton {
                    icon.name: "media-skip-forward"
                    onClicked: cmdRunner.runCmd(getPlayerCmd("next"))
                }
            }
        }

        // App-specific Volume Slider
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            visible: root.mStatus !== "Stopped" // Hide slider if nothing is playing

            Kirigami.Icon {
                source: "audio-volume-low"
                width: Kirigami.Units.iconSizes.small
                height: width
                opacity: 0.7
            }

            PlasmaComponents.Slider {
                id: appVolumeSlider
                Layout.fillWidth: true
                from: 0
                to: 100
                stepSize: 1
                value: root.mVolume * 100
                onMoved: {
                    cmdRunner.runCmd("python3 " + scriptPathSet + " " + (value / 100).toFixed(2))
                }
            }
            
            Kirigami.Icon {
                source: "audio-volume-high"
                width: Kirigami.Units.iconSizes.small
                height: width
                opacity: 0.7
            }
        }
    }
}
