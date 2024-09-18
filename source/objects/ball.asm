INCLUDE "includes/includes.inc"


SECTION "Object Functions", ROM0

_InitBall::
    xor a
    ld [wBallVelocityY], a
    ld [wBallVelocityX], a

    ld a, (SCRN_Y / 3) * 2
    ld [wBallPositionYAdjusted], a
    ld hl, wBallPositionY
    call _ConvertByteToFixedPoint

    ld a, 16
    ld [wBallPositionXAdjusted], a
    ld hl, wBallPositionX
    jp _ConvertByteToFixedPoint


_StartBall::
    call _GetCurrentLevel
    add a, $10
    
    ld [wBallVelocityMax], a
    ld [wBallVelocityY], a
    ld [wBallVelocityX], a
    ret


_UpdateBall::
    call _UpdateBall_Horizontal
    call _UpdateBall_Vertical

    call _UpdateBall_BackgroundCollision_Horizontal
    call _UpdateBall_BackgroundCollision_Vertical
    
    call _UpdateBall_PaddleCollision_Horizontal
    call _UpdateBall_PaddleCollision_Vertical

    jp _UpdateBall_Sprite


_UpdateBall_Vertical:
    ld a, [wBallVelocityY]
    ld hl, wBallPositionY
    cp a, %1000_0000
    jr c, .movingDown

.movingUp:
    cpl
    inc a
    ld b, a
    call _SubtractFromFixedPoint
    jr .done

.movingDown:
    ld b, a
    call _AddToFixedPoint

.done:
    call _ConvertFixedPointToByte
    ld [wBallPositionYAdjusted], a
    ret


_UpdateBall_Horizontal:
    ld a, [wBallVelocityX]
    ld hl, wBallPositionX
    cp a, %1000_0000
    jr c, .movingRight

.movingLeft:
    cpl
    inc a
    ld b, a
    call _SubtractFromFixedPoint
    jr .done

.movingRight:
    ld b, a
    call _AddToFixedPoint

.done:
    call _ConvertFixedPointToByte
    ld [wBallPositionXAdjusted], a
    ret


_UpdateBall_PaddleCollision_Horizontal:
    ld a, [wPaddlePositionYAdjusted]
    sub a, OAM_Y_OFS
    ld e, a
    ld a, [wPaddlePositionYAdjusted]
    sub a, (OAM_Y_OFS / 2)
    ld d, a

    ld a, [wBallPositionYAdjusted]
    sub a, (OAM_Y_OFS / 2)

    cp a, e
    jr c, .done
    ;sub a, (OAM_Y_OFS / 2)
    cp a, d
    jr nc, .done
    
.left:
    ld a, [wPaddlePositionXAdjusted]
    sub a, (OAM_X_OFS / 4) * 5
    ld e, a
    ld a, [wPaddlePositionXAdjusted]
    sub a, (OAM_X_OFS / 4) * 3
    ld d, a

    ld a, [wBallPositionXAdjusted]
    sub a, (OAM_X_OFS / 2)

    cp a, d
    jr nc, .right
    cp a, e
    jr c, .right
    
    ld a, [wBallVelocityMax]
    cpl
    inc a
    ld [wBallVelocityX], a

    ld a, TRUE
    and a
    ret

.right:
    ld a, [wPaddlePositionXAdjusted]
    add a, (OAM_X_OFS / 4) * 3
    ld e, a
    ld a, [wPaddlePositionXAdjusted]
    add a, (OAM_X_OFS / 4) * 5
    ld d, a

    ld a, [wBallPositionXAdjusted]
    sub a, (OAM_X_OFS / 2)

    cp a, d
    jr nc, .done
    cp a, e
    jr c, .done
    
    ld a, [wBallVelocityMax]
    ld [wBallVelocityX], a

    ld a, TRUE
    and a
    ret


.done:
    xor a
    ret



_UpdateBall_PaddleCollision_Vertical:
    ld a, [wPaddlePositionYAdjusted]
    sub a, OAM_Y_OFS
    ld e, a
    ld a, [wPaddlePositionYAdjusted]
    sub a, (OAM_Y_OFS / 2)
    ld d, a

    ld a, [wBallPositionYAdjusted]
    sub a, (OAM_Y_OFS / 2)

    cp a, e
    jr c, .done
    ;sub a, (OAM_Y_OFS / 2)
    cp a, d
    jr nc, .done
    
.next:
    ld a, [wPaddlePositionXAdjusted]
    sub a, (OAM_X_OFS / 4) * 5
    ld e, a
    ld a, [wPaddlePositionXAdjusted]
    add a, (OAM_X_OFS / 4) * 5
    ld d, a

    ld a, [wBallPositionXAdjusted]
    sub a, (OAM_X_OFS / 2)

    cp a, d
    jr nc, .done
    cp a, e
    jr c, .done
    
    ld a, [wBallVelocityMax]
    cpl
    inc a
    ld [wBallVelocityY], a

    ld a, SOUND_EFFECT_JUMP
    call _PlaySound

    ld a, TRUE
    and a
    ret

.done:
    xor a
    ret
    

_UpdateBall_BackgroundCollision_Horizontal:
    ld a, [wBallPositionYAdjusted]
    sub a, (OAM_Y_OFS / 4) * 3
    ld b, a
    
    ld a, [wBallPositionXAdjusted]
    ld c, a
    
    call _ConvertPixelPositionToGridPosition

    call _GetSCRN0BackgroundTile
    cp a, $FF
    jr z, .leftSide

    cp a, $02
    call c, _DeleteBrick

    ld a, [wBallVelocityMax]
    cpl
    inc a
    ld [wBallVelocityX], a

    jr .collision


.leftSide:
    ld a, [wBallPositionYAdjusted]
    sub a, (OAM_Y_OFS / 4) * 3
    ld b, a
    
    ld a, [wBallPositionXAdjusted]
    sub a, (OAM_X_OFS)
    ld c, a
    
    call _ConvertPixelPositionToGridPosition

    call _GetSCRN0BackgroundTile
    cp a, $FF
    jr z, .done
    
    cp a, $02
    call c, _DeleteBrick
    
    ld a, [wBallVelocityMax]
    ld [wBallVelocityX], a
    jr .collision

.done:
    xor a
    ret

.collision:
    ld a, SOUND_EFFECT_JUMP
    call _PlaySound

    ld a, TRUE
    and a
    ret


_UpdateBall_BackgroundCollision_Vertical:
    ld a, [wBallPositionYAdjusted]
    sub a, (OAM_Y_OFS / 2)
    ld b, a
    
    ld a, [wBallPositionXAdjusted]
    sub a, (OAM_X_OFS / 2)
    ld c, a

    call _ConvertPixelPositionToGridPosition

    call _GetSCRN0BackgroundTile
    cp a, $FF
    jr z, .topSide
    
    cp a, $02
    call c, _DeleteBrick

    ld a, [wBallVelocityMax]
    cpl
    inc a
    ld [wBallVelocityY], a
    jr .collision


.topSide:
    ld a, [wBallPositionYAdjusted]
    sub a, OAM_Y_OFS
    ld b, a
    
    ld a, [wBallPositionXAdjusted]
    sub a, (OAM_X_OFS / 2)
    ld c, a

    call _ConvertPixelPositionToGridPosition

    call _GetSCRN0BackgroundTile
    cp a, $FF
    jr z, .done
    
    cp a, $02
    call c, _DeleteBrick
    
    ld a, [wBallVelocityMax]
    ld [wBallVelocityY], a
    jr .collision

.done:
    xor a
    ret

.collision:
    ld a, SOUND_EFFECT_JUMP
    call _PlaySound

    ld a, TRUE
    and a
    ret


_UpdateBall_Sprite:
    ld hl, wShadowOAM.2

    ld a, [wBallPositionYAdjusted]
    ld [hl+], a

    ld a, [wBallPositionXAdjusted]
    ld [hl+], a

    ld a, 2
    ld [hl+], a

    ld a, PALETTE_COLOR_WHITE
    ld [hl+], a

    ret


_DeleteBrick:
    and a
    jr z, .leftSide

    dec hl

.leftSide:
    call _IsGBColor
    jr z, .monochrome

    push hl
    ld a, 1
    ld b, 2
    ld d, $00
    call _VideoMemSetFast
    pop hl

.monochrome:
    push hl
    xor a
    ld b, 2
    ld d, $FF
    call _VideoMemSetFast

    ld a, SOUND_EFFECT_PERCUSSION
    call _PlaySound
    pop hl
    ; fallthrough


_GetPointsValue:
REPT 5
    srl h
    rr l
ENDR
    ld a, l
    and a, %0001_1111
    cp a, 5
    jr nc, .add1
    cp a, 3
    jr nc, .add2
    
.add3:
    ld a, 3
    jp _AddToCurrentScore

.add2:
    ld a, 2
    jp _AddToCurrentScore

.add1:
    ld a, 1
    jp _AddToCurrentScore

    
ENDSECTION


SECTION "Ball Variables", WRAM0

wBallVelocityMax:
    DB

wBallVelocityY:
    DB

wBallVelocityX:
    DB

wBallPositionY:
    DW

wBallPositionX:
    DW
    
wBallPositionYAdjusted::
    DB

wBallPositionXAdjusted::
    DB

ENDSECTION
