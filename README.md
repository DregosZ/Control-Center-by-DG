# KDE Control Center (ArchDrop)

A modern, highly customizable, and modular Control Center widget for **KDE Plasma 6**. Designed with a beautiful "Liquid Glass" aesthetic, this widget brings a unified dashboard for all your quick actions, media controls, and system sliders right to your Plasma panel.

## ✨ Features

- **Liquid Glass Aesthetic:** Sleek frosted glass UI with glossy overlays, smooth drop shadows, and responsive hover effects.
- **Modular Architecture:** Contains 4 core modules that can be reordered via drag-and-drop:
  - 🎵 **Media Player:** Control your currently playing media with cover art integration.
  - 🎛️ **Quick Toggles:** A grid of quick actions (WiFi, Bluetooth, Dark Mode, Screenshot, Screen Record, etc.).
  - 🎚️ **System Sliders:** Quick access to Volume and Brightness controls.
  - 📱 **Background Apps (System Tray):** Quick access to background applications.
- **Extreme Customizability:** 
  - Change the order of quick toggles.
  - Toggle visibility of specific modules.
  - Customize the widget's taskbar icon (supports custom `.svg` and `.png` uploads).
  - Modify the individual icons of the Quick Toggles directly from settings.
- **Deep System Integration:** Right-click toggles or click the clock to instantly open the corresponding KDE System Settings modules (KCMs).

## 📦 Requirements & Dependencies

To ensure all modules and toggles function correctly, the following packages must be installed on your system:

- **KDE Plasma 6**
- Qt 6 & Kirigami
- `kpackagetool6` (for installation)
- `playerctl` (for Media Player controls and metadata)
- `nmcli` (NetworkManager - for WiFi toggle)
- `rfkill` (for Bluetooth toggle)
- `wpctl` / `pactl` (WirePlumber/PulseAudio - for System Sliders)
- `spectacle` (for Screenshot and Screen Record toggles)

## 🚀 Installation

You can install or upgrade the widget easily using `kpackagetool6`:

### Install
```bash
kpackagetool6 -t Plasma/Applet -i .
```

### Upgrade (if already installed)
```bash
kpackagetool6 -t Plasma/Applet -u .
```

After installation, restart the Plasma shell to apply the changes:
```bash
systemctl restart --user plasma-plasmashell.service
```

## 🛠️ Configuration

Right-click the widget icon on your taskbar and select **"Configure Control Center..."** to access the settings:

- **General:** Reorder modules, toggle module visibility, and change your taskbar icon.
- **Quick Toggles:** Enable/disable toggles, change toggle icons, and drag to reorder the grid.
- **Theme:** Adjust the widget width, height, and overall glass style.

## 📜 Version History

See [CHANGELOG.md](./CHANGELOG.md) for detailed version history and updates. Currently at **v1.0.0 (Stable)**.
