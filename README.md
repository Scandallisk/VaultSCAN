# VaultSCAN Forever

**Less managing. More adventuring.**

VaultSCAN Forever 1.0.0 is a standalone World of Warcraft Forever addon by SCAN | Kilobytes Development. It brings your recorded characters, money, equipment progression and playtime into one compact dashboard.

## Features

- Full first-name and surname display, with unique character GUIDs preventing name collisions.
- Money displayed in gold, silver and copper, including balances below one gold.
- Current-character money and combined money across recorded Forever characters.
- Sortable character, level, money, item level, played time, last login, faction and realm columns.
- Daily combined-character money observations with a 30-day graph and about 90 days of retention.
- Weekly item-level observations and played-time tracking.
- Movable, resizable dashboard and draggable minimap launcher.
- No bank scanning, bank polling, portal shortcut or bank verification requirements.
- No third-party addon dependencies, telemetry or cloud synchronization.

## Installation

Use the packaged **VaultSCAN-Forever-1.0.0.zip**, not GitHub's automatically generated source archive. Extract its `VaultSCAN` folder into `World of Warcraft/_forever_/Interface/AddOns/`, then restart the client if this is a new installation. Enable **VaultSCAN Forever** in the AddOns list. Log into each character you want included and open `/vaultscan` or use the minimap icon.

Target: Forever 1.60.1, interface 16001. Owner testing used client 1.60.1.70938.

## Data and interpretation

Account Gold means the sum of characters this addon has observed in Forever. Offline characters use their last recorded balances; this is not an automatic discovery of every character on an account. Bank holdings, mail, auctions and inventory valuations are not included.

The graph records the first combined observation each calendar day. Later money changes update the roster and footer, not that day's saved observation. Missing days are not backfilled; scanning another character can change the combined total without representing money earned.

Data stays in local `VaultSCANForeverDB`, separate from Retail's `VaultSCANDB`. This is a separate client installation; no Retail balances or historical bank data are imported.

Prototype first-name-only records are archived under `legacyCharacters` rather than assigned to a potentially wrong character. Visit each character again to create clean GUID records. The archive is excluded from totals.

## Commands

- `/vaultscan`: open or close the dashboard.
- `/vsdebug`: show current character identity, record count and recorded money.

## Validation

Owner screenshots confirmed two same-first-name characters retained with surnames, sub-gold money presentation, current/account totals and a compact layout with full realm text. Lua 5.1 syntax and mocked money/identity/snapshot tests passed. Multi-day live rollover, 90-day live retention, fresh CurseForge installation and wider client coverage remain unverified.

To roll back, disable VaultSCAN Forever and reload. Keep its SavedVariables to preserve records.

Website: https://kilobytes.dev/vaultscan/

Source: https://github.com/Scandallisk/VaultSCAN/tree/forever

Copyright SCAN | Kilobytes Development. All rights reserved.
