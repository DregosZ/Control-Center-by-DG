import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.iconthemes as KIconThemes

Item {
    id: root

    property string cfg_glassStyle: "glossy"
    property string cfg_glassColor: "none"
    property string cfg_tintStyle: "vibrant"
    property string cfg_panelIcon: "view-media-equalizer"
    property int cfg_widgetWidth: 340
    property int cfg_widgetHeight: 0
    property string cfg_sizePreset: "default"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing
        
        Item { height: Kirigami.Units.largeSpacing } // Top margin spacer
        
        Kirigami.FormLayout {
            Layout.fillWidth: true
            
            Controls.ComboBox {
                Kirigami.FormData.label: "Design Style:"
                model: [
                    { text: "Glossy Glass (Reflective/Metallic)", value: "glossy" },
                    { text: "Matte Glass (Flat)", value: "matte" }
                ]
                textRole: "text"
                valueRole: "value"
                currentIndex: root.cfg_glassStyle === "matte" ? 1 : 0
                onActivated: {
                    root.cfg_glassStyle = currentValue
                }
            }
            
            RowLayout {
                Kirigami.FormData.label: "Taskbar Icon:"
                spacing: Kirigami.Units.smallSpacing
                
                Controls.Button {
                    icon.name: root.cfg_panelIcon || "view-media-equalizer"
                    text: "Browse Icon..."
                    onClicked: iconDialog.open()
                }
                
                KIconThemes.IconDialog {
                    id: iconDialog
                    title: "Select Taskbar Icon"
                    onIconNameChanged: {
                        if (iconName !== "") {
                            root.cfg_panelIcon = iconName
                        }
                    }
                }
            }
            
            Controls.ComboBox {
                Kirigami.FormData.label: "Widget Size:"
                model: [
                    { text: "Default (Auto height - 340px)", value: "default" },
                    { text: "Fat (Wider - 420px)", value: "fat" },
                    { text: "Tall (Taller - 600px)", value: "tall" },
                    { text: "Custom (Manual dimensions)", value: "custom" }
                ]
                textRole: "text"
                valueRole: "value"
                currentIndex: {
                    for (let i = 0; i < count; i++) {
                        if (model[i].value === root.cfg_sizePreset) return i;
                    }
                    return 0;
                }
                onActivated: {
                    // Sync values to custom sliders so they can continue adjusting smoothly
                    if (currentValue === "default") {
                        root.cfg_widgetWidth = 340;
                        root.cfg_widgetHeight = 0;
                    } else if (currentValue === "fat") {
                        root.cfg_widgetWidth = 420;
                        root.cfg_widgetHeight = 0;
                    } else if (currentValue === "tall") {
                        root.cfg_widgetWidth = 340;
                        root.cfg_widgetHeight = 600;
                    }
                    root.cfg_sizePreset = currentValue
                }
            }
            
            RowLayout {
                Kirigami.FormData.label: "Custom Width:"
                spacing: Kirigami.Units.smallSpacing
                visible: root.cfg_sizePreset === "custom"
                
                Controls.Slider {
                    id: widthSlider
                    Layout.fillWidth: true
                    from: 250
                    to: 800
                    stepSize: 10
                    value: root.cfg_widgetWidth
                    onValueChanged: {
                        if (root.cfg_widgetWidth !== value) {
                            root.cfg_widgetWidth = value;
                        }
                    }
                }
                
                Controls.SpinBox {
                    id: widthSpinBox
                    from: 250
                    to: 800
                    stepSize: 10
                    value: root.cfg_widgetWidth
                    onValueChanged: {
                        if (root.cfg_widgetWidth !== value) {
                            root.cfg_widgetWidth = value;
                        }
                    }
                }
                
                Controls.Label {
                    text: "px"
                }
            }
            
            RowLayout {
                Kirigami.FormData.label: "Custom Height:"
                spacing: Kirigami.Units.smallSpacing
                visible: root.cfg_sizePreset === "custom"
                
                Controls.Slider {
                    id: heightSlider
                    Layout.fillWidth: true
                    from: 0 // 0 = Auto
                    to: 1000
                    stepSize: 10
                    value: root.cfg_widgetHeight
                    onValueChanged: {
                        if (root.cfg_widgetHeight !== value) {
                            root.cfg_widgetHeight = value;
                        }
                    }
                }
                
                Controls.SpinBox {
                    id: heightSpinBox
                    from: 0
                    to: 1000
                    stepSize: 10
                    value: root.cfg_widgetHeight
                    onValueChanged: {
                        if (root.cfg_widgetHeight !== value) {
                            root.cfg_widgetHeight = value;
                        }
                    }
                }
                
                Controls.Label {
                    text: root.cfg_widgetHeight === 0 ? "px (Auto Fit)" : "px"
                }
            }
            
            Flow {
                Kirigami.FormData.label: "Glass Tint Color:"
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                
                Repeater {
                    model: [
                        { name: "None", value: "none" },
                        { name: "Crimson", value: "#DC143C" },
                        { name: "Red", value: "#FF3B30" },
                        { name: "Rose", value: "#E91E63" },
                        { name: "Pink", value: "#FF2D55" },
                        { name: "Coral", value: "#FF7F50" },
                        { name: "Orange", value: "#FF9500" },
                        { name: "Amber", value: "#FFBF00" },
                        { name: "Yellow", value: "#FFCC00" },
                        { name: "Lemon", value: "#FFF44F" },
                        { name: "Lime", value: "#32CD32" },
                        { name: "Green", value: "#34C759" },
                        { name: "Emerald", value: "#2ECC71" },
                        { name: "Mint", value: "#00C7BE" },
                        { name: "Teal", value: "#5AC8FA" },
                        { name: "Cyan", value: "#00BCD4" },
                        { name: "Sky", value: "#87CEEB" },
                        { name: "Blue", value: "#007AFF" },
                        { name: "Azure", value: "#007FFF" },
                        { name: "Indigo", value: "#3F51B5" },
                        { name: "Navy", value: "#000080" },
                        { name: "Purple", value: "#5856D6" },
                        { name: "Amethyst", value: "#9B59B6" },
                        { name: "Violet", value: "#EE82EE" },
                        { name: "Magenta", value: "#FF00FF" },
                        { name: "Slate", value: "#607D8B" },
                        { name: "Charcoal", value: "#36454F" }
                    ]
                    
                    delegate: Rectangle {
                        width: Kirigami.Units.gridUnit * 1.5
                        height: width
                        radius: width / 2
                        color: modelData.value === "none" ? "transparent" : modelData.value
                        border.color: root.cfg_glassColor === modelData.value ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                        border.width: root.cfg_glassColor === modelData.value ? 2 : 1
                        
                        Kirigami.Icon {
                            anchors.centerIn: parent
                            source: modelData.value === "none" ? "list-remove" : "dialog-ok"
                            width: parent.width * 0.7
                            height: width
                            visible: modelData.value === "none" || root.cfg_glassColor === modelData.value
                            color: modelData.value === "none" ? Kirigami.Theme.textColor : "#FFFFFF"
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.cfg_glassColor = modelData.value
                            
                            Controls.ToolTip.visible: containsMouse
                            Controls.ToolTip.text: modelData.name
                        }
                        
                        // Add a subtle scale animation on hover/selection
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        scale: (root.cfg_glassColor === modelData.value || hoverArea.containsMouse) ? 1.1 : 1.0
                        
                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                        }
                    }
                }
            }
            
            Controls.ComboBox {
                Kirigami.FormData.label: "Tint Style:"
                model: [
                    { text: "Vibrant (Clear & Saturated)", value: "vibrant" },
                    { text: "Pastel (Soft & Milky Mixed)", value: "pastel" },
                    { text: "Subtle (Highly Transparent)", value: "subtle" }
                ]
                textRole: "text"
                valueRole: "value"
                visible: root.cfg_glassColor !== "none"
                currentIndex: {
                    for (let i = 0; i < count; i++) {
                        if (model[i].value === root.cfg_tintStyle) return i;
                    }
                    return 0; // Default to vibrant
                }
                onActivated: {
                    root.cfg_tintStyle = currentValue
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
