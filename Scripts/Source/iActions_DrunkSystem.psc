; =============================================================================
; SkyrimNet iActions - Drunk State System
; =============================================================================
Scriptname iActions_DrunkSystem extends Quest
Import ActorUtil
Import StorageUtil
Import PO3_SKSEFunctions

; Properties
iActions_Lib Property Lib Auto
FormList Property iActions_AlcoholList Auto

; Animation Properties
Idle Property IdleDrunkStart Auto
Idle Property IdleDrunkStop Auto
Idle Property IdleStop_Loose Auto
Idle Property IdleForceDefaultState Auto
Idle Property IdleDrink Auto
Idle Property IdleWipeBrow Auto

; Faction/Storage Configuration
Bool Property UseFaction = True Auto
Faction Property DrunkFaction Auto
String Property MemberStorageKey = "iActions_DrunkMembers" AutoReadOnly

; Drunk Level Configuration
Int Property PointsPerLevel = 2 Auto ; How many rank points per drunk level (2 = ranks 0-1 tipsy, 2-3 drunk, etc.)
Int Property PointsPerDrink = 2 Auto ; How many points added per drink (except for first drink, which sets to rank 0)
Int Property PointsPerDecay = 1 Auto ; How many points reduced per poll cycle
Int Property MaxDrunkLevel = 3 Auto  ; Maximum drunk category (0=tipsy, 1=drunk, 2=plastered, 3=blackout)
Float Property MemberPollRate = 300.0 Auto ; How often polling occurs (300 = every 5 min)

; Drunk Category Constants
Int Property DrunkCategory_Sober = -1 AutoReadOnly
Int Property DrunkCategory_Tipsy = 0 AutoReadOnly
Int Property DrunkCategory_Drunk = 1 AutoReadOnly
Int Property DrunkCategory_Plastered = 2 AutoReadOnly
Int Property DrunkCategory_Blackout = 3 AutoReadOnly

; Debug/QOL Properties
Bool Property AllowStumble = True Auto
Bool Property RequireAlcohol = True Auto

; =========================================================
; --- Initialization/Update ---
; =========================================================

Event OnInit()
    Lib.LogAlert("iActions_DrunkSystem initialized...")
    Lib.LogAlert("Polling Drunks every " + MemberPollRate + " seconds.")
    Lib.LogAlert("Config: " + PointsPerLevel + " points/level, " + PointsPerDrink + " points/drink, -" + PointsPerDecay + " decay/poll")
    SkyrimNetAPI.SetActionCooldown("DrinkBooze", 8) ; Prevent Drink spamming
    RegisterForSingleUpdate(10.0) ; Start pruning loop
EndEvent

Event OnUpdate()
    ScanAndFixOrphanedDrunks() ; Initial scan to fix any orphaned drunks
    Utility.Wait(1.0)
    SoberUpDrunkMembers() ; Decay drunk ranks
    Lib.LogAlert("All drunk members rank have been reduced by " + PointsPerDecay + " this cycle")
    ListDrunkMembers()
    PruneInvalidMembers()
    RegisterForSingleUpdate(MemberPollRate) ; Re-register for next cycle
EndEvent

; =========================================================
; --- Eligibility Check ---
; =========================================================

Int Function SetDrunkState_IsEligible(Actor akActor)
    If akActor == None || akActor.IsDead()
        return 1
    EndIf
    return 0
EndFunction

; =========================================================
; --- Execution ---
; =========================================================

Function SetDrunkState_Execute(Actor akActor, Bool abIsDrunk)
    SetActorDrunkState(akActor, abIsDrunk)
EndFunction

; =========================================================
; --- Core Implementation ---
; =========================================================

; === Main Drunk State Setter ===
Function SetActorDrunkState(Actor akActor, Bool abIsDrunk)
    If akActor == None || akActor.IsDead()
        return
    EndIf
    
    If abIsDrunk
        MakeActorDrunk(akActor)
    Else
        MakeActorSober(akActor)
    EndIf
EndFunction

; === Make Drunk ===
Function MakeActorDrunk(Actor akActor)
    string npcName = akActor.GetDisplayName()

    ; See how many drinks they have
    int drinks = akActor.GetItemCount(iActions_AlcoholList)
    If drinks > 0 || !RequireAlcohol
        ; Get a drink item from their inventory
        Form drink = GetAlcoholItem(akActor) as Form ; Potion type *should* also work

        int drunkRank = SetDrunkFactionMembership(akActor, True)
        string drunkLevel = GetDrunkLevel(akActor)

        PlayAnim(akActor, true) ; Play drinking animation
        If drink && RequireAlcohol
            ; string drinkName = drink.GetName() ; Not used currently
            akActor.EquipItem(drink, False, False) ; abPreventRemoval=False, abSilent=false
        EndIf
        string drinkMsg = npcName + " drinks. They are now " + drunkLevel
        If RequireAlcohol
            drinkMsg += " (" + (drinks - 1) + " left)"
        EndIf
        
        ; === Cause stumble if blackout drunk ===
        Int category = GetDrunkCategory(akActor)
        If AllowStumble && category >= DrunkCategory_Blackout
            Lib.Stumble(akActor, 0.0)
            drinkMsg += " and stumbles around!"
            Lib.LogAlert(drinkMsg, True, Lib.CoinFlip())
        Else
            Lib.LogAlert(drinkMsg, True, Lib.CoinFlip())
        EndIf

        akActor.EvaluatePackage()
    Else
        Lib.LogAlert(npcName + " has no alcohol to drink!", True, True)
    EndIf
    
EndFunction

Form Function GetAlcoholItem(Actor akActor)
    Int numItems = akActor.GetNumItems()
    Int i = 0
    
    While i < numItems
        Form item = akActor.GetNthForm(i)
        
        If iActions_AlcoholList.HasForm(item) && akActor.GetItemCount(item) > 0
            Return item
        EndIf
        
        i += 1
    EndWhile
    Return None
EndFunction

; === Make Sober ===
Function MakeActorSober(Actor akActor)
    SetDrunkFactionMembership(akActor, False)
    PlayAnim(akActor, false) ; Play brow wiping animation
    Lib.LogAlert(akActor.GetDisplayName() + " is sobering up", True, Lib.CoinFlip())
    akActor.EvaluatePackage()
EndFunction

; =========================================================
; --- Faction/Rank Functions ---
; =========================================================

; === Set Faction & Rank ===
int Function SetDrunkFactionMembership(Actor akActor, Bool bShouldJoin)
    If !UseFaction || DrunkFaction == None
        Lib.LogAlert("Drunk Faction unavailable.")
        return -100
    ElseIf akActor == None
        Lib.LogAlert("Attempted to modify None actor.")
        return -100
    ElseIf akActor.IsDead()
        Lib.LogAlert("Attempted to modify dead actor: " + akActor.GetDisplayName())
        return -100
    EndIf
    
    If DrunkFaction && UseFaction
        If bShouldJoin && akActor.IsInFaction(DrunkFaction)
            ; Already drunk - add points per drink (capped at max)
            Int currentRank = akActor.GetFactionRank(DrunkFaction)
            Int maxRank = GetMaxDrunkRank()
            Int newRank = Lib.Min(currentRank + PointsPerDrink, maxRank)
            akActor.SetFactionRank(DrunkFaction, newRank)
        ElseIf bShouldJoin
            ; First drink - join faction at rank 0 (tipsy minimum)
            akActor.AddToFaction(DrunkFaction)
            akActor.SetFactionRank(DrunkFaction, 0) ; Start at rank 0 (level 0 = tipsy)
            TrackDrunkMember(akActor)
        ElseIf akActor.IsInFaction(DrunkFaction)
            ; Manual sobering up
            akActor.RemoveFromFaction(DrunkFaction)
            UntrackDrunkMember(akActor)
        EndIf
    EndIf
    
    akActor.EvaluatePackage()
    return akActor.GetFactionRank(DrunkFaction)
EndFunction

; =========================================================
; --- Drunk Level Calculation Functions ---
; =========================================================

; === Calculate maximum possible drunk rank ===
Int Function GetMaxDrunkRank()
    return (MaxDrunkLevel + 1) * PointsPerLevel - 1
EndFunction

; === Get drunk category (0=tipsy, 1=drunk, 2=plastered, 3=blackout, -1=sober) ===
Int Function GetDrunkCategory(Actor akActor)
    If !UseFaction || DrunkFaction == None || !akActor
        return DrunkCategory_Sober
    EndIf
    
    Int rank = akActor.GetFactionRank(DrunkFaction)
    If rank < 0
        return DrunkCategory_Sober
    EndIf
    
    return rank / PointsPerLevel
EndFunction

; === Get sub-level within category (0 to PointsPerLevel-1) ===
Int Function GetDrunkSubLevel(Actor akActor)
    If !UseFaction || DrunkFaction == None || !akActor
        return -1
    EndIf
    
    Int rank = akActor.GetFactionRank(DrunkFaction)
    If rank < 0
        return -1
    EndIf
    
    return rank % PointsPerLevel
EndFunction

; === Get drunk level as string ===
String Function GetDrunkLevel(Actor akActor)
    If !UseFaction || DrunkFaction == None
        return "unknown"
    EndIf
    
    Int rank = akActor.GetFactionRank(DrunkFaction)
    return GetDrunkLevelFromRank(rank)
EndFunction

; === Helper: Get drunk level from rank value ===
String Function GetDrunkLevelFromRank(Int rank)
    If rank < 0
        return "sober"
    EndIf
    
    Int category = rank / PointsPerLevel
    
    If category == DrunkCategory_Tipsy
        return "tipsy"
    ElseIf category == DrunkCategory_Drunk
        return "drunk"
    ElseIf category == DrunkCategory_Plastered
        return "plastered"
    ElseIf category >= DrunkCategory_Blackout
        return "black-out drunk"
    Else 
        return "unknown"
    EndIf
EndFunction

; === Get numeric drunk rank for external use ===
Int Function GetDrunkRank(Actor akActor)
    If !UseFaction || DrunkFaction == None || !akActor || !akActor.IsInFaction(DrunkFaction)
        return -2 ; Faction removal value
    EndIf
    return akActor.GetFactionRank(DrunkFaction)
EndFunction

; =========================================================
; --- Drunk Faction Tracking ---
; =========================================================

; === Add NPC to Drunk Member List ===
Function TrackDrunkMember(Actor akActor)
    If akActor && StorageUtil.FormListFind(Self, MemberStorageKey, akActor) == -1
        StorageUtil.FormListAdd(Self, MemberStorageKey, akActor)
    EndIf
EndFunction

; === Remove NPC from Drunk Member List ===
Function UntrackDrunkMember(Actor akActor)
    If akActor
        Int index = StorageUtil.FormListFind(Self, MemberStorageKey, akActor)
        If index != -1
            StorageUtil.FormListRemoveAt(Self, MemberStorageKey, index)
        EndIf
    EndIf
EndFunction

; === Sober Up All Drunk Members (Decay System) ===
Function SoberUpDrunkMembers()
    Int count = StorageUtil.FormListCount(Self, MemberStorageKey)
    
    If count == 0
        return
    EndIf
    
    ; Iterate backwards to safely handle list modifications
    Int i = count
    Int soberedUp = 0
    
    While i > 0
        i -= 1
        Actor member = StorageUtil.FormListGet(Self, MemberStorageKey, i) as Actor
        
        If member && !member.IsDead() && member.IsInFaction(DrunkFaction)
            Int currentRank = member.GetFactionRank(DrunkFaction)
            Int newRank = currentRank - PointsPerDecay
            
            If newRank < 0
                ; Remove from faction when below 0
                member.RemoveFromFaction(DrunkFaction)
                UntrackDrunkMember(member)
                member.EvaluatePackage()
                soberedUp += 1
                Lib.LogAlert(member.GetDisplayName() + " has sobered up completely", True, False)
            Else
                ; Reduce rank by decay amount
                member.SetFactionRank(DrunkFaction, newRank)
                String oldLevel = GetDrunkLevelFromRank(currentRank)
                String newLevel = GetDrunkLevelFromRank(newRank)
                
                ; Only log if they changed drunk categories
                If oldLevel != newLevel
                    Lib.LogAlert(member.GetDisplayName() + " is now " + newLevel + " (was " + oldLevel + ")", False, False)
                EndIf
            EndIf
        EndIf
    EndWhile
    
    If soberedUp > 0
        Lib.LogAlert(soberedUp + " NPCs sobered up this cycle")
    EndIf
EndFunction

; === Clear Drunk Member List (Debug/Emergency) ===
Function _ClearAllDrunkMembersNotify()
    ClearAllDrunkMembers(True)
EndFunction

Function ClearAllDrunkMembers(Bool abNotify = False)
    Int count = StorageUtil.FormListCount(Self, MemberStorageKey)
    If count == 0
        Lib.LogAlert("No drunk members to clear", abNotify)
        return
    EndIf
    
    ; Remove all actors from faction with package reset
    Int i = count
    While i > 0
        i -= 1
        Actor member = StorageUtil.FormListGet(Self, MemberStorageKey, i) as Actor
        If member && member.IsInFaction(DrunkFaction)
            member.RemoveFromFaction(DrunkFaction)
            member.EvaluatePackage() ; Added - ensures AI refreshes
        EndIf
    EndWhile
    
    ; Clear the tracking list
    StorageUtil.FormListClear(Self, MemberStorageKey)
    Lib.LogAlert("Cleared " + count + " drunk NPCs", abNotify)
EndFunction

; === Prepare for Mod Uninstallation ===
Function _PrepareForUninstall()
    Lib.LogAlert("iActions: Beginning uninstall cleanup...", True)
    
    ; Use shared cleanup logic
    ClearAllDrunkMembers(False) ; Don't double-notify
    
    ; Additional uninstall-only steps
    StorageUtil.ClearAllPrefix(Self) ; Remove ALL StorageUtil data for this quest
    UnregisterForUpdate() ; Stop polling loop
    
    Lib.LogAlert("iActions: Uninstall cleanup complete. Safe to disable mod.", True)
EndFunction

; === Clear Invalid/Sober Members ===
Function PruneInvalidMembers()
    Int count = StorageUtil.FormListCount(Self, MemberStorageKey)
    If count == 0
        return
    EndIf
    
    Int i = count
    Int pruned = 0
    
    While i > 0
        i -= 1
        Actor member = StorageUtil.FormListGet(Self, MemberStorageKey, i) as Actor
        
        ; Remove invalid, dead, or no-longer-drunk members
        If !member || member.IsDead() || member.GetFactionRank(DrunkFaction) < 0
            StorageUtil.FormListRemoveAt(Self, MemberStorageKey, i)
            pruned += 1
        EndIf
    EndWhile
    
    If pruned > 0
        Lib.LogAlert("Pruned " + pruned + " dead/invalid/sober drunks")
    EndIf
EndFunction

; === List All Drunk Members (Debug) ===
Function _ListDrunkMembersNotify()
    ListDrunkMembers(True)
EndFunction

Function ListDrunkMembers(Bool abNotify = False)
    Int count = StorageUtil.FormListCount(Self, MemberStorageKey)
    
    If count == 0
        Lib.LogAlert("No drunk members found", abNotify)
        return
    EndIf
    
    ; Build the header
    String output = count + " Characters are currently inebriated:\n"
    
    ; Build the list
    Int i = 0
    While i < count
        Actor member = StorageUtil.FormListGet(Self, MemberStorageKey, i) as Actor
        If member
            String drunkLevel = GetDrunkLevel(member)
            output += "- " + member.GetDisplayName() + ": " + drunkLevel + " (" + member.GetFactionRank(DrunkFaction) + ")"
            
            ; Add status indicator if dead/unloaded (optional)
            If member.IsDead()
                output += " [DEAD]"
            ElseIf !member.Is3DLoaded()
                output += " [UNLOADED]"
            EndIf
            
            ; Add newline if not last item
            If i < count - 1
                output += "\n"
            EndIf
        Else
            output += "- <INVALID>"
            If i < count - 1
                output += "\n"
            EndIf
        EndIf
        i += 1
    EndWhile
    
    Lib.LogAlert(output, abNotify)
EndFunction

; === Find and Fix Orphaned Drunk NPCs ===
Function _ScanAndFixOrphanedDrunksNotify()
    ScanAndFixOrphanedDrunks(True)
EndFunction

Function ScanAndFixOrphanedDrunks(Bool akNotify = False)
    Lib.LogAlert("Scanning for orphaned drunk NPCs...", akNotify)

    Int fixed = 0
    Int removed = 0
    
    ; Get all actors in the loaded area
    Cell currentCell = Game.GetPlayer().GetParentCell()
    Int numRefs = currentCell.GetNumRefs(43) ; 43 = kNPC formtype
    
    Int i = 0
    While i < numRefs
        Actor akActor = currentCell.GetNthRef(i, 43) as Actor
        
        If akActor && !akActor.IsDead()
            ; Check if they're in faction but not tracked
            If akActor.IsInFaction(DrunkFaction)
                Int index = StorageUtil.FormListFind(Self, MemberStorageKey, akActor)
                If index == -1
                    ; Found orphaned drunk - add to tracking
                    TrackDrunkMember(akActor)
                    fixed += 1
                    Lib.LogAlert("Fixed orphaned drunk: " + akActor.GetDisplayName() + " (Rank " + akActor.GetFactionRank(DrunkFaction) + ")", akNotify)
                EndIf
            EndIf
        EndIf
        
        i += 1
    EndWhile
    
    Lib.LogAlert("Scan complete. Fixed: " + fixed + ", Removed: " + removed, akNotify)
EndFunction

; === Nuclear Option: Remove ALL actors from faction (even untracked) ===
Function ForceRemoveAllFromFaction()
    Lib.LogAlert("Force-removing ALL actors from drunk faction...", True)

    Int removed = 0
    
    ; Scan loaded cells
    Cell currentCell = Game.GetPlayer().GetParentCell()
    Int numRefs = currentCell.GetNumRefs(43)
    
    Int i = 0
    While i < numRefs
        Actor akActor = currentCell.GetNthRef(i, 43) as Actor
        
        If akActor && akActor.IsInFaction(DrunkFaction)
            akActor.RemoveFromFaction(DrunkFaction)
            akActor.EvaluatePackage()
            StorageUtil.UnsetFloatValue(akActor, "iActions_LastDrinkTime")
            removed += 1
        EndIf
        
        i += 1
    EndWhile
    
    ; Also clear the tracking list
    StorageUtil.FormListClear(Self, MemberStorageKey)

    Lib.LogAlert("Force-removed " + removed + " actors from faction", True)
EndFunction

; =========================================================
; --- Animation Utils ---
; =========================================================

; === PlayAnimation ===
Function PlayAnim(Actor akActor, Bool abGetDrunk)
    Lib.StopUsingFurniture(akActor) ; Ensure they're not using furniture
    Idle _idle
    If abGetDrunk
        _idle = IdleDrink
    Else
        _idle = IdleWipeBrow
    endif
    akActor.PlayIdle(IdleForceDefaultState)
    utility.wait(2)
    akActor.PlayIdle(_idle)
EndFunction
