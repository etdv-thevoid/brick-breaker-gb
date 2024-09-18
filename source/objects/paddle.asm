INCLUDE "includes/includes.inc"


SECTION "Paddle Functions", ROM0


_InitPaddle::
    xor a
    ld [wPaddleAccelerationX], a
    ld [wPaddleVelocityX], a
    
    ld a, (SCRN_Y + 8)
    ld [wPaddlePositionYAdjusted], a

    ld a, (OAM_X_OFS * 7)
    ld [wPaddlePositionXAdjusted], a
    ld hl, wPaddlePositionX
    jp _ConvertByteToFixedPoint


_UpdatePaddle::
    xor a
    ld [wPaddleAccelerationX], a

.leftHeld:
    ldh a, [hKeysHeld]
    and a, PADF_LEFT
    jr z, .rightHeld

    ld a, -2
    ld [wPaddleAccelerationX], a
    jr .applyAcceleration

.rightHeld:
    ldh a, [hKeysHeld]
    and a, PADF_RIGHT
    jr z, .applyAcceleration

    ld a, 2
    ld [wPaddleAccelerationX], a
    jr .applyAcceleration

.applyAcceleration:
    ld hl, wPaddleVelocityX
    ld a, [wPaddleAccelerationX]
    add a, [hl]
    cp a, %1000_0000
    jr c, .accelRight

.accelLeft:
    inc a
    cp a, -$18
    jr nc, .applyVelocity
    cp a, $18
    ld a, -$18
    jr nc, .applyVelocity
    xor a
    jr .applyVelocity

.accelRight:
    dec a
    cp a, $18
    jr c, .applyVelocity
    cp a, -$18
    ld a, $18
    jr c, .applyVelocity
    xor a

.applyVelocity:
    ld [hl], a
    ld hl, wPaddlePositionX
    cp a, %1000_0000
    jr c, .movingRight

.movingLeft:
    cpl
    inc a
    ld b, a
    call _SubtractFromFixedPoint
    call _ConvertFixedPointToByte
    ld [wPaddlePositionXAdjusted], a
    cp a, 16
    jr nc, .updateSprite

    ld a, 16
    ld [wPaddlePositionXAdjusted], a
    ld hl, wPaddlePositionX
    call _ConvertByteToFixedPoint

    xor a
    ld [wPaddleAccelerationX], a
    ld [wPaddleVelocityX], a

    jr .updateSprite

.movingRight:
    ld b, a
    call _AddToFixedPoint
    call _ConvertFixedPointToByte
    ld [wPaddlePositionXAdjusted], a
    cp a, 96
    jr c, .updateSprite

    ld a, 96
    ld [wPaddlePositionXAdjusted], a
    ld hl, wPaddlePositionX
    call _ConvertByteToFixedPoint

    xor a
    ld [wPaddleAccelerationX], a
    ld [wPaddleVelocityX], a

.updateSprite:
    ld hl, wShadowOAM.0

    ld a, [wPaddlePositionYAdjusted]
    ld [hl+], a

    ld a, [wPaddlePositionXAdjusted]
    ld [hl+], a

    ld a, 0
    ld [hl+], a

    ld a, PALETTE_COLOR_MAGENTA
    ld [hl+], a
    
    ld a, [wPaddlePositionYAdjusted]
    ld [hl+], a

    ld a, [wPaddlePositionXAdjusted]
    add a, OAM_X_OFS
    ld [hl+], a

    ld a, 1
    ld [hl+], a

    ld a, PALETTE_COLOR_MAGENTA
    ld [hl+], a

    ret

    
ENDSECTION


SECTION "Paddle Variables", WRAM0

wPaddleAccelerationX:
    DB

wPaddleVelocityX:
    DB

wPaddlePositionX:
    DW

wPaddlePositionXAdjusted::
    DB

wPaddlePositionYAdjusted::
    DB

ENDSECTION
