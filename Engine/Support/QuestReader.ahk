; ================================================================
;  QuestReader.ahk  —  engine\support\
;
;  Uses RapidOCR (PaddleOCR-based) for reliable game-font reading.
;  Supports any resolution — no window resize needed.
;  All coordinates scale proportionally from 800×600 reference.
; ================================================================

#Include ..\..\lib\Pin.ahk
#Include ..\..\lib\TextRender.ahk

; ── 800×600 reference coordinates (from RankQuests Coords.ahk) ──
global BASE_W := 800, BASE_H := 600

global QUEST_OCR_BASE_X := 128    ; left edge of quest text panel
global QUEST_OCR_BASE_Y := 270    ; 7px above Quest1 (y=277)
global QUEST_OCR_BASE_W := 200    ; captures full quest name
global QUEST_OCR_BASE_H := 160    ; covers all 4 slots + margin

; Quest slot y-bands at 800×600 (relative to client top-left)
; Each slot spans 34px; these ranges include a little padding
global QUEST_BANDS_800 := [[277, 312], [313, 346], [347, 380], [381, 425]]

global OCR_DEBUG := true   ; true → yellow outline + raw text overlay

; ----------------------------------------------------------------
;  GetRobloxGeometry(hWnd)
;  Returns {cx, cy, cw, ch, sx, sy} for the Roblox window.
;  sx/sy are scale factors from 800×600 reference to actual size.
; ----------------------------------------------------------------
GetRobloxGeometry(hWnd) {
    WinGetClientPos(&cx, &cy, &cw, &ch, "ahk_id " hWnd)
    return {cx: cx, cy: cy, cw: cw, ch: ch,
            sx: cw / BASE_W, sy: ch / BASE_H}
}

; ----------------------------------------------------------------
;  ReadAllQuestSlots(hWnd)  → Array[4] of raw strings
; ----------------------------------------------------------------
ReadAllQuestSlots(hWnd) {
    result := ["", "", "", ""]

    try {
        g := GetRobloxGeometry(hWnd)
    } catch {
        return result
    }

    ; ── OCR rect in absolute screen coords ──────────────────────
    ocrX := g.cx + Round(QUEST_OCR_BASE_X * g.sx)
    ocrY := g.cy + Round(QUEST_OCR_BASE_Y * g.sy)
    ocrW := Round(QUEST_OCR_BASE_W * g.sx)
    ocrH := Round(QUEST_OCR_BASE_H * g.sy)

    if OCR_DEBUG
        try Pin(ocrX, ocrY, ocrX + ocrW, ocrY + ocrH, 3000, "b2 cYellow flash0")

    try {
        ocrObj := RapidOcr.FromRect(ocrX, ocrY, ocrW, ocrH)
    } catch {
        return result
    }

    if !ocrObj || !ocrObj.Lines.Length
        return result

    if OCR_DEBUG
        try TextRender(ocrObj.text, "x" (ocrX + ocrW + 5) " y" ocrY " w400 t4000 s11")

    ; ── Slot y-bands scaled to actual screen coords ──────────────
    ; RapidOcr.FromRect returns line.y in absolute screen coords
    ; (it adds orgY internally), so compare against cy + scaled_y.
    bands := []
    for _, b in QUEST_BANDS_800
        bands.Push([g.cy + Round(b[1] * g.sy),
                    g.cy + Round(b[2] * g.sy)])

    ; ── Assign each OCR line to a slot by y-position ────────────
    ; This is immune to: case, star icons, cross-slot merging.
    slotText := ["", "", "", ""]
    for _, line in ocrObj.Lines {
        txt := Trim(line.text)
        if !RegExMatch(txt, "[a-zA-Z]{2,}")   ; skip pure symbols/numbers
            continue
        ly := line.y
        Loop 4 {
            b := bands[A_Index]
            if ly >= b[1] && ly <= b[2] {
                slotText[A_Index] .= (slotText[A_Index] = "" ? "" : " ") txt
                break
            }
        }
    }

    ; ── Clean and normalise each slot ───────────────────────────
    Loop 4
        result[A_Index] := NormalizeOCRText(Trim(slotText[A_Index]))

    return result
}

; ----------------------------------------------------------------
;  NormalizeOCRText — fix known PS99 FredokaOne font misreads
; ----------------------------------------------------------------
NormalizeOCRText(text) {
    text := RegExReplace(text, "i)breake?b[a-z]*", "breakables")
    text := RegExReplace(text, "i)&mond|diam[o0]nd",  "diamond")
    text := RegExReplace(text, "i)su[^p]?[^e]?r",     "superior")
    text := RegExReplace(text, "i)\bni[nm]i\b",        "mini")
    text := RegExReplace(text, "i)\b[sc]t\s+area\b",   "best area")
    text := RegExReplace(text, "i)\bcorne[rt]\b",       "comet")
    return text
}

; ----------------------------------------------------------------
;  ExtractAmount
; ----------------------------------------------------------------
ExtractAmount(ocrText) {
    ocrText := RegExReplace(ocrText, "27 SO", "2750")
    ocrText := RegExReplace(ocrText, "\bS\b",  "5")
    ocrText := RegExReplace(ocrText, "\bSO\b", "50")
    ocrText := RegExReplace(ocrText, "\bSS\b", "55")

    if RegExMatch(ocrText, "\(x(\d+)\)", &m)
        return Integer(m[1])

    if RegExMatch(ocrText, "(\b\d+(?:\.\d+)?)[kK]\b", &m)
        return Round(Float(m[1]) * 1000)

    if RegExMatch(ocrText, "\b(\d[\d,]*)\b", &m)
        return Integer(StrReplace(m[1], ",", ""))

    return 1
}
