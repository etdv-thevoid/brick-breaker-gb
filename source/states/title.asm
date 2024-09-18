INCLUDE "includes/includes.inc"


SECTION "Title State Functions", ROMX

xTitle::
    ld hl, wShadowOAM
    ld b, (OAM_COUNT * 4)
    xor a
    call _MemSetFast
    
    ; Load Tilemap
    ld hl, xTitleStateTilemap
    call _LoadTilemapSCRN0

    ; Load Attrmap
    ld hl, xTitleStateAttrmap
    call _LoadAttrmapSCRN0

    ld a, LCDC_DEFAULT
    call _ScreenOn
    ; fallthrough

xTitleStateLoop:
    call _WaitForVBLInterrupt

    ldh a, [hKeysPressed]
    and a, PADF_START
    ld a, MAIN_STATE_GAME
    jp nz, _MainStateNew

    ld hl, wTitleStateFrameCounter
    inc [hl]
    ld a, [wTitleStateBlinkFlag]
    and a
    ld a, %0011_1111
    jr z, .blinkOFF
    ld a, %0000_0111

.blinkON:
    and a, [hl]
    jr nz, .done

    ld a, FALSE
    ld [wTitleStateBlinkFlag], a

    xor a
    ld hl, xTitleStatePressSTARTString
    ld b, (xTitleStatePressSTARTString.end - xTitleStatePressSTARTString)
    ld de, vSCRN0.y10x4
    call _VideoMemCopyFast
    jr .done

.blinkOFF:
    and a, [hl]
    jr nz, .done

    ld a, TRUE
    ld [wTitleStateBlinkFlag], a
    
    xor a
    ld hl, vSCRN0.y10x4
    ld b, (xTitleStatePressSTARTString.end - xTitleStatePressSTARTString)
    ld d, " "
    call _VideoMemSetFast
    jr .done

.done: 
    jr xTitleStateLoop


xTitleStatePressSTARTString:
    DB "Press START!"
.end:

xTitleStateTilemap:
    INCBIN "assets/tilemaps/title_tilemap.rle"
.end:

xTitleStateAttrmap:
    INCBIN "assets/tilemaps/title_attrmap.rle"
.end:   

ENDSECTION


SECTION "Title State Variables", WRAM0

wTitleStateFrameCounter:
    DB

wTitleStateBlinkFlag:
    DB

ENDSECTION
