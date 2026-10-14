# VaultSCAN

**Less managing. More adventuring.**

VaultSCAN is a lightweight, minimalist character dashboard for **World of Warcraft Retail**, designed to help adventurers track their characters, wealth, equipment progression, and playtime across Azeroth.

Developed by **SCAN | Kilobytes Development**.

## Current Release

**Version:** 0.6.1  
**Compatibility:** World of Warcraft: Midnight 12.1.5  
**Interface:** 120105  
**Release Type:** Compatibility Update

### What's New in v0.6.1

This release updates VaultSCAN's compatibility metadata for the World of Warcraft: Midnight 12.1.5 client.

- Updated the addon interface version from `120100` to `120105`.
- Updated the addon version to `0.6.1`.
- Updated in-game version references.
- Preserved all existing v0.6.0 features and functionality.
- No changes to the character database or SavedVariables structure.
- No changes to the dashboard's visual design or minimap icon.

**Note:** This is a compatibility maintenance release. It does not introduce new gameplay features.

## Features

### Character Dashboard
- View characters across multiple realms in one organized window.
- Display character names with their corresponding class colors and icons.
- Track character levels, factions, and realms.
- See when each character was last played.
- Sort dashboard columns to organize your roster.

### Gold & Wealth Tracking
- Track gold balances for individual characters.
- View combined character gold.
- Track Warband Bank gold when available.
- Calculate total wealth from recorded character gold and Warband Bank gold.

### Equipment & Progression
- Track equipped item levels.
- View weekly item-level history through tooltips.
- Compare character progression across your roster.

### Playtime Tracking
- Record individual character playtime.
- Display combined total played time.
- Identify characters whose playtime has not yet been recorded.

### Minimalist Interface
- Clean, dark dashboard with high-contrast text.
- Champagne-gold currency values.
- Class-colored character names and faction-specific colors.
- Resizable and scrollable character dashboard.
- Draggable minimap button for convenient access.
- Confirmation before deleting saved character records.

## Installation

### CurseForge

1. Open the CurseForge application.
2. Select **World of Warcraft**.
3. Ensure the selected game installation is **Retail**.
4. Search for **VaultSCAN**.
5. Install the latest compatible release.
6. Launch World of Warcraft and confirm VaultSCAN is enabled in the AddOns menu.

### Manual Installation

1. Download the latest VaultSCAN release ZIP.
2. Extract the `VaultSCAN` folder into:

   `World of Warcraft/_retail_/Interface/AddOns/`

3. Confirm that `VaultSCAN.toc` and the Lua files are directly inside the `VaultSCAN` folder.
4. Launch World of Warcraft and enable VaultSCAN.

## Usage

- Type `/vaultscan` to open or close the dashboard.
- Left-click the minimap icon to open VaultSCAN.
- Drag the minimap icon to reposition it.
- Click column headers to change sorting.
- Drag the dashboard's bottom-right corner to resize the window