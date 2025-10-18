# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2025-10-18

### Added
- **Complete MCM interface** with Core Settings and Maintenance pages (`iActions_MCM.psc`)
- **TakeAlcohol action** for NPCs to request alcohol from player when they lack inventory
- **Configurable force push system** with customizable key binding (`ForcePushKeyCode` property)
- **Auto-sobering toggle** (`EnableAutoSobering` property) to disable automatic decay system
- **Debug rank display** (`ShowDrunkRank` property) showing drunk levels during force push and transitions
- **Reset core settings** functionality in MCM with detailed confirmation dialog
- **Real-time configuration updates** - all MCM changes apply immediately without restart
- **Enhanced bootstrap system** with MCM quest management and improved error handling
- **Inventory optimization** - alcohol checks limited to NPCs with ≤16 items for performance
- **Configurable action cooldowns** for DrinkBooze and StumbleAndFall via MCM (1-30 seconds)
- **Dynamic key registration** system with proper cleanup of previous bindings
- **Mass-based force push physics** for more realistic object interactions

### Changed
- **MCM now primary interface** for configuration (WebUI remains as fallback)
- **Enhanced bootstrap timing**: OnInit 1.0s→2.0s, OnPlayerLoadGame 0.1s→0.5s for better mod compatibility
- **Improved maintenance system** with better property initialization and error handling
- **Enhanced debug integration** - force push displays drunk levels when debug mode enabled
- **Reorganized MCM interface** with Core Settings and Maintenance page separation
- **Updated prompt system** to remove drunk rank values for cleaner output
- **Refined alcohol list** - added missing wines, removed unique items (Colovian Brandy)
- **Better backward compatibility** for existing saves when adding new properties

### Fixed
- **Enhanced property validation** in MCM to prevent crashes when systems aren't initialized
- **Improved error handling** in maintenance functions with comprehensive system validation
- **Better force push mass calculations** for more realistic physics effects
- **Fixed debug output formatting** for rank changes and decay operations
- **Enhanced coin flip function** calls to use direct reference instead of wrapper
- **Improved logging consistency** using direct LogAlert calls with proper parameter ordering

### Technical
- **Bootstrap quest management** ensures both main quest and MCM quest reliability
- **Script instance validation** verifies all components are accessible during initialization
- **Enhanced spell-based approach** replacing some faction operations for better reliability
- **Comprehensive settings reset** covering all core mod properties
- **Dynamic key binding management** with `UpdateKeyRegistration()` function

## [0.2.0] - 2025-10-15

### Added
- Alcohol inventory requirement system (`RequireAlcohol` property, `iActions_AlcoholList` FormList)
- Automatic decay system with configurable polling (default: 5min cycles, `MemberPollRate` property)
- Persistent member tracking using StorageUtil (`"iActions_DrunkMembers"` key)
- HaveArrowsExtracted action for post-combat cleanup
- StumbleAndFall standalone action with DirectNarration
- Action cooldowns (8 seconds for DrinkBooze and StumbleAndFall)
- WebUI-accessible debug functions (`_ListDrunkMembersNotify`, `_ClearAllDrunkMembersNotify`, `_ScanAndFixOrphanedDrunksNotify`)
- Safe uninstall function (`_PrepareForUninstall`)
- Automatic orphan detection in OnInit for backward compatibility
- Point-based configuration system (`PointsPerLevel`, `PointsPerDrink`, `PointsPerDecay` properties)

### Changed
- **BREAKING**: Renamed actions: `GetDrunk` → `DrinkBooze`, `GetSober` → `SobersUp`
- **BREAKING**: Script names: `SkyrimNet_iActions_DrunkSystem` → `iActions_DrunkSystem`
- DrinkBooze priority increased to 9 (from 8)
- Enhanced prompt system shows alcohol inventory status
- Modular architecture: split utilities into `iActions_Lib.psc`
- Improved error handling with comprehensive null/dead actor checks

### Fixed
- Backward compatibility: auto-detects and fixes orphaned drunk NPCs from v0.1.0
- Corrected drunk category calculation in prompt file
- Enhanced animation handling with furniture detection

## [0.1.0] - 2025-10-13

### Added
- Public release based on v0.0.2 codebase
- Faction rank system (0-3 progression)
- OAR integration with config override
- Prompt injection system (`1020_iaction_drunk.prompt`)
- Progressive intoxication levels (Tipsy/Drunk/Plastered/Black-out Drunk)

## [0.0.2] - 2025-10-09

### Added
- Faction rank system for tracking intoxication levels
- OAR integration with config override
- `GetDrunkLevel()` classification system
- Wipe-brow animation for sobering
- `is_in_faction` decorator eligibility check
- Prompt injection for LLM visibility into drunk state

### Changed
- Action priority increased to 8 (from 5)
- Stumble effect enabled by default
- IdleHack system disabled by default
- Drinking animation disabled due to timing issues

### Removed
- Pacify system (moved to separate development)

## [0.0.1] - 2025-10-03

### Added
- Initial release
- Basic GetDrunk/GetSober actions
- Vanilla idle animation system
- DrunkFaction tracking
- YAML action definitions
- Quest and script infrastructure