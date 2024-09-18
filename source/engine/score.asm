INCLUDE "includes/includes.inc"


SECTION "Score Functions", ROM0

_LoadHighScore::
    ld hl, sHighScore
    ld bc, 2
    ld de, wHighScore
    jp _LoadFromSRAM


_SaveHighScore::
    ld hl, wHighScore
    ld bc, 2
    ld de, sHighScore
    jp _SaveToSRAM


_ClearCurrentScore::
    ld hl, wCurrentScore
    xor a
    ld [hl+], a
    ld [hl], a
    ld [wCurrentLevel], a
    ld a, 3
    ld [wCurrentBalls], a
    ld a, 36
    ld [wBricksRemaining], a
    ret


_IncrementCurrentLevel::
    ld a, 36
    ld [wBricksRemaining], a

    ld hl, wCurrentLevel
    inc [hl]
    ret


_GetCurrentLevel::
    ld a, [wCurrentLevel]
    and a
    ret


_DecrementCurrentBalls::
    ld hl, wCurrentBalls
    dec [hl]
    ld a, [hl]
    and a
    ret


_AddToCurrentScore::
    ld b, a
    ld c, 2
    ld hl, wCurrentScore
    call _AddToBCDNumber

    ld hl, wBricksRemaining
    dec [hl]
    ret


_GetBricksRemaining::
    ld a, [wBricksRemaining]
    and a
    ret


_PrintCurrentScore::
    ld hl, wCurrentScore+1
    ld de, wCurrentScoreTileBuffer
    ld b, 2

.loop:
    ld a, [hl]
    and a, %1111_0000
    swap a
    add a, "0"
    ld [de], a
    inc de

    ld a, [hl-]
    and a, %0000_1111
    add a, "0"
    ld [de], a
    inc de

    dec b
    jr nz, .loop

    xor a
    ld hl, wCurrentScoreTileBuffer
    ld b, 4
    ld de, vSCRN0.y10x15
    jp _VideoMemCopyFast


_PrintHighScore::
    ld hl, wHighScore+1
    ld de, wHighScoreTileBuffer
    ld b, 2

.loop:
    ld a, [hl]
    and a, %1111_0000
    swap a
    add a, "0"
    ld [de], a
    inc de

    ld a, [hl-]
    and a, %0000_1111
    add a, "0"
    ld [de], a
    inc de

    dec b
    jr nz, .loop

    xor a
    ld hl, wHighScoreTileBuffer
    ld b, 4
    ld de, vSCRN0.y2x15
    jp _VideoMemCopyFast


_PrintCurrentLevel::
    ld hl, wCurrentLevel
    ld de, wCurrentLevelTileBuffer

    ld a, [hl]
    and a, %1111_0000
    swap a
    add a, "0"
    ld [de], a
    inc de

    ld a, [hl]
    and a, %0000_1111
    add a, "0"
    ld [de], a
    inc de

    xor a
    ld hl, wCurrentLevelTileBuffer
    ld b, 2
    ld de, vSCRN0.y6x17
    jp _VideoMemCopyFast


_PrintCurrentBalls::
    ld a, [wCurrentBalls]
    dec a
    add a, "0"
    ld d, a

    xor a
    ld hl, vSCRN0.y14x18
    ld b, 1
    jp _VideoMemSetFast


ENDSECTION


SECTION "Score Variables", WRAM0

wBricksRemaining:
    DS 1

wCurrentBalls:
    DS 1

wCurrentLevel:
    DS 1

wCurrentLevelTileBuffer:
    DS 2

wCurrentScore:
    DS 2

wCurrentScoreTileBuffer:
    DS 4

wHighScore:
    DS 2

wHighScoreTileBuffer:
    DS 4

ENDSECTION


SECTION "Save Data", SRAM

sHighScore:
    DW

ENDSECTION
