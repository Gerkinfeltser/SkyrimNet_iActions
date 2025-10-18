# SkyrimNet iActions - Quick Start

> ## ⚠️ **Warning: Experimental**
> Test on separate/non-precious saves first if you're risk-averse!
> (I haven't had issues but I don't wanna wreck your day/save.)

## TL;DR
- **What it does**: NPCs drink & get drunk with automatic sobering + extra actions
- **NEW in v0.3.0**: MCM configuration menu, NPC alcohol requests, player force push, auto-sobering toggle
- **Install**: Mod manager → Load after OAR drunk animations → Enable → Configure via MCM
- **Requirements**: Skyrim SE/AE + [SkyrimNet](https://github.com/MinLL/SkyrimNet-GamePlugin) (& its requirements) + OAR + [Drunk animations mod](https://www.nexusmods.com/skyrimspecialedition/mods/62191) (optional but recommended)

## Need More Info?
See [README_DETAILED.md](README_DETAILED.md) for complete, overly-verbose technical documentation and safety functions

## What's New in v0.3.0

### 🎛️ **MCM Configuration Menu**
- Complete in-game configuration via MCM (Mod Configuration Menu)
- Real-time adjustments to drunk system parameters
- Core Settings: Auto-sobering toggle, decay rates, drunk progression
- Maintenance page: Reset settings, emergency cleanup functions

### 🍻 **Enhanced NPC Interactions**
- **TakeAlcohol Action**: NPCs can request alcohol from the player
- NPCs will ask for drinks when they want to get drunk but lack alcohol
- Realistic social drinking scenarios with inventory exchanges

### 💪 **Player Force Push System**
- Configurable key binding for physics-based object pushing
- Mass-based impulse calculations for realistic effects
- Debug integration shows drunk levels when force push is used

### ⚙️ **Advanced Configuration**
- **Auto-sobering Toggle**: Disable automatic decay if desired
- **Configurable Keybinds**: Customize force push key in MCM
- **Enhanced Debug Mode**: Shows drunk rank changes and levels
- **Reset Functionality**: Restore default settings via MCM

### 🔧 **Performance & Stability**
- Inventory optimization (≤16 items) prevents performance issues during alcohol checks
- Enhanced error handling and backward compatibility
- Improved bootstrap timing for better mod initialization

## Quick Installation
1. Install all requirements
2. Install SkyrimNet_iActions with mod manager
3. **Critical Load Order**: Place AFTER "[Drunk or drugged animations OAR](https://www.nexusmods.com/skyrimspecialedition/mods/62191)" mod (& probably after SkyrimNet)
4. **Configure via MCM**: Access settings through SkyUI's MCM interface

## What This Mod Does

### Main Features:
- **Smart Drunk System**: NPCs drink real alcohol → get progressively drunk → gradually sober up
- **Progressive States**: Tipsy → Drunk → Plastered → Black-out drunk (with configurable automatic decay, 5 minutes by default)
- **AI Integration**: Prompt injector tells AI about NPC drunk states & alcohol in inventory
- **Visual Effects**: Drunk animations, stumbling behavior, and realistic feedback
- **MCM Integration**: Full in-game configuration and maintenance tools

### Actions:
- **Drink Booze**: NPCs drink alcohol from inventory to get progressively more drunk (configurable cooldown, 8 seconds default)
- **Take Alcohol**: NPCs request alcohol from the player when they want to drink but have none
- **Sober Up**: NPCs instantly sober up and return to normal behavior  
- **Arrow Extraction**: Remove arrows/bolts from characters after combat
- **Stumble & Fall**: NPCs stumble when intoxicated, injured, or just clumsy (configurable cooldown, 8 seconds default)

### Player Features:
- **Force Push**: Configurable key binding to push objects/NPCs with physics effects
- **Debug Integration**: Optional drunk level display when debug mode is enabled

### Important Notes:
- **Alcohol Required**: NPCs need alcohol in their inventory to get drunk (default setting, configurable via MCM)
- **Automatic Cleanup**: NPCs gradually sober up every 5 minutes automatically (can be disabled via MCM)
- **Cooldown Protection**: Configurable cooldowns prevent drink/stumble spamming (8 seconds by default)
- **MCM Configuration**: All settings now configurable in-game via MCM interface

## Compatibility & Safety
- Maybe avoid using on essential quest NPCs
- Built-in safety/debug functions (including uninstall function) accessible via SkyrimNet WebUI
- **MCM Reset Options**: Reset core settings via MCM Maintenance page
- **Safe Uninstall**: Use MCM Maintenance page (recommended) or WebUI uninstall function before disabling mod
- **Upgrading**: v0.3.0+ automatically handles backward compatibility and property initialization
