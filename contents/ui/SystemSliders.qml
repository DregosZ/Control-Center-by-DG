import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

ColumnLayout {
    id: sliders
    spacing: Kirigami.Units.largeSpacing

    Plasma5Support.DataSource {
        id: cmdRunner
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)
        function runCmd(cmd) { if (cmd) connectSource(cmd) }
    }

    // Volume Poller
    Plasma5Support.DataSource {
        id: volumeSource
        engine: "executable"
        connectedSources: ["wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -oP '(?<=Volume: )[0-9.]+' | awk '{print $1 * 100}'"]
        interval: 1500
        onNewData: (sourceName, data) => {
            if (!volumeSlider.pressed) {
                let val = parseInt(data.stdout.trim());
                if (!isNaN(val)) volumeSlider.value = val;
            }
        }
    }

    // Volume
    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            source: "audio-volume-medium"
            width: Kirigami.Units.iconSizes.smallMedium
            height: width
        }

        PlasmaComponents.Slider {
            id: volumeSlider
            Layout.fillWidth: true
            from: 0
            to: 100
            stepSize: 1
            onMoved: {
                cmdRunner.runCmd("sh -c 'wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (value / 100).toFixed(2) + " || pactl set-sink-volume @DEFAULT_SINK@ " + Math.round(value) + "%'")
            }
        }

        PlasmaComponents.ToolButton {
            id: volumeMenuBtn
            icon.name: "go-next"
            opacity: 0.5
            
            ListModel {
                id: sinkListModel
            }

            Controls.Menu {
                id: sinkMenu
                y: volumeMenuBtn.height
                
                Repeater {
                    model: sinkListModel
                    Controls.MenuItem {
                        text: model.description
                        onTriggered: {
                            cmdRunner.runCmd("pactl set-default-sink " + model.name)
                        }
                    }
                }
            }

            Plasma5Support.DataSource {
                id: sinkFetcher
                engine: "executable"
                connectedSources: []
                onNewData: (sourceName, data) => {
                    try {
                        let sinks = JSON.parse(data.stdout);
                        sinkListModel.clear();
                        for (let i = 0; i < sinks.length; i++) {
                            sinkListModel.append({
                                "name": sinks[i].name,
                                "description": sinks[i].description
                            });
                        }
                        sinkMenu.open();
                    } catch (e) {
                        console.log("Failed to parse sinks: " + e);
                    }
                    disconnectSource(sourceName);
                }
            }

            onClicked: {
                sinkFetcher.connectSource("pactl -f json list sinks")
            }
        }
    }
}
