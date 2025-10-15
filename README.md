# SkyrimNet iActions - Quick Start

> ## ⚠️ **Warning: Experimental**
> Test on separate/non-precious saves first if you're risk-averse!
> (I haven't had issues but I don't wanna wreck your day/save.)

## TL;DR
- **What it does**: NPCs drink & get drunk with automatic sobering + extra actions
- **NEW in v0.2.0**: NPCs need actual alcohol in inventory, gradual sobering over time, arrow extraction, stumbling
- **Install**: Mod manager → Load after OAR drunk animations → Enable
- **Requirements**: Skyrim SE/AE + [SkyrimNet](https://github.com/MinLL/SkyrimNet-GamePlugin) (& its requirements) + OAR + [Drunk animations mod](https://www.nexusmods.com/skyrimspecialedition/mods/62191) (optional but recommended)

## Need More Info?
See [README_DETAILED.md](README_DETAILED.md) for complete, overly-verbose technical documentation and safety functions

## What's New in v0.2.0

### 🍺 **Realistic Drinking System**
- NPCs must have alcohol in their inventory to get drunk (ale, mead, wine, etc.)
- Shows how much alcohol they have left when drinking
- AI knows when NPCs have alcohol vs. when they're out

### ⏰ **Automatic Sobering**
- NPCs gradually sober up over time (every 5 minutes)
- No more permanently drunk NPCs cluttering your save!
- Can still instant-sober with "Sober Up" action

### 🏹 **Arrow Extraction**
- NPCs can remove arrows/bolts stuck in themselves or others
- Great for post-combat cleanup and medical roleplay

### 🤸 **Enhanced Stumbling**
- Separate stumble action for various scenarios (drunk, injured, clumsy)
- Better visual feedback with different stumble messages

### 🧠 **Smarter AI Integration**
- AI gets detailed info about NPC drunk states and alcohol inventory
- More realistic drunk dialogue and decision-making

## Quick Installation
1. Install all requirements
2. Install SkyrimNet_iActions with mod manager
3. **Critical Load Order**: Place AFTER "[Drunk or drugged animations OAR](https://www.nexusmods.com/skyrimspecialedition/mods/62191)" mod (& probably after SkyrimNet)

## What This Mod Does

### Main Features:
- **Smart Drunk System**: NPCs drink real alcohol → get progressively drunk → gradually sober up
- **Progressive States**: Tipsy → Drunk → Plastered → Black-out drunk (with automatic decay every 5 minutes)
- **AI Integration**: Prompt injector tells AI about NPC drunk states & alcohol in inventory
- **Visual Effects**: Drunk animations, stumbling behavior, and realistic feedback

### Actions:
- **Drink Booze**: NPCs drink alcohol from inventory to get progressively more drunk (8 second cooldown)
- **Sober Up**: NPCs instantly sober up and return to normal behavior  
- **Arrow Extraction**: Remove arrows/bolts from characters after combat
- **Stumble & Fall**: NPCs stumble when intoxicated, injured, or just clumsy (8 second cooldown)

### Important Notes:
- **Alcohol Required**: NPCs need alcohol in their inventory to get drunk (default setting)
- **Automatic Cleanup**: NPCs gradually sober up every 5 minutes automatically
- **Cooldown Protection**: 8-second cooldowns prevent drink/stumble spamming
- **Future Plans**: MCM menus for easier configuration settings

## Compatibility & Safety
- Maybe avoid using on essential quest NPCs
- Built-in safety/debug functions (including uninstall function) accessible via SkyrimNet WebUI
- **Safe Uninstall**: Use WebUI uninstall function before disabling mod to prevent NPCs getting stuck in drunk animations
- **Upgrading**: v0.2.0+ automatically fixes any "orphaned" drunk NPCs from previous versions
