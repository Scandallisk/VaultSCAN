# VaultSCAN v0.4.0

**Less managing. More adventuring.**

VaultSCAN is a lightweight, in-game character roster dashboard for **World of Warcraft Retail**. View your characters' gold, equipped item levels, played time, and activity in one sortable window—without maintaining a separate spreadsheet.

## What's new in v0.4.0

### Last Played tracking
- A **Last Played** column records the most recent character login observed by VaultSCAN.
- Sort the roster by Last Played to find characters you haven't visited recently.
- Previously tracked characters display **—** until you log into them with v0.4.0 installed. This is not Blizzard's account-wide historical login data.

### Weekly item-level progression
- VaultSCAN automatically records **weekly snapshots of equipped item level** when a valid value is available.
- **Hover over a character's item level** to see up to **12 recent weekly snapshots**.
- Up to **52 weekly records per character** are retained. The current week's record reflects the latest observed equipped item level for that week.
- History starts when v0.4.0 is installed; past weeks cannot be reconstructed retroactively.

### Class-aware roster display
- Blizzard class icons appear beside character names.
- Character names and equipped item-level values use class colors for quick visual recognition.

### Redesigned dashboard header
- Taller, cleaner custom title bar with a prominent **VaultSCAN** title.
- **48 × 48 gold-coin emblem** at the upper-left corner of the window; hover for the addon author and version.
- Larger **36 × 36 close button**, aligned with the title bar.
- **Close-button hotfix:** clicking the X now closes the *entire* VaultSCAN window, not just its custom header.

## Core features

- **Gold tracking:** See each character's saved gold balance and the combined **Total Wealth** of your tracked roster.
- **Equipped item-level comparison:** Compare characters' equipped item levels and sort the roster by item level.
- **Played time:** View each character's accumulated played time and the combined **Total Played Time**.
- **Character overview:** Display character name, class icon, gold, equipped iLvl, played time, last played, faction, and realm.
- **Sortable columns:** Click a column heading to sort; click again to reverse the direction.
- **Scrollable, resizable window:** Browse larger rosters, resize the dashboard, and move the window.
- **Character removal:** Click the small red **×** beside a character and confirm to delete its stored record.
- **Minimap launcher:** Open or close VaultSCAN using the draggable gold-coin minimap button; its position is saved.
- **Chat command:** Type `/vaultscan` to toggle the dashboard.
- **Quiet startup:** One login message: `VaultSCAN v0.4.0: Ready.`

## Installation and upgrade

1. **Close World of Warcraft.** Before upgrading, back up your saved data if present:
   `World of Warcraft/_retail_/WTF/Account/<account>/SavedVariables/VaultSCAN.lua`
2. Extract the addon folder to:
   `World of Warcraft/_retail_/Interface/AddOns/VaultSCAN/`
3. Ensure `VaultSCAN.toc`, the `.lua` files, and `README.md` are directly inside the `VaultSCAN` folder—not an additional nested folder.
4. Replace the existing addon files. **Do not delete your SavedVariables file.**
5. Start WoW, then type `/vaultscan` or click the minimap coin.

### Upgrading from v0.3.0

Existing `VaultSCANDB[realm][character]` records are preserved. Version 0.4.0 adds `lastPlayed` and `history` fields without requiring a reset or manual migration. Previously saved gold, item-level, and played-time information remains available; offline characters update when you next log into them.

## Using VaultSCAN

- **Sort:** Click a table column header; click again to change direction.
- **Inspect progression:** Hover over a character's **iLvl** value to view recent weekly snapshots.
- **Move the dashboard:** Drag the window by its frame.
- **Resize:** Use the frame's resize handle.
- **Close:** Click the red **X**; the entire dashboard closes.
- **Remove a record:** Click the small red **×** beside a character and confirm. This removes its saved entry, not the actual WoW character.
- **Debug listing (optional):** `/vsdebug` prints tracked-character details in chat.

## Important notes

- VaultSCAN stores character information **locally in WoW SavedVariables**. It does not transmit your roster to an external service.
- **Last Played** is the latest login that VaultSCAN itself has recorded, not a full account history.
- Weekly progression reflects **equipped** item level, not an all-time maximum or daily history.
- Character values can only be refreshed when the relevant character is played; offline characters retain their last saved values.
- For a safe upgrade, keep a backup of your SavedVariables file.

## v0.4.0 release verification

- [x] Custom title bar renders correctly in-game (user confirmed).
- [x] Close button hides the entire window (user confirmed).
- [ ] Verify weekly history after the next weekly snapshot period.
- [ ] Confirm Last Played updates as additional characters are visited.
- [ ] Complete final release testing across characters, sorting, resizing, and minimap interactions.

---

**FOR THE VAULT!** ⚔️💰
