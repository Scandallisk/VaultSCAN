# VaultSCAN

**Version 0.3.0** · World of Warcraft Retail addon · Built with Lua

VaultSCAN is a lightweight character dashboard for World of Warcraft. Track gold, equipped item level, and total played time across your characters and realms—all in one convenient window.

## Features

- **Multi-character tracking:** Saves each character's gold, equipped item level, played time, class, faction, and realm.
- **Total Wealth:** Displays the combined gold balance of all tracked characters.
- **Total Played Time:** Adds up the played time collected for your characters, so you can see your total time invested across your roster.
- **Sortable dashboard:** Click **Character**, **Gold**, **iLvl**, **Played**, **Faction**, or **Realm** to sort; click again to reverse the direction. The default sort is highest equipped item level first.
- **Character management:** Click the small **×** beside a character to remove their saved record, with a confirmation prompt to prevent accidental deletion. Totals update after removal.
- **Color-coded information:** Class-colored character names and item levels, Alliance blue, Horde red, and light-gold realm names.
- **Resizable window:** Drag the bottom-right corner to resize the dashboard; scroll through longer character lists.
- **Minimap button:** Left-click the gold coin to toggle the dashboard, or drag it around the minimap. Its position is saved between sessions.
- **Automatic updates:** Updates saved gold and equipped item level while you play and requests played-time information from WoW.

## Installation

1. Download the repository as a ZIP file or clone it.
2. Place the `VaultSCAN` folder in your World of Warcraft Retail addons directory:

   ```text
   World of Warcraft/_retail_/Interface/AddOns/VaultSCAN/
   ```

3. Make sure `VaultSCAN.toc` is directly inside that folder, not inside another nested folder.
4. Start or reload World of Warcraft and enable **VaultSCAN** in the AddOns list if necessary.

## Usage

- Type `/vaultscan` to open or close the dashboard, or left-click the minimap coin.
- Click any column header to sort; click again to reverse the direction.
- Drag the window's bottom-right resize grip to change its size.
- Drag the minimap coin to reposition it.
- Click the **×** beside a character and confirm to remove that character from VaultSCAN's saved data.

VaultSCAN collects information as you log into each character. **Gold, item level, and played time shown for offline characters are their last saved values, not live account-wide readings.**

### Played-time tracking

WoW provides played time through the same game data used by `/played`. VaultSCAN requests this information and stores it for each character. A character's **Played** column displays `—` until played-time data has been collected for that character.

The **Total Played Time** summary adds together known played-time values. When some characters have not yet been scanned, the total is incomplete; log into those characters to populate their records. Played time is displayed in days and hours, while the underlying data is stored in seconds for accurate sorting and summation.

### Removing characters

Removing a character deletes **only its VaultSCAN record**, not the actual World of Warcraft character. Its gold and played time are immediately excluded from dashboard totals. If you log into the removed character again, VaultSCAN can create a new record for it.

## Current dashboard columns

| Column | Description |
| --- | --- |
| Character | Character name, colored by class, with a delete control |
| Gold | Last saved character gold balance |
| iLvl | Last saved equipped item level |
| Played | Total played time collected for that character |
| Faction | Alliance, Horde, or Unknown |
| Realm | Character's realm |

At the bottom of the dashboard, **Total Wealth** sums saved gold and **Total Played Time** sums known played-time values across tracked characters.

## Development status

**v0.3.0 — Demo build / release candidate**

New in v0.3.0:

- Played-time collection, storage, and sortable dashboard column
- Combined **Total Played Time** summary
- Character deletion with confirmation and immediate total recalculation
- Corrected ascending/descending sorting behavior
- Improved saved-data handling to avoid overwriting valid gold and item-level values during character switching

Carried forward from v0.2.0:

- Resizable, scrollable dashboard with realm and faction tracking
- Class and faction coloring, sortable headers, and improved column spacing
- Draggable minimap button with persistent position and hover glow
- Left-aligned window title showing the addon version

### Planned improvements

- Separate character records from addon preferences in SavedVariables
- Persist window size, window position, and sorting preferences
- Continue refining the UI and addon configuration

Planned items are not yet implemented.

## Project structure

```text
VaultSCAN/
├── VaultSCAN.toc   # Addon metadata and file loading order
├── Database.lua    # Character data persistence and retrieval
├── UI.lua          # Dashboard, sorting, scrolling, resizing, and deletion UI
├── Minimap.lua     # Minimap button, dragging, and hover behavior
└── VaultSCAN.lua   # Game events, played-time requests, and slash commands
```

## Repository

[VaultSCAN on GitHub](https://github.com/Scandallisk/VaultSCAN)

---

**FOR THE VAULT!** ⚔️💰
