; =============================================================================
; SkyrimNet iActions - Drunk State System
; dev0.0.2 (2025-10-09)
; =============================================================================
Scriptname SkyrimNet_iActions_DrunkSystem extends Quest
Import ActorUtil
Import PO3_SKSEFunctions

; Properties
Faction Property DrunkFaction Auto
Idle Property IdleDrunkStart Auto
Idle Property IdleDrunkStop Auto
Idle Property IdleStop_Loose Auto
Idle Property IdleForceDefaultState Auto
Idle Property IdleDrink Auto
Idle Property IdleWipeBrow Auto

; Local Properties
Bool VerboseLogging = True
Bool UseFaction = True
Bool AllowStumble = True
Bool DrunkIdleHack = False

; =========================================================
; Initialization - game load
; =========================================================
Event OnInit()
    LogAlert("SkyrimNet_iActions_DrunkSystem initialized...")
EndEvent

; =========================================================
; --- Eligibility Check ---
; =========================================================

Int Function SetDrunkState_IsEligible(Actor akNPC)
    ; TODO: Sober Ineligible if Not Drunk
    If akNPC == None || akNPC.IsDead()
        return 1
    EndIf
    return 0
EndFunction

; =========================================================
; --- Execution ---
; =========================================================

Function SetDrunkState_Execute(Actor akNPC, Bool abIsDrunk)
    SetActorDrunkState(akNPC, abIsDrunk)
    return
EndFunction

; =========================================================
; --- Core Implementation ---
; =========================================================

Function SetActorDrunkState(Actor akNPC, Bool abIsDrunk)
    If akNPC == None || akNPC.IsDead()
        return
    EndIf
    
    If abIsDrunk
        MakeActorDrunk(akNPC)
    Else
        MakeActorSober(akNPC)
    EndIf
EndFunction

; === Make Drunk ===
Function MakeActorDrunk(Actor akNPC)
    string npcName = akNPC.GetDisplayName()
    int drunkRank = SetDrunkFactionMembership(akNPC, True)
    string drunkLevel = GetDrunkLevel(akNPC)
    ; PlayAnim(akNPC, true) ; Play drinking animation
    ; === Cause stumble if high drunk ranked ===
    If AllowStumble ; && drunkRank > 0
        Game.GetPlayer().PushActorAway(akNPC, 1.5)
        LogAlert(npcName + " stumbles, now " + drunkLevel, True)
    Else
        LogAlert(npcName + " is now " + drunkLevel, True)
    EndIf
    akNPC.EvaluatePackage()
    If DrunkIdleHack
        idleHack(akNPC)
    EndIf
EndFunction

; === Make Sober ===
Function MakeActorSober(Actor akNPC)
    If DrunkIdleHack
        akNPC.PlayIdle(IdleDrunkStop)
    EndIf
    SetDrunkFactionMembership(akNPC, False)
    PlayAnim(akNPC, false) ; Play brow wiping animation
    LogAlert(akNPC.GetDisplayName() + " is sobering up", True)
    Utility.wait(3)
    akNPC.EvaluatePackage()
EndFunction

; =========================================================
; --- Sub Functions ---
; =========================================================

; === Set Faction & Rank ===
int Function SetDrunkFactionMembership(Actor akNPC, Bool bShouldJoin)
    If !UseFaction || DrunkFaction == None
        LogAlert("Drunk Faction unavailable.")
        return -100
    ElseIf akNPC == None
        LogAlert("Attempted to modify None actor.")
        return -100
    ElseIf akNPC.IsDead()
        LogAlert("Attempted to modify dead actor: " + akNPC.GetDisplayName())
        return -100
    EndIf
    If DrunkFaction && UseFaction
        If bShouldJoin && akNPC.IsInFaction(DrunkFaction)
            akNPC.SetFactionRank(DrunkFaction, Min(akNPC.GetFactionRank(DrunkFaction) + 1, 3))
        ElseIf bShouldJoin
            akNPC.AddToFaction(DrunkFaction)
            akNPC.SetFactionRank(DrunkFaction, 0)
        ElseIf akNPC.IsInFaction(DrunkFaction)
            akNPC.RemoveFromFaction(DrunkFaction)
        EndIf
    EndIf
    return akNPC.GetFactionRank(DrunkFaction)
EndFunction

; === Classify Drunk ===
String Function GetDrunkLevel(Actor akNPC)
    If !UseFaction || DrunkFaction == None
        return "unknown"
    EndIf
    ; Sober:-2, Tipsy:0, Drunk:1, Black-out Drunk:2, Unconscious:3
    Int level = akNPC.GetFactionRank(DrunkFaction)
    if level < 0
        return "sober"
    ElseIf level == 0
        return "tipsy"
    ElseIf level == 1
        return "drunk"
    ElseIf level == 2
        return "plastered"
    ElseIf level >= 3
        return "black-out drunk" ; TODO
    Else 
        return "unknown"
    EndIf
EndFunction

; === PlayAnimation ===
Function PlayAnim(Actor akNPC, Bool abGetDrunk)
    Idle _idle
    If abGetDrunk
        _idle = IdleDrink
    Else
        _idle = IdleWipeBrow
    endif
    akNPC.PlayIdle(IdleStop_Loose) ; IdleForceDefaultState)
    utility.wait(2)
    akNPC.PlayIdle(_idle)
EndFunction

; === Idle Hack for the OAR-less ===
Function idleHack(Actor akNPC, Int maxRetryCount=3)
    If akNPC == None
        LogAlert("IdleHack skipped: None actor.")
        return
    EndIf
    akNPC.PlayIdle(IdleStop_Loose)
    Utility.Wait(0.5)
    Int retryCount = 0
    Bool result = akNPC.PlayIdle(IdleDrunkStart)
    String npcName = akNPC.GetDisplayName()
    While !result && retryCount < maxRetryCount
        Utility.Wait(0.5)
        akNPC.PlayIdle(IdleStop_Loose)
        Utility.Wait(0.5)
        retryCount += 1
        result = akNPC.PlayIdle(IdleDrunkStart)
        LogAlert(npcName + " IdleDrunkStart attempt " + retryCount)
    EndWhile
    akNPC.EvaluatePackage() ; May break drunk animation (has not been verified functional)
EndFunction

; =========================================================
; --- Utility Functions ---
; =========================================================

; === Log Trace & Notify ===
Function LogAlert(String sMessage="", Bool bNotifyInGame=False)
    If VerboseLogging
        Debug.Trace("[iAct] " + sMessage)
        If bNotifyInGame
            Debug.Notification(sMessage)
        EndIf
    EndIf
EndFunction

; === Math: Min ===
int Function Min(int a, int b)
    if a < b
        return a
    else
        return b
    endif
EndFunction
