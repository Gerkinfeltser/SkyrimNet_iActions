# SkyrimNet iActions
**Version 0.1.0** (2025-10-13) (was **Version 0.0.2** (2025-10-09))

A SkyrimNet extension that adds dynamic NPC drunk states with OAR-driven animations and faction-based progression.

## ⚠️ Experimental - Use With Caution

**This mod is in early development and not thoroughly tested.** It manipulates NPC AI states and faction membership, which could potentially:
- Conflict with mods that modify NPC behavior or faction systems
- Cause unexpected NPC behavior or AI issues
- Interrupt quest-related NPC states
- Have unforeseen side effects

**Recommended**: Test in a separate save and avoid using on essential/quest NPCs until further hardening and testing.

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

## Features

### Drunk System

Makes NPCs visibly drunk with swaying animations based on dialogue context, using a faction rank system to track intoxication levels.

#### GetDrunk Action
**Triggers:**
- When NPC drinks alcohol in dialogue (ale, mead, wine)
- When dialogue/narration indicates intoxication
- When explicitly prompted via narration
**Priority:** 8 (prioritizes over generic gesture actions when alcohol is involved)
**Effect:** 
- Adds NPC to `DrunkFaction` or increments rank (if already drunk)
- Triggers OAR drunk animations based on faction membership
- Stumble effect (pushes NPC slightly for visual feedback - on by default)
- In-game notification showing drunk level

**Faction Ranks (Proof of Concept):**
| Rank | State | Description |
|------|-------|-------------|
| -2 (not in faction) | Sober | Normal behavior, no animations |
| 0 | Tipsy | Light sway animations |
| 1 | Drunk | Moderate sway/stumble |
| 2 | Plastered | Heavy intoxication animations |
| 3 | Black-out Drunk | *Not yet implemented* |

Each `GetDrunk` action increments rank by +1 (max 3). The LLM does not control rank directly - it only triggers the action.

**Note**: Drinking idle animation disabled due to timing/reliability issues. Stumble provides sufficient visual feedback (& is funny).

#### GetSober Action
**Triggers:**
- When NPC mentions sobering up or feeling clear-headed
**Priority:** 8 (matches GetDrunk)
**Eligibility:** Requires NPC to be in `DrunkFaction` (uses `is_in_faction` decorator check)
**Effect:** 
- Fully removes NPC from `DrunkFaction` (complete reset)
- Plays wipe-brow idle animation (with 2-second delay for animation sequencing)
- Stops drunk animations
- In-game notification: "is sobering up"
- `EvaluatePackage()` call to refresh AI behavior

**Current Limitation**: Sobering is binary (drunk → sober), not gradual. Gradual rank reduction is planned for future versions.

## Technical Details

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

### Legacy Idle System (Disabled by Default)
For users without OAR, a fallback system exists using `IdleDrunkStart`/`IdleDrunkStop` vanilla idles with retry logic. This is disabled by default (`DrunkIdleHack = False`) and **not recommended** due to unreliability. Enable via script property if needed.

### Script Architecture
- **Quest**: `SkyrimNet_iActions_DrunkSystemQuest`
- **Script**: `SkyrimNet_iActions_DrunkSystem.psc`
- **Core Functions**:
  - `SetDrunkState_IsEligible()` - Eligibility check (currently minimal on script side)
  - `SetDrunkState_Execute()` - Routes to drunk/sober based on bool parameter
  - `SetActorDrunkState()` - Core state manager
  - `GetDrunkLevel()` - Classifies rank → string label
  - `PlayAnim()` - Handles idle animations with brief script delays (2 seconds for animation sequencing)

### Animation Behavior
- **GetDrunk**: No drinking animation (commented out due to timing/reliability issues). Stumble effect provides visual feedback.
- **GetSober**: Plays wipe-brow idle animation with 2-second delay before execution to allow animation to complete.

**Performance Note**: Uses `Utility.Wait()` for animation delays - acceptable for infrequent, user-initiated actions. Not suitable for high-frequency polling.

### Known Issues
- Faction rank progression is linear (+1 per drink) - may need balancing if NPCs over-use the action
- No gradual sobering - always full reset to sober
- No timer-based auto-sobering yet
- Stumble effect (`PushActorAway`) can look janky/funny depending on environment. Expect some chaos...
- Animation success depends on NPC's current state/package

## Future Plans
- **Decorator integration** for exposing drunk state in LLM prompts (e.g., `{{ npc.drunk_level }}`)
- **Timer-based sobering** (gradual rank decrease over time)
- **Rank-aware sobering** (ability to step down one rank instead of full reset)
- Potential unconsciousness state with `BleedOutStart` or custom package

## AI Integration

SkyrimNet's AI automatically triggers actions based on conversation context:

**Getting Drunk:**
```
Player: "Let's have a drinking contest!"
NPC: "You're on! *chugs ale*"
[AI triggers GetDrunk action]
[Faction rank: 0 → 1]
[Notification: "Lyne is now drunk"]
*NPC stumbles and sways visibly*
```

**Sobering Up:**
```
NPC: "My head's clearing up now..."
[AI triggers GetSober action]
[NPC wipes brow]
[Faction rank: 1 → removed]
[Notification: "Lyne is sobering up"]
*NPC returns to normal stance*
```

**Progressive Intoxication:**
```
Player: "Another round?"
NPC: "Why not!" *drinks again*
[AI triggers GetDrunk action]
[Faction rank: 1 → 2]
[Notification: "Lyne stumbles, now plastered"]
```

## Configuration

Actions are defined in YAML files:
- `SKSE/Plugins/SkyrimNet/config/actions/get_drunk.yaml`
- `SKSE/Plugins/SkyrimNet/config/actions/get_sober.yaml`

## Development Notes

**Script Properties** (set via Creation Kit):
- `DrunkFaction` - Tracks intoxication state and rank
- `IdleDrunkStart` - Legacy fallback idle (unused by default)
- `IdleDrunkStop` - Legacy fallback idle (unused by default)
- `IdleStop_Loose` - Animation reset idle
- `IdleForceDefaultState` - Force default animation state
- `IdleDrink` - Drinking animation (unused - commented out)
- `IdleWipeBrow` - Sobering animation

**Local Properties** (hardcoded):
- `VerboseLogging = True` - Debug traces with `[iAct]` prefix
- `UseFaction = True` - Enable faction-based system
- `AllowStumble = True` - Enable `PushActorAway` visual feedback
- `DrunkIdleHack = False` - Disable legacy idle system

**Performance Notes**:
- Faction operations are lightweight (native engine calls)
- No update loops or polling - event-driven only
- `EvaluatePackage()` called after state changes to refresh AI behavior
- Uses brief `Utility.Wait()` delays for animation sequencing (acceptable for infrequent actions)

## Changelog

### v0.0.2 (2025-10-09)
- **Added**: Faction rank system (0-3 progression)
- **Added**: OAR integration with config override
- **Added**: `GetDrunkLevel()` classification system
- **Added**: Incremental drunkenness (repeated drinks increase rank)
- **Added**: Wipe-brow animation for sobering
- **Added**: `is_in_faction` decorator eligibility check for GetSober
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

## Credits

- **SkyrimNet team** for the LLM integration framework
- **Gokuma** for Drunk or drugged animations OAR
- **Skyrim modding community** for documentation and tools
- **powerofthree** for Papyrus Extender
- **exiledviper** for PapyrusUtil

## License

Distributed as-is for educational/experimental purposes. Modify and redistribute freely with credit.
