import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ShadowedRectangle {
    id: root

    implicitHeight: mainLayout.implicitHeight + (Kirigami.Units.largeSpacing * 2)

    // Inner cards base frost.
    property string currentTint: plasmoid.configuration.glassColor || "none"
    property string tintStyle: plasmoid.configuration.tintStyle || "vibrant"
    
    // In light mode, textColor is black, giving a dark frost that creates contrast.
    // In dark mode, textColor is white, giving a bright frost.
    // We use a universal 2% base frost to give the card "glass material" thickness before applying color.
    property color baseInnerColor: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.02)
    
    color: {
        if (currentTint === "none") return baseInnerColor;
        
        if (tintStyle === "vibrant") {
            // Highly saturated! Mix 4% glass frost with 75% pure color.
            return Qt.tint(baseInnerColor, Qt.alpha(currentTint, 0.75));
        }
        
        if (tintStyle === "pastel") {
            // Mix 4% glass frost with 55% tint, then layer a milky background for the solid pastel look
            let tinted = Qt.tint(baseInnerColor, Qt.alpha(currentTint, 0.55));
            let milky = Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.55);
            return Qt.tint(milky, tinted);
        }
        
        // Subtle: Distinct but highly transparent. Mix 4% glass frost with 25% pure color.
        return Qt.tint(baseInnerColor, Qt.alpha(currentTint, 0.25));
    }
    
    // Smooth modern rounded corners
    radius: 16

    // Drop shadow gives the glass "thickness" and makes it float (boosted for light mode visibility)
    shadow.size: 15
    shadow.color: Qt.rgba(0, 0, 0, 0.35)
    shadow.yOffset: 3

    // Inner frosted border (Edge Lighting) - Adapts to light/dark mode for better contrast
    border.color: Qt.tint(Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15), Qt.rgba(255, 255, 255, 0.15))
    border.width: 1

    // True Glass highlight (specular reflection) - NO BLACK GRADIENTS!
    // Black gradients make it look like solid metallic car paint. Glass only reflects light (white).
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: root.radius - 1
        color: "transparent"
        visible: (plasmoid.configuration.glassStyle || "glossy") === "glossy"
        
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(255, 255, 255, 0.30) } // Top rim reflection
            GradientStop { position: 0.15; color: Qt.rgba(255, 255, 255, 0.0) } // Transparent body
            GradientStop { position: 0.85; color: Qt.rgba(255, 255, 255, 0.0) } // Transparent body
            GradientStop { position: 1.0; color: Qt.rgba(255, 255, 255, 0.08) } // Soft bottom bounce light
        }
    }

    default property alias content: mainLayout.data

    ColumnLayout {
        id: mainLayout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Kirigami.Units.largeSpacing
        }
        spacing: Kirigami.Units.smallSpacing
    }
}
