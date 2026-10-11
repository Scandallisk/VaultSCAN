# VaultSCAN v0.5.0 — Warband Update (Test Build)

**Less managing. More adventuring.**

VaultSCAN is a World of Warcraft Retail addon that displays your tracked characters in a sortable, in-game roster.

## What's new in v0.5.0

- **Character Level:** New sortable Level column, immediately before Gold. Captured on login and level changes. Previously tracked characters display **—** until you log into them with v0.5.0.
- **Warband Bank Wealth:** Uses `C_Bank.FetchDepositedMoney(Enum.BankType.Account)` to read account-bank gold (in copper). Saves one balance per account, not per character. Attempts a scan at login, when account money changes, and when a bank opens. The last successfully scanned value is retained across sessions; it may become stale until the next successful scan.
- **Four footer totals:** Character Wealth, Warband Bank Wealth, Total Wealth, and **Total Played Time**. Character Wealth is the sum of tracked characters' last recorded purse balances. Total Wealth adds the account-bank balance **once**. Until a successful Warband Bank scan, the bank reads **Not scanned** and Total Wealth reads **Pending bank scan**, rather than showing an incorrect total.
- **UI polish:** Approved circular gold coin with gold border, aligned within the enlarged title bar; subtle fixed separator under column headings; close button still hides the whole window.
- **Version information:** Tooltip, addon metadata, and startup message updated to v0.5.0.

## Features retained from v0.4.0

- Class-colored names and equipped item levels, class icons, faction and realm.
- Sortable roster, gold, equipped iLvl, played time, last played, and weekly iLvl history tooltips (up to 12 recent snapshots, 52 stored).
- Resizable, movable window, scrollable roster, character record removal with confirmation, draggable minimap button, `/vaultscan`, and `/vsdebug`.
- Total Played Time, including the tracked-character coverage indicator if some playtimes are unknown.

## Installation and upgrade

1. Exit World of Warcraft. Back up your existing `WTF/Account/<account>/SavedVariables/VaultSCAN.lua` file.
2. Unzip the included `VaultSCAN` folder into `_retail_/Interface/AddOns/`, replacing the existing addon files. Do **not** delete the SavedVariables file.
3. Launch Retail WoW and type `/vaultscan` or use the minimap coin.
4. Log into each character to populate its new Level value. Open your Warband Bank at least once if bank gold is not yet available.

The v0.4.0 SavedVariables structure is preserved. v0.5.0 adds an optional `level` field to each character and a separate top-level `warbandBank` record. Offline character gold and played time reflect their last saved values, not live account-wide data.

## v0.5.0 testing checklist

- [ ] Verify the new Level column appears between Character and Gold and sorts in both directions.
- [ ] Log into a character and confirm the Level value updates. Level up and confirm refresh.
- [ ] Open the Warband Bank and compare the bank gold to the in-game bank balance.
- [ ] Confirm Total Wealth equals Character Wealth plus Warband Bank Wealth, without double counting.
- [ ] Confirm all **four** footer rows, including Total Played Time, remain visible when resizing and scrolling.
- [ ] Confirm the new header divider, approved circular coin, tooltip v0.5.0, and full-window close button.
- [ ] Reload, switch characters, and verify the data and Warband Bank balance persist.
- [ ] Confirm sorting, delete confirmation, class icons, and weekly iLvl history still work.

## Known limitations

- This is a **test build**, not an in-game-verified final release. Warcraft's API availability can depend on account and bank state.
- The account-bank balance is a saved snapshot; the addon does not continuously poll or guarantee it is current on another character until the next successful scan.
- Characters not yet visited on v0.5.0 have unknown levels. Previously saved gold and playtime remain snapshots from the last visit.
- `Total Played Time` includes only characters whose played time was recorded; it is not an account-wide historical value provided by Blizzard.

## Changelog

**0.5.0 (test build):** Character levels and sorting; Warband Bank gold; expanded four-line footer; fixed column divider; circular coin and title-bar improvements; tooltip and version updates.

**0.4.0:** Last Played, weekly iLvl history, class icons/colors, redesigned title bar, fixed close button.
