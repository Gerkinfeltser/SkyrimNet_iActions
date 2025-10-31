# SkyrimNet iActions - Quick Start

**For detailed documentation, see the [SkyrimNet iActions Wiki](https://github.com/Gerkinfeltser/SkyrimNet_iActions/wiki).**

> ## ⚠️ **Warning: Experimental**
> Test on separate/non-precious saves first if you're risk-averse!

## TL;DR
- **What it does**: NPCs drink, get drunk & sober over time (plus a few extras) via SkyrimNet actions
- **NEW v0.4.0**: Better drink sharing, optional "drinking on the house" in inn & taverns, improved MCM
- **Better drink sharing** → When NPCs need alcohol for drinking, an optional (on by default) dialog lets you provide it from your inventory (or automatically) if available
- **Install**: Mod manager → Load after OAR drunk animations → Configure in MCM
- **Requirements**: Skyrim SE/AE + SkyrimNet + OAR + [drunk animations](https://www.nexusmods.com/skyrimspecialedition/mods/62191) (optional)

## Quick Installation
1. Install requirements (SkyrimNet, OAR)
2. Install SkyrimNet_iActions with mod manager
3. Load AFTER OAR drunk animations mod
4. Configure in MCM menu

**⚠️ Upgrading from 0.3.0 & mod's MCM pages blank?**

**Method 1: Use 0.4.0's WebUI Uninstall (Recommended)**
1. With 0.4.0 enabled, use SkyrimNet WebUI to run `WebUI_PrepareForUninstall()` on `iActions_MCM` script
2. Save game, exit Skyrim completely, disable mod
3. Start Skyrim, load save, optionally run `setstage SKI_ConfigManagerInstance 1` in console to kick MCM
4. Save, exit Skyrim, enable 0.4.0 again
5. Start Skyrim, load save - MCM should populate correctly (optionally running `setstage SKI_ConfigManagerInstance 1` if its slow)

**Method 2: Revert to 0.3.0 (Fallback)**
- Temporarily re-enable 0.3.0 → MCM uninstall → save → disable mod → load/save → enable 0.4.0 → load save

**Note**: 0.3.0 lacks the comprehensive WebUI uninstall function, making Method 1 simpler.

## What It Does
- **Drunk System**: NPCs drink alcohol → get drunk → sober up automatically
- **Actions**: Drink alcohol, request alcohol, sober up, extract arrows, stumble
- **Player Features**: Force push, optional in-game debug notifications

## Key MCM Settings
- Alcohol required by default (can be disabled completely or only in inns/taverns)
- 20-second cooldowns to prevent drink/stumble spam
- Auto-incremental sobering every 5 minutes (configurable)
- Key-bindable shove (middle-mouse button works well, unbound by default)
- All(/most) settings in MCM menu
