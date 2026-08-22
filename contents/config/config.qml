import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "settings-configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: "Quick Toggles"
        icon: "view-grid"
        source: "configToggles.qml"
    }
    ConfigCategory {
        name: "Theme"
        icon: "preferences-desktop-color"
        source: "configTheme.qml"
    }
}
