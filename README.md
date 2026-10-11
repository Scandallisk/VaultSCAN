# VaultSCAN v0.4.0 — Release Candidate

A lightweight character dashboard for World of Warcraft Retail.

## Features
- Character and realm tracking: gold, equipped item level, played time, faction and class.
- Last Played: saved login timestamp, shown as a sortable date; older characters show — until logged in with v0.4.0.
- Weekly equipped item-level snapshots: recorded automatically when a valid item level is available. **Hover over a character's iLvl to see up to 12 recent weekly snapshots.** Up to 52 weekly records per character are retained. Each week's entry reflects the latest observed value that week; it is not a daily history.
- Blizzard class icons beside names; item levels match class-name colors.
- Sortable, scrollable, resizable dashboard with red × character deletion and confirmation.
- Combined Total Wealth and Total Played Time summaries.
- Gold coin on dashboard title bar; hover for author/version tooltip.
- Draggable minimap coin with saved position.
- Exactly one VaultSCAN login message: `VaultSCAN v0.4.0: Ready.`

## Install / upgrade
1. **Back up** `World of Warcraft/_retail_/WTF/Account/<account>/SavedVariables/VaultSCAN.lua` if it exists, while WoW is closed.
2. Extract the ZIP so `VaultSCAN.toc` is directly in `World of Warcraft/_retail_/Interface/AddOns/VaultSCAN/`.
3. Replace the existing five addon files and this README. Do **not** delete your SavedVariables.
4. Start WoW and open the dashboard using `/vaultscan` or the minimap coin.

## Existing data
The v0.3.0 `VaultSCANDB[realm][character]` records are retained in place; this version adds `lastPlayed` and `history` fields. Existing gold, item level, and played-time values remain intact. Offline characters cannot be scanned until you log into them. No data migration or reset is required.

## Verification checklist
- [ ] Only one VaultSCAN message appears at login.
- [ ] The window title reads VaultSCAN and the coin shows author/version on hover.
- [ ] Existing character gold, item levels, and played times are still present.
- [ ] Log into an alt: Last Played updates; old alts show — until visited.
- [ ] Hover an iLvl to view weekly progression data.
- [ ] Verify class icon and class-color item level for several different classes.
- [ ] Sort each column both ways; test scrolling, resizing, minimap dragging.
- [ ] Switch characters and verify saved gold and item levels remain correct.
- [ ] Test red × deletion **only on a record you intend to remove**.

## Notes
- Weekly history begins with v0.4.0; older item levels cannot be reconstructed.
- The current weekly entry is updated as the character's equipped item level changes.
- `Last Played` is the most recent login recorded by VaultSCAN, not a Blizzard account-wide activity history.
- The addon does not send data outside the WoW client.
- This is a release candidate: in-game validation is still required.

**FOR THE VAULT!** ⚔️💰
