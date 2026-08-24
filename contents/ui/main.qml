import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: "NoBackground"

    // What shows on the Panel (Taskbar)
    compactRepresentation: PlasmaComponents.ToolButton {
        id: panelBtn
        onClicked: root.expanded = !root.expanded
        
        contentItem: Item {
            implicitWidth: Kirigami.Units.iconSizes.smallMedium
            implicitHeight: Kirigami.Units.iconSizes.smallMedium
            
            Kirigami.Icon {
                anchors.centerIn: parent
                // Force it to be smaller than the standard taskbar icons
                width: Kirigami.Units.iconSizes.small
                height: width
                source: plasmoid.configuration.panelIcon || "pan-up-symbolic"
                color: panelBtn.down || panelBtn.checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
            }
        }
    }

    // What shows in the Popup (Control Center)
    fullRepresentation: Item {
        property string pSize: plasmoid.configuration.sizePreset || "default"
        property int confWidth: pSize === "fat" ? 420 : pSize === "tall" ? 340 : pSize === "custom" ? (plasmoid.configuration.widgetWidth || 340) : 340
        
        // Auto height logic: if custom/tall and > 0, ensure it doesn't clip (Math.max)
        property int baseHeight: mainLayout.implicitHeight
        property int customH: plasmoid.configuration.widgetHeight
        property int confHeight: pSize === "tall" ? Math.max(baseHeight, 600) : (pSize === "custom" && customH > 0) ? Math.max(baseHeight, customH) : baseHeight

        width: confWidth
        implicitWidth: confWidth
        Layout.minimumWidth: confWidth
        Layout.maximumWidth: confWidth
        Layout.preferredWidth: confWidth
        
        height: confHeight
        implicitHeight: confHeight
        Layout.minimumHeight: confHeight
        Layout.maximumHeight: confHeight
        Layout.preferredHeight: confHeight

        ColumnLayout {
            id: mainLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 0 // Removed double margin so cards fit snugly against the OS frame
            spacing: Kirigami.Units.largeSpacing

                // Dynamic Modules based on config
                Repeater {
                    model: (plasmoid.configuration.moduleOrder || "media,toggles,sliders,tray").split(",")
                    
                    Loader {
                        Layout.fillWidth: true
                        visible: {
                            if (modelData === "media") return plasmoid.configuration.showMedia ?? true;
                            if (modelData === "toggles") return plasmoid.configuration.showToggles ?? true;
                            if (modelData === "sliders") return plasmoid.configuration.showSliders ?? true;
                            if (modelData === "tray") return plasmoid.configuration.showTray ?? true;
                            return false;
                        }
                        
                        sourceComponent: {
                            if (modelData === "media") return mediaComp;
                            if (modelData === "toggles") return togglesComp;
                            if (modelData === "sliders") return slidersComp;
                            if (modelData === "tray") return trayComp;
                            return null;
                        }
                    }
                }


                GlassCard {
                    Layout.fillWidth: true
                    Footer { Layout.fillWidth: true }
                }
            }
        }

    // Component Definitions
    Component {
        id: mediaComp
        GlassCard {
            MediaPlayer { Layout.fillWidth: true }
        }
    }
    
    Component {
        id: togglesComp
        GlassCard {
            QuickToggles { Layout.fillWidth: true }
        }
    }
    
    Component {
        id: slidersComp
        GlassCard {
            SystemSliders { Layout.fillWidth: true }
        }
    }
    
    Component {
        id: trayComp
        GlassCard {
            BackgroundApps { Layout.fillWidth: true }
        }
    }
}
