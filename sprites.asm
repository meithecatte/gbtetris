DMA_Routine::
	ld a, HIGH(wOAMBuffer)
	ld [rDMA], a
	ld a, $28
.wait:
	dec a
	jr nz, .wait
	ret
DMA_Routine_End:

; hl = sprite list pointer
UpdateSprites::
	ld a, h
	ld [hSpriteListPtrHi], a
	ld a, l
	ld [hSpriteListPtrLo], a
	ld a, [hl]
	and a
	jr z, .handle_visible_sprite

	cp SPRITE_HIDDEN
	jr z, .handle_hidden_sprite

.handle_loop:
	ld a, [hSpriteListPtrHi]
	ld h, a
	ld a, [hSpriteListPtrLo]
	ld l, a
	ld de, SPRITE_SIZE
	add hl, de
	ld a, [hSpriteCount]
	dec a
	ld [hSpriteCount], a
	ret z
	jr UpdateSprites

.finished_handling:
	xor a
	ld [hSpriteHidden], a
	jr .handle_loop

.handle_hidden_sprite:
	ld [hSpriteHidden], a

.handle_visible_sprite:
	ld b, SPRITE_INFO_SIZE
	ld de, hCurSpriteBuffer ; could use C as the pointer, would be shorter

.copy_entry:
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .copy_entry

	ld a, [hCurSpriteID]
	ld hl, SpriteDescriptorPointers
	rlca ; add de twice instead to get greater range for free
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl] ; could load into HL again and get free increments later (see rst $28 comment)
	inc hl
	ld d, [hl]

	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	ld a, [de]
	ld [hSpriteAnchorY], a
	inc de
	ld a, [de]
	ld [hSpriteAnchorX], a
	ld e, [hl]
	inc hl
	ld d, [hl] ; in the loop,
	; HL = object list pointer
	; DE = dimension descriptor pointer

.object_loop:
	inc hl
	ld a, [hCurSpriteFlags]
	ld [hSpriteFlags], a
	ld a, [hl]
	cp $ff
	jr z, .finished_handling

	cp $fd
	jr nz, .not_flip

	ld a, [hCurSpriteFlags]
	xor OAMF_XFLIP
	ld [hSpriteFlags], a
	inc hl
	ld a, [hl]
	jr .not_magic

.empty_spot:
	inc de
	inc de
	jr .object_loop

.not_flip:
	cp $fe
	jr z, .empty_spot

.not_magic:
	ld [hCurSpriteID], a
	ld a, [hCurSpriteY]
	ld b, a
	ld a, [de]
	ld c, a
	ld a, [hCurSpriteFlip]
	bit OAMB_YFLIP, a
	jr nz, .mirrored_y

	ld a, [hSpriteAnchorY]
	add b
	adc c
	jr .got_y

.mirrored_y:
	ld a, b
	push af
	ld a, [hSpriteAnchorY]
	ld b, a
	pop af
	sub b
	sbc c
	sbc 8

.got_y:
	ld [hSpriteY], a
	ld a, [hCurSpriteX]
	ld b, a
	inc de
	ld a, [de]
	inc de
	ld c, a
	ld a, [hCurSpriteFlip]
	bit OAMB_XFLIP, a
	jr nz, .mirrored_x

	ld a, [hSpriteAnchorX]
	add b
	adc c
	jr .got_x

.mirrored_x:
	ld a, b
	push af
	ld a, [hSpriteAnchorX]
	ld b, a
	pop af
	sub b
	sbc c
	sbc 8

.got_x:
	ld [hSpriteX], a
	push hl
	ld a, [hOAMBufferPtrHi]
	ld h, a
	ld a, [hOAMBufferPtrLo]
	ld l, a
	ld a, [hSpriteHidden]
	and a
	jr z, .real_y

	ld a, $ff
	jr .done_hiding

.real_y:
	ld a, [hSpriteY]

.done_hiding:
	ld [hl+], a
	ld a, [hSpriteX]
	ld [hl+], a
	ld a, [hCurSpriteID]
	ld [hl+], a
	ld a, [hSpriteFlags]
	ld b, a
	ld a, [hCurSpriteFlip]
	or b
	ld b, a
	ld a, [hCurSpriteBelowBG]
	or b
	ld [hl+], a
	ld a, h
	ld [hOAMBufferPtrHi], a
	ld a, l
	ld [hOAMBufferPtrLo], a
	pop hl
	jp .object_loop

SpriteDescriptorPointers::
	dw SpriteL0, SpriteL1, SpriteL2, SpriteL3
	dw SpriteJ0, SpriteJ1, SpriteJ2, SpriteJ3
	dw SpriteI0, SpriteI1, SpriteI2, SpriteI3 ; you could just do 0, 1, 0, 1
	dw SpriteO0, SpriteO1, SpriteO2, SpriteO3 ; JUST REFER TO THE SAME SPRITE FOUR TIMES ALREADY
	dw SpriteZ0, SpriteZ1, SpriteZ2, SpriteZ3
	dw SpriteS0, SpriteS1, SpriteS2, SpriteS3
	dw SpriteT0, SpriteT1, SpriteT2, SpriteT3

INCBIN "baserom.gb", $2be4, $2c68 - $2be4

SpriteL0::
	dw SpriteL0Objects
	db -17, -16

SpriteL1::
	dw SpriteL1Objects
	db -17, -16

SpriteL2::
	dw SpriteL2Objects
	db -17, -16

SpriteL3::
	dw SpriteL3Objects
	db -17, -16

SpriteJ0::
	dw SpriteJ0Objects
	db -17, -16

SpriteJ1::
	dw SpriteJ1Objects
	db -17, -16

SpriteJ2::
	dw SpriteJ2Objects
	db -17, -16

SpriteJ3::
	dw SpriteJ3Objects
	db -17, -16

SpriteI0::
	dw SpriteI0Objects
	db -17, -16

SpriteI1::
	dw SpriteI1Objects
	db -17, -16

SpriteI2::
	dw SpriteI2Objects
	db -17, -16

SpriteI3::
	dw SpriteI3Objects
	db -17, -16

SpriteO0::
	dw SpriteO0Objects
	db -17, -16

SpriteO1::
	dw SpriteO1Objects
	db -17, -16

SpriteO2::
	dw SpriteO2Objects
	db -17, -16

SpriteO3::
	dw SpriteO3Objects
	db -17, -16

SpriteZ0::
	dw SpriteZ0Objects
	db -17, -16

SpriteZ1::
	dw SpriteZ1Objects
	db -17, -16

SpriteZ2::
	dw SpriteZ2Objects
	db -17, -16

SpriteZ3::
	dw SpriteZ3Objects
	db -17, -16

SpriteS0::
	dw SpriteS0Objects
	db -17, -16

SpriteS1::
	dw SpriteS1Objects
	db -17, -16

SpriteS2::
	dw SpriteS2Objects
	db -17, -16

SpriteS3::
	dw SpriteS3Objects
	db -17, -16

SpriteT0::
	dw SpriteT2Objects ; shift the cycle to start pointing down
	db -17, -16

SpriteT1::
	dw SpriteT3Objects
	db -17, -16

SpriteT2::
	dw SpriteT0Objects
	db -17, -16

SpriteT3::
	dw SpriteT1Objects
	db -17, -16

INCBIN "baserom.gb", $2cd8, $2da0 - $2cd8

; make it readable
_ EQU $fe
SpriteL0Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _  
	db _,   _,   _,   _  
	db $84, $84, $84, _
	db $84, $ff

SpriteL1Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _  
	db _,   $84, _,   _
	db _,   $84, _,   _
	db _,   $84, $84, $ff

SpriteL2Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   $84, _
	db $84, $84, $84, _
	db $ff ; couldn't you have stopped this sooner?

SpriteL3Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db $84, $84, _,   _
	db _,   $84, _,   _
	db _,   $84, $ff

SpriteJ0Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   _,   _
	db $81, $81, $81, _
	db _,   _,   $81, $ff

SpriteJ1Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   $81, $81, _
	db _,   $81, _,   _
	db _,   $81, $ff

SpriteJ2Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db $81, _,   _,   _
	db $81, $81, $81, $ff

SpriteJ3Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   $81, _,   _
	db _,   $81, _,   _
	db $81, $81, $ff

SpriteI0Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   _,   _
	db $8a, $8b, $8b, $8f
	db $ff

SpriteI1Objects::
	dw SpriteDim4x4
	db _,   $80, _,   _
	db _,   $88, _,   _
	db _,   $88, _,   _
	db _,   $89, $ff

SpriteI2Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   _,   _
	db $8a, $8b, $8b, $8f
	db $ff

SpriteI3Objects::
	dw SpriteDim4x4
	db _,   $80, _,   _
	db _,   $88, _,   _
	db _,   $88, _,   _
	db _,   $89, $ff

SpriteO0Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   _,   _
	db _,   $83, $83, _
	db _,   $83, $83, $ff

SpriteO1Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   _,   _
	db _,   $83, $83, _
	db _,   $83, $83, $ff

SpriteO2Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   _,   _
	db _,   $83, $83, _
	db _,   $83, $83, $ff

SpriteO3Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   _,   _
	db _,   $83, $83, _
	db _,   $83, $83, $ff

SpriteZ0Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   _,   _
	db $82, $82, _,   _
	db _,   $82, $82, $ff

SpriteZ1Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   $82, _,   _
	db $82, $82, _,   _
	db $82, $ff

SpriteZ2Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   _,   _
	db $82, $82, _,   _
	db _,   $82, $82, $ff

SpriteZ3Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   $82, _,   _
	db $82, $82, _,   _
	db $82, $ff

SpriteS0Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   _,   _
	db _,   $86, $86, _
	db $86, $86, $ff

SpriteS1Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db $86, _,   _,   _
	db $86, $86, _,   _
	db _,   $86, $ff

SpriteS2Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   _,   _
	db _,   $86, $86, _
	db $86, $86, $ff

SpriteS3Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db $86, _,   _,   _
	db $86, $86, _,   _
	db _,   $86, $ff

SpriteT0Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   $85, _,   _
	db $85, $85, $85, $ff

SpriteT1Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   $85, _,   _
	db $85, $85, _,   _
	db _,   $85, $ff

SpriteT2Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,   _,   _,   _
	db $85, $85, $85, _
	db _,   $85, $ff

SpriteT3Objects::
	dw SpriteDim4x4
	db _,   _,   _,   _
	db _,  $85,  _,   _
	db _,  $85,  $85, _
	db _,  $85,  $ff

INCBIN "baserom.gb", $2f75, $31f1 - $2f75

PURGE _

SpriteDim4x4::
	db 0,  0
	db 0,  8
	db 0,  16
	db 0,  24
	db 8,  0
	db 8,  8
	db 8,  16
	db 8,  24
	db 16, 0
	db 16, 8
	db 16, 16
	db 16, 24
	db 24, 0
	db 24, 8
	db 24, 16
	db 24, 24
INCBIN "baserom.gb", $3211, $3287 - $3211
