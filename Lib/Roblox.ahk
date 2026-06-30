; ================================================================
;  Roblox.ahk — Window helpers for any Roblox game
;  Adapted from HiveHub by Killericboy
; ================================================================

global windowX := 0, windowY := 0, windowWidth := 0, windowHeight := 0

GetRobloxHWND() {
    if (hwnd := WinExist("ahk_exe RobloxPlayerBeta.exe"))
        return hwnd
    if WinExist("Roblox ahk_exe ApplicationFrameHost.exe") {
        try hwnd := ControlGetHwnd("ApplicationFrameInputSinkWindow1")
        catch TargetError
            hwnd := 0
        return hwnd
    }
    return 0
}

GetRobloxClientPos(hwnd?) {
    global windowX, windowY, windowWidth, windowHeight
    if !IsSet(hwnd)
        hwnd := GetRobloxHWND()
    try
        WinGetClientPos &windowX, &windowY, &windowWidth, &windowHeight, "ahk_id " hwnd
    catch TargetError
        return windowX := windowY := windowWidth := windowHeight := 0
    return 1
}

ActivateRoblox() {
    try WinActivate "Roblox"
    catch
        return 0
    return 1
}
