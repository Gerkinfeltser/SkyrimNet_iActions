# iActions [Drunk+] for SkyrimNet - Quick Start

> ## ⚠️ **Warning: Experimental**
> Test on separate/non-precious saves first if you're risk-averse!

> ## 📢 **Important: v0.5.0 Rebrand & ESL Update**
> This mod has been renamed from "SkyrimNet iActions" to "iActions" to clarify it's **not officially developed by the SkyrimNet team**. This version requires clean migration due to ESL conversion - see upgrade notes below.

## 🍻 [**Latest Release v0.5.0 here!!!**](https://github.com/Gerkinfeltser/iActions/releases/tag/0.5.0)
**For detailed documentation, see the [iActions Wiki](https://github.com/Gerkinfeltser/iActions/wiki).**

## TL;DR
- **What it does**: NPCs drink, get drunk & sober over time (plus a few extras) via SkyrimNet actions
- **NEW v0.5.0**: 5-tier drunk system (Buzzed→Blackout), major performance optimizations, new MCM settings, rebranded to clarify non-official status
- **Better drink sharing** → When NPCs need alcohol for drinking, an optional (on by default) dialog lets you provide it from your inventory (or automatically) if available
- **Install**: Mod manager → Load after OAR drunk animations → Configure in MCM
- **Requirements**: Skyrim SE/AE + SkyrimNet + OAR + JContainers + PO3_SKSEFunctions + [drunk animations](https://www.nexusmods.com/skyrimspecialedition/mods/62191) (optional)

## Quick Installation
1. Install requirements (SkyrimNet, OAR, JContainers, PO3_SKSEFunctions)
2. Install iActions with mod manager
3. Load AFTER OAR drunk animations mod
4. Configure in MCM menu

**⚠️ Upgrading from v0.4.0 or earlier? CRITICAL MIGRATION REQUIRED!**

**v0.5.0 ESL Migration (Required)**
1. Use MCM "Prepare for Uninstall" with your current version
2. Save game, quit Skyrim completely
3. Disable old mod, uninstall from mod manager
4. Start Skyrim, load save (expect normal warnings about missing scripts)
5. Save again, quit Skyrim
6. Install v0.5.0, enable mod
7. Start Skyrim, load save - MCM may take a moment to register (use `setstage SKI_ConfigManagerInstance 1` if needed)

**⚠️ Upgrading from 0.3.0?**
**Method 1: Use 0.4.0's WebUI Uninstall (Recommended)**
1. With 0.4.0 enabled, use SkyrimNet WebUI to run `WebUI_PrepareForUninstall()` on `iActions_MCM` script
2. Save game, exit Skyrim completely, disable mod
3. Start Skyrim, load save, optionally run `setstage SKI_ConfigManagerInstance 1` in console to kick MCM
4. Save, exit Skyrim, enable 0.5.0 (follow ESL migration above)
5. Start Skyrim, load save - MCM should populate correctly (optionally running `setstage SKI_ConfigManagerInstance 1` if its slow)

**Method 2: Revert to 0.3.0 (Fallback)**
- Temporarily re-enable 0.3.0 → MCM uninstall → save → disable mod → load/save → enable 0.5.0 → follow ESL migration

## What It Does
- **Drunk System**: NPCs drink alcohol → get drunk → sober up automatically (5 levels: Buzzed, Tipsy, Drunk, Plastered, Blackout)
- **Actions**: Drink alcohol, request alcohol, sober up, extract arrows, stumble
- **Player Features**: Force push, optional in-game debug notifications
- **Performance**: Optimized inventory detection, cached alcohol lookups, reduced script lag

## Key MCM Settings
- Alcohol required by default (can be disabled completely or only in inns/taverns)
- 20-second cooldowns to prevent drink/stumble spam
- Auto-incremental sobering every 5 minutes (configurable)
- **NEW**: Max simultaneous drunk NPCs (8-128, default 32)
- **NEW**: Toggle drink animations (user preference for animation timing)
- **NEW**: Performance logging for optimization monitoring
- Key-bindable shove (middle-mouse button works well, unbound by default)
- All(/most) settings in MCM menu