# VaultSCAN

**Less managing. More adventuring.**

VaultSCAN is a lightweight, standalone **World of Warcraft Retail** addon that brings your tracked characters, gold, Warband Bank balance, equipped item levels, playtime, and wealth history into one clean dashboard. It is developed by **SCAN | Kilobytes Development**.

**Current release candidate:** v1.0.1  
**Game:** World of Warcraft Retail  
**Interface:** `120105` (Retail 12.1.5)  
**Dependencies:** None

[Project website](https://kilobytes.dev/vaultscan/) · [GitHub repository](https://github.com/Scandallisk/VaultSCAN) · [GitHub releases](https://github.com/Scandallisk/VaultSCAN/releases)

## Features

### Character overview

- View characters recorded across your realms in a single dashboard.
- See character name, class icon/color, level, gold, equipped item level, total played time, last played date, faction, and realm.
- Sort the roster by column heading; click again to reverse the order.
- Use a movable, resizable, scrollable interface and a draggable minimap launcher.
- Remove an obsolete *saved character record* using the red `×` without deleting the in-game character.

### Wealth tracking and account trends

- Review individual character gold, total tracked character gold, the last available Warband Bank gold, and combined recorded wealth.
- View a **rolling 30-day Account Wealth Trend** with daily snapshots, net change, and percentage change.
- Hover over graph markers for dates, recorded balances, and changes since the previous observation.
- Distinguish **Verified** snapshots (filled markers) from **Estimated** snapshots (hollow markers).
- Preserve historical records across logins and retain up to **90 days** of saved daily wealth history.

### Equipment progression and playtime

- Compare currently recorded **equipped item levels** across characters.
- Review per-character weekly item-level history in an iLvl hover tooltip (up to **12 recent entries**); up to **52 weeks** are retained per character.
- View individual and combined recorded played time.

### Warband Bank support — improved in v1.0.1

VaultSCAN checks for available Warband Bank information quietly in the background. It **does not require a daily bank visit** and no longer displays a daily verification pop-up.

- **Verified:** World of Warcraft allowed VaultSCAN to view and read a current Warband Bank balance.
- **Estimated:** The game did not provide a verifiable current balance; VaultSCAN uses the **last verified Warband Bank amount** together with your characters' last saved gold balances. These observations are clearly marked as estimates.
- **Optional update:** Opening a viewable Warband Bank lets VaultSCAN attempt verification. If today's snapshot is Estimated, a successful scan can replace that day's estimate with a Verified observation.
- **Background retries:** While verification is unavailable, VaultSCAN attempts a check approximately every **90 seconds** during play and responds to relevant game/bank events.
- **Safeguards:** Failed reads do not overwrite the last verified balance. If there is no previously verified Warband balance, VaultSCAN does **not** invent an estimated account-wide history entry.

> **Warband Bank limitation:** Warcraft does not permit VaultSCAN to reliably verify the current Warband Bank balance automatically while the bank is not viewable. A value returned while the bank is closed may be cached; VaultSCAN will not present it as newly verified. The dashboard's gold **(i)** icon explains this limitation.

#### Optional Warband Bank Distance Inhibitor shortcut

Beside **Account Wealth Trend**, VaultSCAN provides a small shortcut for the **Warband Bank Distance Inhibitor** ability (summon spell ID `460905`).

1. Open VaultSCAN using its minimap icon or `/vaultscan`.
2. If your character has unlocked the spell and it is usable, click the bank shortcut next to the graph title.
3. When the game confirms spell activation, VaultSCAN closes so you can see the cast and use the summoned Warband Bank.
4. Open the bank to let VaultSCAN attempt to verify today's snapshot.

The shortcut respects cooldowns, combat restrictions, and ability availability. **Not every character/account has this ability**, and it may be unusable in some locations. If unavailable, VaultSCAN's regular tracking features still work. You can verify through any accessible Warband Bank whenever convenient.

## Getting started

### Install with CurseForge

1. Open the **CurseForge** application and select **World of Warcraft Retail**.
2. Search for **VaultSCAN** and choose **Install** (or **Update**).
3. Launch World of Warcraft Retail and log into a character.
4. Click the VaultSCAN minimap icon or enter `/vaultscan`.
5. Log into additional characters over time to add or refresh their saved records.

VaultSCAN begins collecting available character information at login. Daily wealth history starts when there is a usable Warband balance (verified or previously verified/cached); **a fresh installation may need its first Warband Bank visit** before it can calculate account-wide wealth history. At least two daily observations are needed to display a meaningful trend line.

### Manual installation / upgrade

1. Exit World of Warcraft.
2. For an upgrade, **back up your SavedVariables** before replacing addon files:
   `World of Warcraft/_retail_/WTF/Account/<account>/SavedVariables/VaultSCAN.lua`
3. Extract the release archive so the addon files reside at:
   `World of Warcraft/_retail_/Interface/AddOns/VaultSCAN/`
4. Verify the `VaultSCAN` folder directly contains `VaultSCAN.toc`, `Database.lua`, `UI.lua`, `Minimap.lua`, and `VaultSCAN.lua`—not an extra nested directory.
5. Restart the game. Keep your SavedVariables file; do **not** reset or delete it during an update.

### Commands

| Command | Function |
| --- | --- |
| `/vaultscan` | Open or close the VaultSCAN dashboard. |
| `/vsdebug` | Print saved character details in chat. |
| `/vsbankdebug` | Show read-only Warband Bank API/cache and snapshot diagnostics. |
| `/vsportaldebug` | Show portal ability/button, cooldown, and recent spellcast diagnostics. |

The last three commands are diagnostic utilities; ordinary use requires only `/vaultscan` or the minimap icon.

## How the data works

- **Local storage:** VaultSCAN stores records in World of Warcraft's built-in `VaultSCANDB` SavedVariables. It does not require external accounts, network services, or data uploads.
- **Last recorded values:** Characters you are not currently playing retain their most recently saved gold, item level, and other information until you log into them again. **Last Played** means the latest login observed by VaultSCAN, not your account's complete login history.
- **Daily wealth observations:** History represents a daily observation, **not** a live account-wide ledger or a record of every gold transaction. Missed days are not backfilled. Older v1.0.0 snapshots remain preserved as verified historical observations.
- **Today's estimated snapshot:** When bank verification is unavailable, a snapshot may be Estimated even if its numerical value resembles a previously verified balance. A later successful verification may upgrade *today's* estimate; older verified snapshots are not rewritten.
- **Current vs historical totals:** The displayed current total may differ from the latest saved historical snapshot as character balances change.
- **Security and privacy:** Your tracked data remains in your local WoW installation unless you choose to copy or share the SavedVariables yourself.

## v1.0.1 highlights

- Replaced daily Warband Bank reminder pop-ups with quiet background verification checks.
- Added automatic **Estimated** versus **Verified** wealth-history observations and distinct graph markers.
- Preserved the last verified Warband balance when fresh verification is unavailable.
- Added an optional Warband Bank Distance Inhibitor shortcut with ability/cooldown/combat handling.
- Added the instructional label **“Open your Warband Bank to update your snapshot”** and a gold information tooltip explaining the limitation.
- Improved portal activation behavior to close the dashboard only after World of Warcraft confirms the spell started.
- Preserved v1.0.0 roster, gold, equipment history, playtime, and wealth records.

For full release notes, see the v1.0.1 changelog distributed with the release materials.

## Compatibility and support

VaultSCAN is intended for **World of Warcraft Retail**. API behavior and available spells can change with game updates. Please report reproducible issues with the game version, VaultSCAN version, any Lua error text, and steps to reproduce.

- **Website:** https://kilobytes.dev/vaultscan/
- **Source and issues:** https://github.com/Scandallisk/VaultSCAN
- **Developer:** SCAN | Kilobytes Development

© 2026 Kilobytes Development. All rights reserved.

**VaultSCAN — Less managing. More adventuring.**
