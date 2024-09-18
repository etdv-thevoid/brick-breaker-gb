INCLUDE "includes/includes.inc"


SECTION "Game State Functions", ROMX

xGame::
    xor a
    ld [wGameStateCurrent], a

.loop:
    ; Jump to current game state's function
    ld a, [wGameStateCurrent]
    ld c, NUMBER_OF_GAME_STATES
    ld hl, xGameStateJumpTable
    call _JumpTable

    ; Loop for as long as the current main state is valid
    ld a, [wGameStateCurrent]
    cp a, NUMBER_OF_GAME_STATES
    jr c, .loop

    ld a, MAIN_STATE_TITLE
    jp _MainStateNew

/*
Jump Table for each game state
*/
xGameStateJumpTable:
    DW xGameInit
    DW xGameReset
    DW xGamePlay
    DW xGameNext
    DW xGameOver
    ASSERT (@ - xGameStateJumpTable == NUMBER_OF_GAME_STATES * SIZE_OF_ADDRESS_TABLE)


/*
Returns to the previous main state.
*/
xGameStatePrevious::
    ld a, [wGameStatePrevious]
    jr xGameStateNew

/*
Increments the current main state.
*/
xGameStateIncrement::
    ld a, [wGameStateCurrent]
    inc a
    ; fallthrough

/*
Sets the current main state.

Input:
- `a` = `GAME_STATE_*` value
*/
xGameStateNew::
    push af

    ld a, [wGameStateCurrent]
    ld [wGameStatePrevious], a

    pop af
    ld [wGameStateCurrent], a
    ret


xGameInit:
    ; Load Attrmap
    ld hl, xGameStateAttrmap
    call _LoadAttrmapSCRN0

    ; Load Tilemap
    ld hl, xGameStateTilemap
    call _LoadTilemapSCRN0

    ; Load Paddle
    call _InitPaddle

    ; Load saved high score from sram
    call _LoadHighScore
    
    ; Clear Score
    call _ClearCurrentScore
    
    ld a, LCDC_DEFAULT
    call _ScreenOn

    ld a, GAME_STATE_RESET
    jp xGameStateNew


xGameReset:
    ; Load Ball
    call _InitBall

    ; Print Numbers
    call _PrintCurrentScore
    call _PrintHighScore
    call _PrintCurrentLevel
    call _PrintCurrentBalls

    ; Print String
    call xDrawPressAString
    
    ; Update objects
    call _UpdatePaddle
    call _UpdateBall

.loop:
    call _WaitForVBLInterrupt

    call _UpdatePaddle

    ldh a, [hKeysPressed]
    and a, PADF_A
    jr z, .loop

    call _StartBall

    ld a, GAME_STATE_PLAY
    jp xGameStateNew


xGamePlay:
    call xClearString

.loop:
    call _WaitForVBLInterrupt

    call _PrintCurrentScore

    call _UpdatePaddle
    call _UpdateBall

    call _GetBricksRemaining
    ld a, GAME_STATE_NEXT
    jp z, xGameStateNew

    ld a, [wBallPositionYAdjusted]
    sub a, OAM_Y_OFS
    cp a, SCRN_Y
    jr c, .loop

    call _DecrementCurrentBalls
    
    ld a, GAME_STATE_OVER
    jp z, xGameStateNew

    ld a, GAME_STATE_RESET
    jp xGameStateNew


xGameNext:
    ; Increment Level
    call _IncrementCurrentLevel
    
    ; Reload objects
    call _InitPaddle
    call _InitBall

    ; Load Attrmap
    ld hl, xGameStateAttrmap
    call _LoadAttrmapSCRN0

    ; Load Tilemap
    ld hl, xGameStateTilemap
    call _LoadTilemapSCRN0

    ld a, GAME_STATE_RESET
    jp xGameStateNew


xGameOver:
    call xDrawGameOverString

.loop:
    call _WaitForVBLInterrupt
    
    ldh a, [hKeysPressed]
    and a, PADF_START | PADF_A
    jr z, .loop
    
    ld a, NUMBER_OF_GAME_STATES
    jp xGameStateNew


xClearString:
    xor a
    ld hl, vSCRN0.y8x1
    ld b, 12
    ld d, $FF
    jp _VideoMemSetFast

xDrawPressAString:
    xor a
    ld hl, xGameStatePressAString
    ld b, (xGameStatePressAString.end - xGameStatePressAString)
    ld de, vSCRN0.y8x2
    jp _VideoMemCopyFast

xGameStatePressAString:
    DB " Press A! "
.end:

xDrawGameOverString:
    xor a
    ld hl, xGameStateGameOverString
    ld b, (xGameStateGameOverString.end - xGameStateGameOverString)
    ld de, vSCRN0.y8x1
    jp _VideoMemCopyFast

xGameStateGameOverString:
    DB " GAME OVER! "
.end:

xGameStateTilemap:
    INCBIN "assets/tilemaps/game_tilemap.rle"
.end:

xGameStateAttrmap:
    INCBIN "assets/tilemaps/game_attrmap.rle"
.end:   

ENDSECTION



SECTION "Game State Variables", WRAM0

wGameStateCurrent:
    DB

wGameStatePrevious:
    DB

ENDSECTION
