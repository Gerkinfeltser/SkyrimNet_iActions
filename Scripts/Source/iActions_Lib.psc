; =============================================================================
; SkyrimNet iActions - Lib: Shared Library
; =============================================================================
Scriptname iActions_Lib extends Quest

; === Properties ===
Package Property iActions_Passout Auto
Package Property iActions_StopUsingFurniture Auto
Idle Property IdleiActSleep Auto
Idle Property IdleForceDefaultState Auto
; GlobalVariable Property TimeScale Auto

; === Local Variables ===
Bool VerboseLogging = True

; =========================================================
; --- Initialization/Update ---
; =========================================================

Event OnInit()
    LogAlert("iActions_Lib initialized...")
    SkyrimNetAPI.SetActionCooldown("StumbleAndFall", 8) ; 8 seconds cooldown (to prevent response loop spam)
EndEvent

; =========================================================
; --- Eligibility Check ---
; =========================================================

Int Function iAction_IsEligible(Actor akActor)
    If akActor == None || akActor.IsDead()
        return 1
    EndIf
    return 0
EndFunction

; =========================================================
; --- Various Execute Functions ---
; =========================================================

; === Stumble With Narration ===
Function StumbleStandalone_Execute(Actor akActor)
    If akActor && !akActor.IsDead()
        Stumble(akActor) ; Call the original stumble function
        
        ; Add DirectNarration for stumbling
        String npcName = akActor.GetDisplayName()
        String broadcastMsg
        
        Int random = Utility.RandomInt(0, 2)
        If random == 0
            broadcastMsg = npcName + " loses their balance."
        ElseIf random == 1  
            broadcastMsg = npcName + " trips and falls over."
        Else
            broadcastMsg = npcName + " stumbles."
        EndIf

        LogAlert(broadcastMsg, True, CoinFlip())
    EndIf
EndFunction

; === Extract Arrows ===
Function ClearExtraArrows_Execute(Actor akPincushion, Actor akSurgeon = None)
    If akPincushion
        string msg = akPincushion.GetDisplayName() + "'s arrows removed"
        akPincushion.ClearExtraArrows()
        If akSurgeon && !akSurgeon.IsDead() && akSurgeon != akPincushion
            msg = msg + " by " + akSurgeon.GetDisplayName()
        EndIf
        LogAlert(msg, True, True)
    EndIf
EndFunction

; =========================================================
; --- Helper Functions ---
; =========================================================

; === Stumble ===
Function Stumble(Actor akActor, float afForce=0.0)
    If akActor && !akActor.IsDead()
        akActor.PushActorAway(akActor, afForce)
    EndIf
EndFunction

; =========================================================
; --- Sleep / Pass Out Functions ---
; =========================================================

Function ApplyPassout(Actor akActor)
    ActorUtil.AddPackageOverride(akActor, iActions_Passout)
    akActor.EvaluatePackage()
EndFunction

Function RemovePassout(Actor akActor)
    ; Before RemovePassout
    LogAlert("Current package: " + akActor.GetCurrentPackage())

    ; Force interrupt current package behavior
    akActor.PlayIdle(IdleForceDefaultState)
    utility.wait(2)

    ; Remove the override
    ActorUtil.RemovePackageOverride(akActor, iActions_Passout)
    
    ; Force immediate re-evaluation
    akActor.EvaluatePackage()
    
    ; Redundant force-default in case package lingers
    akActor.PlayIdle(IdleForceDefaultState)

    ; After RemovePassout  
    LogAlert("Package after removal: " + akActor.GetCurrentPackage())
EndFunction

; =========================================================
; --- Utility Functions ---
; =========================================================

; === Log Trace & Notify ===
Function LogAlert(String sMessage="", Bool bNotifyInGame=False, Bool bUseDirectNarration=False, Bool bTraceLog=True)
    If bTraceLog
        Debug.Trace("[iAct] " + sMessage)
    EndIf
    If bNotifyInGame
        Debug.Notification(sMessage)
    EndIf
    If bUseDirectNarration
        SkyrimNetAPI.DirectNarration(sMessage) ; System selects speaker, addresses all
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

; === Coin Flip ===
bool Function CoinFlip()
    return Utility.RandomInt(0, 1) == 0
EndFunction

; Check if actor is using any furniture
Bool Function IsUsingFurniture(Actor akActor)
    Return akActor.GetFurnitureReference() != None
EndFunction

; Get the specific furniture they're using
ObjectReference Function GetCurrentFurniture(Actor akActor)
    Return akActor.GetFurnitureReference()
EndFunction

; === Stop Using Furniture so animations can play reliably ===
Function StopUsingFurniture(Actor akActor)
    If IsUsingFurniture(akActor)
        ActorUtil.AddPackageOverride(akActor, iActions_StopUsingFurniture)
        akActor.EvaluatePackage()
        utility.wait(0.5)
        ActorUtil.RemovePackageOverride(akActor, iActions_StopUsingFurniture)
        akActor.EvaluatePackage()
    EndIf
EndFunction

Function Debug_GetCurrentPackage(Actor akActor)
    Package pkg = akActor.GetCurrentPackage()
    If pkg
        Int formID = pkg.GetFormID()
        ; Or use Trace for auto hex formatting
        LogAlert(" CurrentPackage FormID: " + formID)
    EndIf
EndFunction