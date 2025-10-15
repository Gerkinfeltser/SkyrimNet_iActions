# SkyrimNet iActions
**Version 0.2.0** (2025-10-15)

A SkyrimNet extension that adds dynamic NPC drunk states with OAR-driven animations, automatic sobering, and additional utility actions.

## ⚠️ Experimental - Use With Caution

**This mod is in early development and not thoroughly tested.** It manipulates NPC AI states, faction membership, and uses persistent tracking, which could potentially:
- Conflict with mods that modify NPC behavior or faction systems
- Cause unexpected NPC behavior or AI issues
- Interrupt quest-related NPC states
- Have unforeseen side effects

**Recommended**: Test in a separate save and avoid using on essential/quest NPCs until further hardening and testing.

## What's New in Version 0.2.0

### Major Feature Additions:
- **Alcohol Inventory System**: NPCs must have alcohol items to get drunk (configurable)
- **Automatic Decay System**: NPCs gradually sober up over time (5-minute polling cycles)  
- **Member Tracking**: Persistent tracking of drunk NPCs using StorageUtil
- **New Actions**: Arrow extraction and standalone stumbling
- **Enhanced Safety**: WebUI-accessible debug and uninstall functions
- **Action Cooldowns**: 8-second cooldowns prevent drink/stumble spamming

### Script Architecture Overhaul:
- **Modular Design**: Split into `iActions_DrunkSystem` + `iActions_Lib` for better maintainability
- **Improved Performance**: Configurable polling system with automatic cleanup
- **Better Error Handling**: Comprehensive null checks and dead actor handling

## Requirements

### Core Requirements
- **Skyrim SE/AE** (tested on 1.6.1170)
- **SkyrimNet** (& its requirements)

### Animation Requirements
- **Open Animation Replacer (OAR)**
- **[Drunk or drugged animations OAR](https://www.nexusmods.com/skyrimspecialedition/mods/62191)** - Required files:
  - Main file: **"Drunk animations"**
  - Optional: **"Drunk animations classic movement"** (adds more exaggerated sway, but has foot sliding issues)

**Note**: Without OAR and the drunk animation mod, NPCs will enter drunk faction but won't display animations. A legacy idle-based fallback exists but is disabled by default.

## Installation

1. Install all requirements listed above
2. Install SkyrimNet_iActions with your mod manager
3. **Load Order (Critical)**: Place `SkyrimNet_iActions.esp` **AFTER** the OAR drunk animation mod in your mod manager
   - This ensures the included OAR config override applies the faction condition to drunk animations
   - In MO2, drag SkyrimNet_iActions below "Drunk or drugged animations OAR" in the left pane
4. Enable `SkyrimNet_iActions.esp`

## Safe Uninstallation

⚠️ **IMPORTANT**: This mod uses StorageUtil to track drunk NPCs across your save. **"Save corruption" refers to NPCs remaining stuck in the drunk faction without proper tracking** - they won't automatically sober up and may stay permanently drunk.

**For v0.2.0+ users:**
1. Open SkyrimNet's WebUI **Game Data Explorer** interface
2. Click the **📜 Quests** button
3. Find **"iActions for SkyrimNet (Drunk & Misc)"** and click the **🔍 View Scripts** button
4. Click the **"iActions_DrunkSystem"** entry to expand it
5. Find **"_PrepareForUninstall"** and click the green **"Execute Function"** button
6. Refocus Skyrim and wait for confirmation: **"iActions: Uninstall cleanup complete. Safe to disable mod."**
7. Save your game
8. Disable `SkyrimNet_iActions.esp` in your mod manager

**For users upgrading from v0.1.0 or earlier:**
The OnInit function automatically scans for and fixes "orphaned" drunk NPCs from previous versions, adding them back to the tracking system. No manual intervention needed.

**Do not skip the uninstall steps** or drunk NPCs may remain permanently stuck in drunk animations without the ability to naturally sober up.

### Emergency Debug Functions
You can also use the WebUI to call these functions for debugging:
- **_ListDrunkMembersNotify** - Shows all currently drunk NPCs with their levels
- **_ClearAllDrunkMembersNotify** - Emergency cleanup, removes ALL drunk NPCs immediately
- **_ScanAndFixOrphanedDrunksNotify** - Finds and fixes NPCs stuck in drunk faction

## Features

### Enhanced Drunk System

Makes NPCs visibly drunk with swaying animations based on dialogue context, using a faction rank system to track intoxication levels with automatic decay.

#### DrinkBooze Action
**Triggers:**
- When NPC drinks alcohol in dialogue (ale, mead, wine)
- When dialogue/narration indicates intoxication
- When explicitly prompted via narration

**Priority:** 9 (higher priority than most actions - ALWAYS select over GESTURE when alcohol is involved)

**Effect:** 
- Adds NPC to `DrunkFaction` or increments rank (if already drunk)
- Consumes alcohol item from NPC's inventory (if RequireAlcohol enabled)
- Triggers OAR drunk animations based on faction membership
- Stumble effect for heavily intoxicated NPCs (black-out drunk level)
- In-game notification showing drunk level and remaining alcohol count
- **Cooldown**: 8-second cooldown prevents drink spamming

**Alcohol Inventory System:**
When `RequireAlcohol` is enabled (default), NPCs must have alcohol in their inventory to get drunk:

- **Detection**: Uses `iActions_AlcoholList` FormList to define valid alcohol items
- **Consumption**: NPCs equip and "drink" actual alcohol items from their inventory
- **Tracking**: Shows remaining alcohol count in notifications
- **AI Integration**: Prompt system shows alcohol inventory status to help AI understand drinking capability
- **Failure Handling**: If no alcohol found, shows "has no alcohol to drink!" message

**FormList Configuration:**
- Populate `iActions_AlcoholList` with any items that should count as alcoholic
- Supports potions, food items, or any ingestible with alcohol theme
- Currently uses basic string matching in prompts (ale, mead, wine, brandy)
- **TODO**: Expand with vanilla non-essential/unique items to avoid quest conflicts

#### Point-Based Drunk Progression System

The system uses configurable point-based progression with automatic decay:

**Configuration Properties:**
- `PointsPerLevel = 2` - Points required for each drunk category
- `PointsPerDrink = 2` - Points added per drink (except first drink)
- `PointsPerDecay = 1` - Points reduced per polling cycle
- `MaxDrunkLevel = 3` - Maximum drunk category level
- `MemberPollRate = 300.0` - Polling interval in seconds (5 minutes)

**Drunk Categories:**
| Category | Rank Range Formula | State | Description |
|----------|-------------------|-------|-------------|
| Sober | Not in faction | - | Normal behavior, no animations |
| Tipsy | 0 to (PointsPerLevel-1) | 0 | Light sway animations |
| Drunk | PointsPerLevel to (PointsPerLevel×2-1) | 1 | Moderate sway/stumble |
| Plastered | PointsPerLevel×2 to (PointsPerLevel×3-1) | 2 | Heavy intoxication animations |
| Black-out Drunk | PointsPerLevel×3+ | 3 | Very heavy intoxication with stumbling |

**Example with default PointsPerLevel = 2:**
- Tipsy: 0-1, Drunk: 2-3, Plastered: 4-5, Black-out Drunk: 6+

**Rank Progression Behavior:**
- **First drink**: Joins faction at rank 0 (Tipsy level)
- **Subsequent drinks**: Each drink adds `PointsPerDrink` (2) to current rank
- **Automatic decay**: Every `MemberPollRate` (300 seconds), all drunk NPCs lose `PointsPerDecay` (1) point
- **Complete sobering**: When rank drops below 0, NPC is removed from faction entirely

**Example Progression:**
1. First drink: Rank 0 (Tipsy)
2. Second drink: Rank 2 (Drunk) 
3. Third drink: Rank 4 (Plastered)
4. Fourth drink: Rank 6 (Black-out Drunk)
5. After 6 decay cycles (30 minutes): Back to sober

Each `DrinkBooze` action adds points based on `PointsPerDrink`. The LLM does not control rank directly - it only triggers the action.

#### SobersUp Action
**Triggers:**
- When NPC mentions sobering up or feeling clear-headed

**Priority:** 8

**Eligibility:** Requires NPC to be in `DrunkFaction` (uses `is_in_faction` decorator check)

**Effect:** 
- Fully removes NPC from `DrunkFaction` (complete reset)
- Plays wipe-brow idle animation (with 2-second delay for animation sequencing)
- Stops drunk animations immediately
- In-game notification: "is sobering up"
- `EvaluatePackage()` call to refresh AI behavior

**Current Limitation**: Sobering is binary (drunk → sober), not gradual. Gradual rank reduction is planned for future versions.

### New Actions in v0.2.0

#### HaveArrowsExtracted Action
**Triggers:**
- When dialogue indicates arrows/bolts are being removed from a character
- When NPCs mention having projectiles pulled out by themselves or someone else

**Priority:** 8

**Effect:** 
- Removes embedded arrows and crossbow bolts from the character using iActions_Lib.ClearExtraArrows
- Works on both self-extraction and extraction by others
- Provides visual cleanup of combat aftermath
- In-game notification: "arrow/bolts have been extracted"

**Technical Details:**
- Uses `akPincushion` parameter for the character having arrows extracted
- Includes unused `akSurgeon` parameter for future expansion (medical scenarios)
- Integrates with SkyrimNet's action system for contextual triggering

#### StumbleAndFall Action
**Triggers:**
- When NPC loses their footing, trips over obstacles, or falls due to intoxication, injury, or environmental hazards
- Use **OFTEN** when NPC is reported as "plastered" or "black-out drunk"

**Priority:** 8

**Effect:** 
- Causes NPC to stumble and fall using standalone stumble effect
- Works independently of the drunk system for various scenarios
- Provides visual feedback for loss of balance
- Uses iActions_Lib.StumbleStandalone_Execute for standalone execution
- **Cooldown**: 8-second cooldown prevents stumble spamming

**Usage Notes:**
- Can be used for both drunk and non-drunk stumbling scenarios
- Particularly effective for heavily intoxicated NPCs (plastered/black-out drunk levels)
- Integrates with SkyrimNet's action system for contextual triggering

### Enhanced LLM Integration - Prompt Injection

The mod includes an improved prompt file (`SKSE/Plugins/SkyrimNet/prompts/submodules/character_bio/1020_iaction_drunk.prompt`) that **automatically exposes drunk state and alcohol inventory to the LLM**.

**Enhanced in v0.2.0:**
- **Alcohol Status**: Shows if NPC "currently carrying alcohol" or "has no alcohol on hand"
- **Drunk State Visibility**: Provides context-aware descriptions based on render mode
- **Point-Based Accuracy**: Uses correct drunk category calculation

**How it works:**
- Uses `get_faction_rank()` decorator to check `DrunkFaction` membership
- If NPC is in the faction (rank 0-3), injects intoxication info into character bio
- When `RequireAlcohol` is enabled, also shows alcohol inventory status
- Provides context-aware descriptions based on `render_mode`:
  - **"full" or "thoughts" mode** (NPC's self-awareness): "You are drunk - noticeably intoxicated with slurred speech and poor balance."
  - **"dialogue_target" mode** (player observation): "Lyne is noticeably drunk - swaying slightly, slurred words, and clearly intoxicated."

**Example injected text:**
```
## Intoxication
Lyne is plastered - heavily drunk, very unsteady, and prone to poor decisions.
Currently carrying alcohol.
```

This allows the AI to naturally incorporate intoxication into:
- Dialogue responses (slurred speech, rambling)
- Decision-making (poor judgment, emotional reactions)
- Self-awareness (acknowledging feeling drunk)
- NPC behavior consistency

The prompt file uses Inja templating with conditional logic for each rank level, ensuring appropriate descriptions for Tipsy/Drunk/Plastered/Black-out states.

## Technical Details

### Enhanced Script Architecture (v0.2.0)

**Modular Design:**
- **Library Quest**: `iActions_LibQuest`
- **Library Script**: `iActions_Lib.psc` - Shared utilities, new actions (LogAlert, Min, Stumble, etc.)
- **Main Quest**: `iActions_MainQuest` (renamed from SkyrimNet_iActions_DrunkSystemQuest)
- **Core System**: `iActions_DrunkSystem.psc` - Streamlined drunk system logic

**Core System Functions:**
- `SetDrunkState_IsEligible()` - Eligibility check (currently minimal on script side)
- `SetDrunkState_Execute()` - Routes to drunk/sober based on bool parameter
- `SetActorDrunkState()` - Core state manager
- `GetDrunkLevel()` - Classifies rank → string label
- `GetDrunkCategory()` - Returns numeric category (0-3)
- `PlayAnim()` - Handles idle animations with brief script delays (2 seconds for animation sequencing)

**Member Tracking Functions:**
- `TrackDrunkMember()` / `UntrackDrunkMember()` - StorageUtil list management
- `SoberUpDrunkMembers()` - Automatic decay system
- `ListDrunkMembers()` - Debug function showing all tracked drunk NPCs
- `PruneInvalidMembers()` - Cleanup function removing dead/invalid entries

**WebUI Debug Functions** (prefixed with "_" for easy access):
- `_ListDrunkMembersNotify()` - Debug function to show all drunk NPCs with their current levels
- `_ClearAllDrunkMembersNotify()` - Emergency cleanup function to immediately sober all NPCs
- `_PrepareForUninstall()` - Safe uninstall cleanup function
- `_ScanAndFixOrphanedDrunksNotify()` - Debug function to find and fix NPCs stuck in drunk faction

**Shared Library Functions:**
- `StumbleStandalone_Execute()` - Standalone stumbling action
- `ClearExtraArrows_Execute()` - Arrow extraction action
- `LogAlert()` - Enhanced logging with DirectNarration support
- `Stumble()`, `Min()`, `CoinFlip()` - Utility functions
- `StopUsingFurniture()` - Animation preparation helper

### OAR Integration
This mod includes an OAR config override (`meshes/actors/character/animations/OpenAnimationReplacer/Drunk animations/Drunk animations/config.json`) that adds:
```json
{
  "condition": "IsInFaction",
  "Faction": {
    "pluginName": "SkyrimNet_iActions.esp",
    "formID": "4DFD"
  }
}
```
to the existing drunk animation conditions. This retains compatibility with survival mods, CACO, and other intoxication systems while adding SkyrimNet support.

### Backward Compatibility & "Save Corruption"

**What "Save Corruption" Actually Means:**
The term "save corruption" in this context refers to NPCs being stuck in the drunk faction without proper tracking - they remain permanently drunk because they're not included in the decay system. This doesn't damage your save file, but creates annoying permanently drunk NPCs.

**Automatic Orphan Detection (v0.2.0+):**
- OnInit automatically scans loaded NPCs for drunk faction membership
- Adds any "orphaned" drunk NPCs to the tracking system
- Ensures seamless upgrading from v0.1.0 without manual cleanup
- `_ScanAndFixOrphanedDrunksNotify()` function available for manual scanning

### Member Tracking & Performance

**Persistent Tracking:**
- Uses StorageUtil with key `"iActions_DrunkMembers"` to maintain list across save/load cycles
- Automatic polling every `MemberPollRate` seconds (default: 300 = 5 minutes)
- Built-in cleanup removes dead/invalid NPCs from tracking
- Tracks NPCs when they join faction, removes when they leave

**Performance Optimizations:**
- Lightweight faction operations (native engine calls)
- Configurable polling intervals reduce script overhead  
- Automatic pruning prevents list bloat
- Action cooldowns prevent spam-induced lag
- Member tracking polls every 300 seconds (configurable via `MemberPollRate` property) starting 10 seconds after load

**Automatic Decay System:**
- Every polling cycle, all tracked drunk NPCs lose `PointsPerDecay` points
- NPCs with rank below 0 are completely removed from faction and tracking
- Gradual category changes are logged for visibility
- Emergency cleanup functions available via WebUI

### Legacy Idle System (Disabled by Default)
For users without OAR, a fallback system exists using `IdleDrunkStart`/`IdleDrunkStop` vanilla idles with retry logic. This is disabled by default (`DrunkIdleHack = False`) and **not recommended** due to unreliability. Enable via script property if needed.

### Animation Behavior
- **DrinkBooze**: No drinking animation (commented out due to timing/reliability issues). Stumble effect provides visual feedback for heavily intoxicated NPCs.
- **SobersUp**: Plays wipe-brow idle animation with 2-second delay before execution to allow animation to complete.

**Performance Note**: Uses `Utility.Wait()` for animation delays - acceptable for infrequent, user-initiated actions.

### Known Issues
- Faction rank progression is configurable but may need balancing if NPCs over-use the action
- Stumble effect (`PushActorAway`) can look janky/funny depending on environment. Expect some chaos...
- Animation success depends on NPC's current state/package
- String matching vs FormList in prompts due to limited Inja FormList support

## AI Integration Examples

SkyrimNet's AI automatically triggers actions based on conversation context:

**Getting Drunk:**
```
Player: "Let's have a drinking contest!"
NPC: "You're on! *chugs ale*"
[AI triggers DrinkBooze action]
[Faction rank: 0 → 2]
[Notification: "Lyne drinks. They are now drunk (3 left)"]
[Prompt injection: "Lyne is drunk - noticeably intoxicated..."]
*NPC stumbles and sways visibly*
*NPC's responses become slurred and less inhibited*
```

**Sobering Up:**
```
NPC: "My head's clearing up now..."
[AI triggers SobersUp action]
[NPC wipes brow]
[Faction rank: 2 → removed]
[Notification: "Lyne is sobering up"]
[Prompt injection removed]
*NPC returns to normal stance and speech*
```

**Progressive Intoxication:**
```
Player: "Another round?"
NPC: "Why not!" *drinks again*
[AI triggers DrinkBooze action]
[Faction rank: 2 → 4]
[Notification: "Lyne drinks. They are now plastered (2 left)"]
[Prompt updates: "Lyne is plastered - heavily drunk..."]
*Swaying intensifies*
*NPC makes increasingly poor decisions*
```

**Arrow Extraction:**
```
Player: "Hold still, I'll get those arrows out."
NPC: "Ugh, please do!"
[AI triggers HaveArrowsExtracted action]
[Notification: "Lyne's arrows removed by Player"]
*Arrows disappear from NPC model*
```

**Stumbling:**
```
NPC: *stumbles drunkenly*
[AI triggers StumbleAndFall action]
[Notification: "Lyne loses their balance."]
*NPC pushed away and falls*
```

## Configuration

### Script Properties (configurable via Creation Kit):
- `Lib` - Reference to iActions_Lib quest for shared utilities
- `DrunkFaction` - Tracks intoxication state and rank
- `iActions_AlcoholList` - FormList defining what items count as alcohol for drinking
- `RequireAlcohol` - Whether NPCs must have alcohol in inventory to get drunk (default: True)
- `MemberPollRate` - Seconds between drunk member list checks (default: 300)
- `PointsPerLevel` - Points required for each drunk category (default: 2)
- `PointsPerDrink` - Points added per drink except first (default: 2)
- `PointsPerDecay` - Points reduced per polling cycle (default: 1)
- `MaxDrunkLevel` - Maximum drunk category level (default: 3)
- Animation Properties: `IdleDrunkStart`, `IdleDrunkStop`, `IdleStop_Loose`, `IdleForceDefaultState`, `IdleDrink`, `IdleWipeBrow`

**Local Properties** (hardcoded):
- `VerboseLogging = True` - Debug traces with `[iAct]` prefix
- `UseFaction = True` - Enable faction-based system
- `AllowStumble = True` - Enable `PushActorAway` visual feedback
- `DrunkIdleHack = False` - Disable legacy idle system

### Action Files:
- `SKSE/Plugins/SkyrimNet/config/actions/drink_booze.yaml` (renamed from get_drunk.yaml)
- `SKSE/Plugins/SkyrimNet/config/actions/sobers_up.yaml` (renamed from get_sober.yaml)
- `SKSE/Plugins/SkyrimNet/config/actions/have_arrows_extracted.yaml` (NEW)
- `SKSE/Plugins/SkyrimNet/config/actions/stumble_and_fall.yaml` (NEW)

### Prompt Injection:
- `SKSE/Plugins/SkyrimNet/prompts/submodules/character_bio/1020_iaction_drunk.prompt`

## Development Notes

**File Structure:**
```
SkyrimNet_iActions/
├── Scripts/                    - Compiled .pex files
│   └── Source/                 - Source .psc files (iActions_DrunkSystem.psc, iActions_Lib.psc)
├── SKSE/Plugins/SkyrimNet/
│   ├── config/actions/         - Action YAML definitions (4 files)
│   └── prompts/submodules/character_bio/  - Prompt injection .prompt
├── meshes/.../Drunk animations/           - OAR config override
└── SkyrimNet_iActions.esp      - ESP plugin
```

### Current Limitations
- **String Matching vs FormList**: The prompt system currently uses string matching to detect alcohol mentions instead of FormList due to limited Inja FormList support. This is a temporary limitation until FormList support is confirmed in future Inja updates.
- **Binary Sobering**: SobersUp action is binary (drunk → sober), not gradual like the decay system
- **Animation Reliability**: Success depends on NPC's current state/package

## Future Plans
- **Timer-based gradual sobering** for SobersUp action (step down one rank instead of full reset)
- **Enhanced FormList integration** in prompt system when Inja support improves
- **MCM integration** for easier in-game configuration
- Potential unconsciousness state with `BleedOutStart` or custom package

## Changelog

### v0.2.0 (2025-10-15)
**Major Features:**
- **Added**: RequireAlcohol system with iActions_AlcoholList FormList integration
- **Added**: Automatic decay system with configurable 5-minute polling cycles  
- **Added**: Persistent member tracking using StorageUtil
- **Added**: HaveArrowsExtracted action for post-combat cleanup
- **Added**: StumbleAndFall standalone action
- **Added**: Action cooldowns (8 seconds) to prevent spam
- **Added**: WebUI-accessible debug and maintenance functions
- **Added**: Enhanced prompt system showing alcohol inventory status

**Script Architecture:**
- **Refactor**: Renamed to iActions_DrunkSystem (from SkyrimNet_iActions_DrunkSystem)
- **Added**: iActions_Lib shared library for utilities and new actions
- **Enhanced**: Modular code structure for better maintainability
- **Improved**: Error handling with comprehensive null/dead actor checks

**Action Changes:**
- **Renamed**: GetDrunk → DrinkBooze (with alcohol consumption)
- **Renamed**: GetSober → SobersUp (better clarity)
- **Enhanced**: Priority increased to 9 for DrinkBooze (was 8)
- **Enhanced**: Point-based progression system with configurable parameters

**Performance & Safety:**
- **Added**: Automatic cleanup of dead/invalid NPCs
- **Added**: Safe uninstall function (_PrepareForUninstall)
- **Optimized**: Configurable polling rates for better performance
- **Fixed**: Corrected drunk category calculation in prompt file

### v0.1.0 (2025-10-13)
- Public release based on v0.0.2 codebase
- Basic drunk/sober actions with faction rank system
- OAR integration with config override
- Prompt injection for LLM visibility
- Stumble effects and animation system

### v0.0.2 (2025-10-09)
- **Added**: Faction rank system (0-3 progression)
- **Added**: OAR integration with config override
- **Added**: `GetDrunkLevel()` classification system
- **Added**: Incremental drunkenness (repeated drinks increase rank)
- **Added**: Wipe-brow animation for sobering
- **Added**: `is_in_faction` decorator eligibility check for GetSober
- **Added**: Prompt injection system (`1020_iaction_drunk.prompt`) for LLM visibility into drunk state
- **Changed**: Action priority increased to 8 (from 5)
- **Changed**: Rank 2 relabeled "Plastered" (was "Black-out Drunk")
- **Changed**: Rank 3 now "Black-out Drunk" (was "Unconscious")
- **Changed**: Stumble effect now on by default (`AllowStumble = True`)
- **Changed**: IdleHack system disabled by default (`DrunkIdleHack = False`)
- **Changed**: Drinking animation disabled (commented out) due to timing issues
- **Changed**: Notification text: "sobering up" (was "is now sober")
- **Removed**: Pacify system (moved to separate development)
- **Improved**: Debug logging with clearer messages
- **Improved**: Code cleanup and documentation

### v0.0.1 (2025-10-03)
- Initial release
- Basic drunk/sober actions with vanilla idle system
- DrunkFaction tracking
- YAML action definitions for SkyrimNet integration
- Quest and script infrastructure

## Credits

- **SkyrimNet team** for the LLM integration framework
- **Gokuma** for Drunk or drugged animations OAR
- **Skyrim modding community** for documentation and tools
- **powerofthree** for Papyrus Extender
- **exiledviper** for PapyrusUtil

## License

MIT - Do whatever, just credit if you redistribute.