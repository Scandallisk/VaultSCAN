# VaultSCAN v0.6.0 — Minimalist UI Release

**Less managing. More adventuring.**

VaultSCAN is a World of Warcraft Retail addon that displays tracked characters in a sortable, in-game dashboard, including their gold, levels, equipment item levels, playtime, faction, and realm. It also tracks a saved snapshot of Warband Bank gold and summarizes combined wealth.

A project by **Kilobytes.dev**. Source: https://github.com/Scandallisk/VaultSCAN

## What's new in v0.6.0

- **Minimalist dark redesign:** Near-black charcoal (`#101012`) dashboard, pure-black title bar, white headings and labels, and black divider lines.
- **Champagne Gold (`#D6C6A4`)** for character gold and all four footer values, with smaller footer value typography.
- **Updated icon:** `Ability_iyyokuk_bomb_white` on both the title bar and draggable minimap button. The title bar icon retains its circular gold border.
- **Refined layout:** Centered Last Played and Faction values, clear column spacing, and background/separator layering adjustments.
- **Version update:** Addon metadata, login message, and title icon tooltip identify v0.6.0.
- **Emote interaction:** Opening the dashboard via the minimap button triggers `/read`; hiding the dashboard also triggers `/read`.

## Features

- Sortable character roster with Character, Level, Gold, iLvl, Played, Last Played, Faction, and Realm columns.
- Class-colored character names and class icons; Alliance and Horde retain distinct faction colors.
- Equipped item level and weekly iLvl history snapshots (up to 52 weeks stored; 12 most recent shown in tooltips).
- Character gold totals and separately tracked Warband Bank gold. Total Wealth adds the bank balance **once**.
- Footer summaries: **Character Gold**, **Warband Gold**, **Total Wealth**, and **Total Played Time**.
- Movable, resizable dashboard with scrolling, sortable columns, and a character-removal confirmation dialog.
- Draggable minimap launcher, `/vaultscan` command, and `/vsdebug` diagnostic command.
- SavedVariables preserve tracked character records across sessions.

## Installation and upgrade

1. Exit World of Warcraft.
2. Back up your existing `WTF/Account/<account>/SavedVariables/VaultSCAN.lua` before updating.
3. Copy the included `VaultSCAN` folder to `World of Warcraft/_retail_/Interface/AddOns/`, replacing the existing addon code files. Avoid nesting the folder twice.
4. Launch Retail WoW and open VaultSCAN with `/vaultscan` or its minimap button.
5. Log in to each character to refresh that character's level, gold, equipment, and playtime snapshot. Open the Warband Bank to help refresh its balance.

**Do not delete the SavedVariables file.** This release does not require a SavedVariables reset or migration.

## How tracking works

- **Character Gold:** Sum of each tracked character's most recently recorded purse balance, not a live scan of offline characters.
- **Warband Gold:** The most recently successful account-bank scan using `C_Bank.FetchDepositedMoney(Enum.BankType.Account)`. Scans are attempted at login and when relevant bank/money events occur.
- **Total Wealth:** Character Gold plus Warband Gold, with account-bank money counted only once. Until a successful scan, the footer shows **Not scanned** and **Pending bank scan**.
- **Total Played Time:** Sum of the playtime recorded for tracked characters. A coverage indicator appears if any character's playtime is unknown.
- **Last Played:** Saved login timestamp, not a continuously updating activity feed.

## Commands and controls

| Action | Result |
| --- | --- |
| `/vaultscan` | Toggle the dashboard |
| `/vsdebug` | Print tracked character diagnostics to chat |
| Click minimap button | Toggle dashboard; play `/read` when opening |
| Drag minimap button | Reposition the launcher around the minimap |
| Click column heading | Sort by that column; click again to reverse |
| Click character remove control | Ask for confirmation before deleting saved tracking data |
| Close dashboard | Hide the window and play `/read` |

## v0.6.0 verification checklist

- [ ] Addon loads and shows `VaultSCAN v0.6.0: Ready.` in chat.
- [ ] Title icon tooltip reports `Version 0.6.0`.
- [ ] Dashboard displays the dark charcoal canvas and black header without exposed stock textures.
- [ ] Header and footer dividers are visible; white text and Champagne Gold values remain readable.
- [ ] Both icons display `Ability_iyyokuk_bomb_white`, and the minimap icon appears centered.
- [ ] Faction colors, class colors, sorting, scrolling, resizing, and deletion still work.
- [ ] Warband balance and all four footer summaries are correct for the recorded data.
- [ ] `/read` triggers on minimap opening and when the window closes.
- [ ] Saved character records persist after `/reload` and across logins.

## Known limitations

- The Warband Bank balance is a saved snapshot and may be stale until a successful new scan.
- Offline characters' wealth, gear, and playtime are last-recorded snapshots, not live values.
- Characters not yet visited after the Level feature was introduced may have an unknown level.
- Total Played Time covers only tracked characters with recorded playtime.
- UI appearance and Warcraft API behavior should be verified in-game after installation.

## Changelog

**v0.6.0 — Minimalist UI Release:** New charcoal-and-black visual design, white text, Champagne Gold data values, smaller footer value typography, updated `Ability_iyyokuk_bomb_white` title/minimap icon, layout and separator layering refinements, `/read` interactions, and synchronized release version strings.

**v0.5.0 — Warband Update:** Sortable character levels, account-wide Warband Bank wealth tracking, four footer totals, and expanded dashboard presentation.

**v0.4.0:** Last Played tracking, weekly item-level history, class icons/colors, redesigned title bar, and close-button fix.
