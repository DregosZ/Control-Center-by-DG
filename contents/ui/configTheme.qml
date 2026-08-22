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
            
            Controls.ComboBox {
                Kirigami.FormData.label: "Glass Tint Color:"
                model: [
                    { name: "None (Default)", value: "none", hex: "transparent" },
                    { name: "Blue", value: "#007AFF", hex: "#007AFF" },
                    { name: "Purple", value: "#5856D6", hex: "#5856D6" },
                    { name: "Pink", value: "#FF2D55", hex: "#FF2D55" },
                    { name: "Red", value: "#FF3B30", hex: "#FF3B30" },
                    { name: "Orange", value: "#FF9500", hex: "#FF9500" },
                    { name: "Yellow", value: "#FFCC00", hex: "#FFCC00" },
                    { name: "Green", value: "#34C759", hex: "#34C759" },
                    { name: "Teal", value: "#5AC8FA", hex: "#5AC8FA" },
                    { name: "Mint", value: "#00C7BE", hex: "#00C7BE" },
                    { name: "Indigo", value: "#3F51B5", hex: "#3F51B5" },
                    { name: "Rose", value: "#E91E63", hex: "#E91E63" },
                    { name: "Cyan", value: "#00BCD4", hex: "#00BCD4" },
                    { name: "Emerald", value: "#2ECC71", hex: "#2ECC71" },
                    { name: "Amethyst", value: "#9B59B6", hex: "#9B59B6" },
                    { name: "Slate", value: "#607D8B", hex: "#607D8B" }
                ]
                textRole: "name"
                valueRole: "value"
                
                currentIndex: {
                    for (let i = 0; i < count; i++) {
                        if (model[i].value === root.cfg_glassColor) return i;
                    }
                    return 0;
                }
                
                onActivated: {
                    root.cfg_glassColor = currentValue
                }
                
                // Keep the closed state native to prevent text overlapping with the arrow!
                // Only customize the dropdown list items.
                delegate: Controls.ItemDelegate {
                    width: parent.width
                    highlighted: parent.highlightedIndex === index
                    
                    // We must set the text to empty so the default label doesn't render!
                    text: ""
                    
                    contentItem: RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Rectangle {
                            width: Kirigami.Units.iconSizes.small
                            height: width
                            radius: width / 2
                            color: modelData.hex === "transparent" ? Kirigami.Theme.backgroundColor : modelData.hex
                            border.color: Kirigami.Theme.textColor
                            border.width: 1
                            
                            Kirigami.Icon {
                                anchors.centerIn: parent
                                source: "list-remove"
                                width: parent.width * 0.8
                                height: width
                                visible: modelData.value === "none"
                            }
                        }
                        Controls.Label {
                            text: modelData.name
                            Layout.fillWidth: true
                            color: parent.parent.highlighted ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
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
