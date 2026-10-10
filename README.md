# VaultSCAN

**Version 0.2.0** · World of Warcraft Retail addon · Built with Lua

VaultSCAN is a lightweight character wealth dashboard for World of Warcraft. Track the gold and equipped item level of characters you've logged into, and compare them across realms in one convenient window.

## Features

- **Multi-character tracking:** Saves gold, equipped item level, class, faction, and realm for each character you log into.
- **Total Wealth:** Displays the combined gold of all saved characters.
- **Sortable dashboard:** Click **Character**, **Gold**, **iLvl**, **Faction**, or **Realm** to sort; click again to reverse the order. Defaults to highest equipped item level first.
- **Color-coded information:** Class-colored character names and item levels, Alliance blue, Horde red, and light-gold realm names.
- **Resizable window:** Drag the bottom-right corner to adjust the dashboard; scroll through longer character lists.
- **Minimap button:** Left-click to toggle the dashboard or drag to reposition the button. Its minimap position is saved between sessions.
- **Automatic updates:** Refreshes saved gold when money changes and equipped item level when gear changes.

## Installation

1. Download the repository as a ZIP file or clone it.
2. Place the `VaultSCAN` folder in your World of Warcraft Retail addons directory:

   ```text
   World of Warcraft/_retail_/Interface/AddOns/VaultSCAN/
   ```

3. Make sure `VaultSCAN.toc` is directly inside that folder (not inside an additional nested folder).
4. Start or reload World of Warcraft and enable **VaultSCAN** in the AddOns list if necessary.

## Usage

- Type `/vaultscan` to open or close the dashboard.
- Alternatively, left-click the gold coin minimap button.
- Click a column header to sort; click it again to reverse the direction.
- Drag the window's bottom-right resize grip to resize the dashboard.
- Drag the minimap button to move it around the minimap.

VaultSCAN collects data when you log into each character. **Characters you haven't logged into since faction tracking was introduced may display `Unknown` until their next login.** Gold and item level reflect the most recently saved values for each character, not live updates for offline characters.

## Current dashboard columns

| Column | Description |
| --- | --- |
| Character | Character name, colored by class |
| Gold | Saved character gold balance |
| iLvl | Equipped item level |
| Faction | Alliance, Horde, or Unknown |
| Realm | Character's realm |

The **Total Wealth** value at the bottom sums saved character gold across the dashboard.

## Development status

**v0.2.0 — Active development**

Implemented in this version:

- Resizable, scrollable dashboard
- Realm and faction tracking
- Larger headers and improved column layout
- Clickable ascending/descending sorting
- Draggable minimap button with saved position and corrected hover appearance
- Left-aligned title displaying `VaultSCAN version 0.2.0`

### Planned improvements

- Separate character records from addon preferences in SavedVariables
- Persist window size and sorting preferences
- Continue refining the UI and addon configuration

Planned items are not yet implemented.

## Project structure

```text
VaultSCAN/
├── VaultSCAN.toc   # Addon metadata and file loading order
├── Database.lua    # Character data persistence and retrieval
├── UI.lua          # Dashboard, sorting, scrolling, and resizing
├── Minimap.lua     # Minimap button, dragging, and hover behavior
└── VaultSCAN.lua   # Game events and slash commands
```

## Repository

[VaultSCAN on GitHub](https://github.com/Scandallisk/VaultSCAN)

---

**FOR THE VAULT!** ⚔️💰
