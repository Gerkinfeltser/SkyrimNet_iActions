# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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