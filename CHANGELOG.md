# Changelog

## [v1.0.0] - Stable Release (Liquid Glass UI)

# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] - 2026-08-21

### Added
- **Quick Toggles Configuration (`configToggles.qml`)**: 
  - Added a dedicated settings tab inside the Plasma Configuration window.
  - Implemented a GridView matching the front-end layout perfectly.
  - Users can enable/disable toggles with a single click (turns blue/gray).
  - Users can Drag & Drop to reorder toggles smoothly.
- **Smart Footer**: 
  - Dynamic profile picture fetching (`/var/lib/AccountsService/icons/$USER`).
  - Circular avatar mask using `Kirigami.ShadowedImage`.
  - Dynamic user name fetching using `whoami`.
  - Hidden Power Menu (Sleep, Log Out, Restart, Shut Down) accessible by clicking the avatar.
- **New Quick Toggles**:
  - `Record`: Records the screen using `spectacle -R r`.
  - `Monitor`: Shows the KDE native display OSD (`ShowOSD`).

### Changed
- Refactored `QuickToggles.qml` to read the toggle layout dynamically from the KDE configuration (`togglesOrder`).
- Improved QML configuration property bindings (e.g. `onTogglesOrderTriggerChanged`) to ensure instant UI updates when Apply is clicked.
- Renamed "Capture" to "Screenshot" to be more explicit.
- Switched config system to Plasma 6's `ConfigModel` / `ConfigCategory`.

### Fixed
- Fixed broken Drag & Drop cursor offset (Jitter) in `configToggles.qml` by removing `ParentChange` and using absolute mouse coordinates `mapToItem`.
- Fixed the initial settings load in `configToggles.qml` so it waits for C++ values to be injected instead of falling back to default instantly.
- Fixed `ArchDrop` running state detection (changed to `pgrep -x archdrop` to avoid catching `sh -c`).
- Fixed `Ethernet` (266_Home) case sensitivity in toggle commands so it properly lights up when active.

### Added
- **Background Apps Module**: A minimal System Tray alternative that displays background-running apps (Status Notifier Items / SNI) directly in the Control Center.
  - Custom Python DBus Backend (`sni_backend.py`) to poll `org.kde.StatusNotifierWatcher`.
  - Left-click to show/restore the application.
  - Right-click to completely quit the application.
  - Dynamically updates active background apps every 3 seconds without blocking the UI.
  - Integrated into the layout configuration, allowing the module to be enabled/disabled and repositioned via the General Settings UI.
  - **Hotfix (Background Apps)**:
    - Fixed an issue where Electron-based applications (like Discord) failed to show up because they didn't implement standard `IconName` or `Title` properties on their dbus path. Added aggressive fallback extraction based on the application `Id`.
    - Right-click behavior has been enhanced. Instead of an immediate unprompted "Quit", it now opens a small context menu offering explicit "Open / Restore" or "Quit / Kill" options, preventing accidental app termination.
  - **Layout Fix**: Increased the default popup dimensions (minimum and preferred height) to accommodate the new Background Apps module and prevent the footer (user profile and time) from being squished or pushed out of view.
  - **Media Player Module Fix**: 
    - Bypassed the limitation where web browsers (Chrome, Brave, Firefox) expose media controls via MPRIS but do not allow volume adjustments.
    - Wrote custom Python scripts (`get_media_metadata.py` and `set_media_volume.py`) to automatically detect if the playing media is a browser and transparently hook into its direct **PulseAudio/PipeWire** application volume stream instead. 
    - The volume slider now correctly and individually adjusts browser volumes just like native apps (e.g., Spotify).
  - **Design & UI Overhaul (Liquid Glass)**:
    - Shifted the entire UI paradigm to a modern "Floating Cards" design.
    - Removed standard opaque popup backgrounds and sharp corners using `Plasmoid.backgroundHints: "NoBackground"`.
    - Implemented `GlassCard.qml` as a reusable translucent, rounded window frame (Radius 24px for outer, 16px for inner) mimicking frosted glass.
    - Added glossy specular highlights (white/transparent/dark gradients) to simulate light reflecting off metallic/glass surfaces.
    - Reorganized settings into categories, creating a dedicated "Theme" tab in the configuration window.
    - Added a design style toggle allowing users to switch between "Glossy Glass" (highly reflective) and "Matte Glass" (flat translucent).
  - **Color Tinting & Settings UI Refinement**:
    - Introduced a Glass Tint Color feature (`glassColor`) utilizing `Qt.tint` to blend custom hex colors into the base translucent background (outer frame at 35% tint, inner cards at 12% tint).
    - Refactored the Color Picker in the settings to use a clean, standard `ComboBox` dropdown to fix text overlapping issues. The dropdown menu provides a color preview circle next to the color's name.
  - **Identity Update**:
    - Renamed widget to "Control Center by DregosZ" to give it a unique identity.
    - Changed widget icon from default system settings to `view-grid` to match the module/dashboard design layout and avoid confusion with Plasma Settings.
  - **Dynamic Sizing & Layout Fixes**:
    - Replaced flexible width calculation (`Kirigami.Units`) with a strict `340px` absolute width bound. This ensures a consistent, slim smartphone-like profile regardless of display scaling settings that previously caused the widget to stretch excessively.
    - Switched from fixed 640px heights to dynamic height computation (`implicitHeight`). The widget now perfectly hugs its loaded modules and strictly respects `maximumHeight`, preventing Plasma from caching inflated bounds and aggressively flattening the corners when the window hits the screen edges.
    - Updated `MediaPlayer` track info with a robust scrolling marquee animation. If the song title or artist name is too long to fit the slim width, the text smoothly scrolls sideways. Shorter text elegantly elides without getting misaligned.
    - Replaced the manual text field for the custom taskbar icon with a native KDE `IconDialog` chooser, allowing users to browse and pick icons seamlessly through a rich UI.
  - **Configurable Widget Width**: Added a slider and spinbox to the 'Theme' settings page, allowing the user to precisely set the widget width from 250px up to 600px. This enables wrapping extra Quick Toggles into new rows without unnecessarily stretching the widget.
  - **Dynamic Size Presets & Safety Constraints**:
    - Replaced the simple widget width slider with a comprehensive "Widget Size" preset system (`Slim`, `Wide`, `Large`, and `Custom`).
    - Added smart constraints to manual height configuration (Custom mode). If the user configures a height that is shorter than the actual content, the layout intelligently falls back to `implicitHeight` (Auto-fit) to prevent clipping and broken UI.
    - Upgraded `QuickToggles.qml` to utilize a dynamic grid (`columns` auto-calculation). As the user expands the widget width (e.g. `Wide` or `Large`), the toggles will automatically flow into 5 or 6 columns per row, gracefully eliminating blank space without stranding items in the center.
  - **Refined Size Presets & Custom UX**:
    - Renamed and reconfigured the preset definitions to better reflect dimensional intents: `Default` (Auto height, standard width), `Fat` (Wider, auto height), and `Tall` (Fixed 600px height, standard width).
    - Improved the UX for the `Custom` size option: When transitioning from a standard preset (like `Fat` or `Tall`) back to `Custom`, the spinboxes and sliders now seamlessly inherit the exact width and height of the previously active preset, allowing the user to make continuous adjustments without the values jarringly jumping back to old defaults.
  - **Glass Appearance Restoration**:
    - Increased the `GlassCard.qml` base background opacity from `0.06` to `0.12` and the active tint color alpha from `0.12` to `0.25` to restore color vibrancy.
    - Boosted the specular highlight (glossy mode) gradients to `0.25` at the top and `0.30` at the bottom to bring back the strong "Liquid Glass" reflection that was lost when the custom outer popup background was removed.
  - **Layout Refinement (Gap Removal)**:
    - Removed the hardcoded `anchors.margins: Kirigami.Units.largeSpacing` from the main layout. Since `StandardBackground` already injects native OS dialog margins, the hardcoded margins were creating an ugly "double gap" effect. Removing them allows the inner frosted cards to sit snugly against the true edges of the widget, massively improving cohesion and the "single glass object" feel.
  - **Ultra-Premium Glass Aesthetics (Liquid Glass v2)**:
    - Upgraded `GlassCard.qml` from a flat `Rectangle` to a `Kirigami.ShadowedRectangle` to cast soft, realistic drop shadows (`size: 15`, `yOffset: 3`) underneath each module card, making them visibly float above the main OS background.
    - Implemented a true "Edge Lighting" effect by forcing the 1px inner border to be semi-transparent white (`Qt.rgba(255, 255, 255, 0.20)`) instead of relying on the active theme's text color. This mimics light catching the rim of thick physical glass.
    - Dramatically intensified the specular reflection gradients (boosted top highlight to `0.45` alpha and bottom shadow to `0.45` alpha), delivering a profound "thick glass" or "acrylic" depth.
  - **Color Vibrancy & Specular Falloff Refinement**:
    - Fixed an issue where the glass tint appeared "muddy" or "pale" in dark mode. Changed the color blending algorithm from a composite `Qt.tint` (which pre-multiplied with white/black) to a pure `Qt.alpha` (0.35) application. This yields a much cleaner, more vibrant, and authentic colored glass aesthetic.
    - Improved the specular highlight gradient. Stretched the inner reflection falloffs from `0.15/0.85` to `0.25/0.75` and boosted the edge alpha to `0.50`. This creates a smoother, thicker, and highly realistic glass curve reflection.
  - **Refined True Glass Material**:
    - Fixed the issue where the widget appeared as opaque "metallic car paint" (especially in Light Mode) instead of transparent glass. 
    - Removed the harsh black gradients from the specular highlight entirely; true glass reflects white/bright light without casting heavy internal black shadows.
    - Dropped the tint alpha from 35% back down to 20% to fully restore background blur transparency, while maintaining the pure tint algorithm to prevent muddiness.
  - **Tint Styles & Light Mode Enhancements**:
    - Introduced a new `Tint Style` setting in the Theme configuration with 3 profiles:
      - **Vibrant**: Clear & Saturated glass (Default).
      - **Pastel**: Soft & Milky Mixed glass. Achieved by compositing the tint color with the OS's native `backgroundColor` at 40% alpha, creating a beautiful pastel tone that respects both dark and light modes.
      - **Subtle**: Highly Transparent glass (12% alpha).
    - Greatly improved Light Mode visibility by adding a subtle adaptive base layer (`Kirigami.Theme.textColor` at 8% alpha) that provides contrast against white backgrounds, preventing the glass from turning invisible.
    - Boosted drop shadow opacity to `0.35` and made edge lighting adaptive to guarantee the cards "pop" clearly against light backgrounds.
  - **Hotfix (Tint Style)**: Fixed a bug where changing the `Tint Style` in the settings did not enable the "Apply" button because the `cfg_tintStyle` property was missing from the QML root item.
  - **Light Mode Saturation Fix**: Fixed the "Vibrant" color algorithm. Previously, it composited the color over an 8% black contrast layer (intended for "None"), which severely muddied bright colors like Orange into a dirty gray-brown in Light Mode. `Vibrant` now uses pure 45% alpha color, guaranteeing the tint stays clean, rich, and highly visible against bright wallpapers.
  - **Tint Style Scaling Adjustment**:
    - Re-calibrated the opacity and saturation scale across all Tint Styles to provide a much wider and distinct range based on user feedback.
    - `Vibrant`: Boosted alpha from `0.45` to `0.75` for a deeply saturated, stained-glass appearance.
    - `Pastel`: Increased the milky base to `0.55` and tint alpha to `0.55`, resulting in a creamy, solid pastel that mimics the intensity of the old "Vibrant" mode but retains its soft texture.
    - `Subtle`: Increased tint alpha from `0.15` to `0.25` so the color remains clearly visible while preserving high background transparency.
  - **Subtle Tint Refinement**: Removed the dark contrast base layer from the "Subtle" tint style and increased its pure tint alpha to `0.35`. This prevents the glass from looking "grey" in Light Mode and provides a cleaner, perfectly transparent colored glass aesthetic.
  - **Subtle Tint Transparency**: Dropped the Subtle tint alpha down to `0.25` (pure color) to increase transparency and distance it from the Pastel style, achieving the perfect balance of light tint without murkiness.
  - **Subtle Tint Refinement (Base Frost Restored)**: Restored a 4% `textColor` base frost to the Subtle style (mixed with the 25% tint color). This revives the tangible "glass" material look while keeping the grey muddiness to a minimum, ensuring it still looks like tinted glass rather than a flat plastic sheet.
  - **Universal Glass Material Frosting**: Applied a universal `4%` base frost (`textColor` alpha) to *all* Tint Styles (Vibrant, Pastel, Subtle, and None). This ensures every configuration retains the physical "tinted glass material" look without crossing over into the flat "plastic sheet" territory, successfully balancing structural glass texture with clean color transparency.
  - **Subtle Tint Refinement (Base Frost Restored)**: Fine-tuned the universal base frost down to `2%` to find the absolute minimum threshold required to retain the "glass material" substance without introducing any perceived greyness into the vibrant colors.
  - **Quick Toggles Modernization**:
    - Replaced legacy multi-color icons with modern, flat symbolic equivalents (`isMask: true` on `Kirigami.Icon`) to enforce a unified monochromatic look that perfectly matches the text color.
    - Swapped out specific old icons for better alternatives (e.g., `preferences-desktop-theme` -> `weather-clear-night`, `applications-internet` -> `document-share`).
    - Redesigned the toggle button shape: Removed the heavy, high-contrast white border on inactive states and replaced it with a sleek, translucent background (`0.08` alpha) and a micro `0.1` alpha white inner edge for depth, bringing it in line with modern iOS/macOS UI guidelines.
  - **Quick Toggles 3D Glossy Material**: Replaced the flat toggles with `Kirigami.ShadowedRectangle` to cast a drop shadow (size 10, y-offset 2), physically separating the buttons from the background glass card. Added a "Glossy Dome Overlay" (an internal rectangle with a top-to-bottom white-to-black micro-gradient) to simulate light reflecting off a rounded, polished 3D button surface.
  - **Configuration Menu Synchronization**: Updated `configToggles.qml` (the Quick Toggles configuration menu) so that the icon names, button shapes, 3D glossy overlays, and `isMask` flattening behavior perfectly match the modern design of the actual widget.
  - **Quick Toggles Icon & Layout Overhaul**:
    - Appended the `-symbolic` suffix to all icon names (e.g., `camera-photo-symbolic`, `contrast-symbolic`) to guarantee they load as sleek, monochrome vectors instead of glitchy solid white blocks.
    - Reduced the circular frame size from `Kirigami.Units.iconSizes.huge` to a fixed, sleeker `44px` diameter, eliminating the bulky/fat appearance.
    - Improved grid distribution by adding `Layout.fillWidth: true` to the column delegates, spacing the buttons out evenly across the entire width of the card rather than clustering them awkwardly in the center.
    - Synchronized all spacing, sizes, and specific icon names in the `configToggles.qml` settings window to perfectly match the main widget.
  - **Quick Toggles Layout Refinement**:
    - Changed the `GridLayout` to explicitly use `Layout.fillWidth: true` and locked the column count to `5` per row to prevent awkward centering. The layout now perfectly distributes the toggles evenly across the entire width of the card.
    - Fixed a broken Bluetooth icon mapping (`bluetooth-active-symbolic` was failing to load a maskable SVG) by changing it back to the reliable `preferences-system-bluetooth` standard, fully integrating it with the `isMask` flattening behavior.
  - **Quick Toggles Spacing & Bluetooth Fix**:
    - Re-wrote the internal grid delegate using an `Item` wrapper with `Layout.fillWidth: true` and `anchors.horizontalCenter: parent.horizontalCenter` to forcefully compel `GridLayout` to equally distribute all 5 columns across the horizontal space, eliminating the right-side gap.
    - Reverted Bluetooth icon back to standard `bluetooth` to fix the missing mask SVG issue.
  - **Quick Toggles Uneven Spacing & Solid Block Icon Fixes**:
    - Fixed an issue where `GridLayout` was allocating different column widths based on label text length (causing the right side gap) by explicitly setting `Layout.preferredWidth: 1` on the column delegates, forcing exactly equal width distribution.
    - Disabled `isMask: true` globally for toggles because certain system icons (`bluetooth`, `camera-photo-symbolic`) contain SVG paths that render as solid blocks when forced into a mask. Since all icons are now `-symbolic` variants (or naturally flat), they natively adopt the monochrome appearance without needing the mask hack.
  - **Quick Toggles Crash Fix**:
    - Replaced the hardcoded `Math.floor` preferred width calculation that was evaluating to negative numbers during QML initialization (causing the grid to collapse into a single stacked column) with a native layout constraint (`Layout.minimumWidth: 1`) which safely forces equal width distribution.
  - **Custom Toggle Icons**:
    - Implemented a highly requested feature allowing users to right-click on any quick toggle in the settings menu to browse and assign a custom SVG/PNG icon.
    - Custom icon paths are seamlessly serialized into `togglesOrder` configuration string.
    - Added a convenient "Reset to Default Icon" context menu option to easily rollback custom icons.
  - **Clickable Clock Settings**:
    - Transformed the clock/date area in the Footer into an interactive button.
    - Added subtle hover highlight and pointer cursor to signal interactivity.
    - Clicking the clock now launches the KDE Time & Date settings module (`kcmshell6 kcm_clock`).
  - **Liquid Glass Clock Hover**:
    - Replaced the standard solid blue hover highlight over the clock area with a sleek, pill-shaped Liquid Glass border overlay to maintain design consistency with the rest of the widget.
  - **Settings Sidebar Icons**:
    - Changed the generic KCM sidebar icons to more specific ones (`settings-configure` for General, `view-grid` for Quick Toggles, and `preferences-desktop-color` for Theme).
  - **General Settings UI Overhaul**:
    - Replaced the ugly mouse drag handle with a proper `handle-sort-symbolic` drag grip icon.
    - Updated generic module icons to match their actual purpose (`media-playback-start`, `view-grid`, etc.).
    - Applied the Liquid Glass style (glossy gradients, drop shadows, and glass borders) to the drag-and-drop list items in the General Settings tab to match the main widget aesthetic.
  - **Taskbar Icon Upgrades**:
    - Changed the default widget icon on the taskbar from the generic `view-media-equalizer` to a sleek `view-app-grid-symbolic` (a 3x3 dot matrix) which much better represents a "Control Center" or "App Drawer" and avoids confusion with audio volume applets.
    - Added a new UI section at the top of the General Settings tab allowing the user to browse and pick a completely custom SVG/PNG icon for the taskbar widget.
  - **Taskbar Icon Sizing and Symbol**:
    - Reverted the default taskbar icon to `pan-up-symbolic` (a small upward-pointing triangle/chevron).
    - Hardcoded a custom `contentItem` override in `main.qml` to force the icon size to be explicitly smaller (`Kirigami.Units.iconSizes.small`) than standard adjacent icons in the system tray.
