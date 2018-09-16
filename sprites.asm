DMA_Routine::
	ld a, HIGH(wOAMBuffer)
	ld [rDMA], a
	ld a, $28
.wait:
	dec a
	jr nz, .wait
	ret
DMA_Routine_End:

; Update the shadow OAM using a sprite list.
; hl = sprite list pointer
; Clobbers all registers
UpdateSprites::
	ld a, h
	ld [hSpriteListPtrHi], a
	ld a, l
	ld [hSpriteListPtrLo], a
	ld a, [hl] ; SPRITE_OFFSET_VISIBILITY
	and a
	jr z, .handle_visible_sprite

	cp SPRITE_HIDDEN
	jr z, .handle_hidden_sprite

.handle_loop:
	; point HL to the next sprite list entry
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
	assert SPRITE_HIDDEN != 0
	ld [hSpriteHidden], a

.handle_visible_sprite:
	ld b, SPRITE_INFO_SIZE
	ld de, hCurSpriteBuffer ; could use C as the pointer, would be shorter and faster

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
	ld d, 0
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]

	; load object list pointer
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de

	; load anchor coordinates
	ld a, [de]
	ld [hSpriteAnchorY], a
	inc de
	ld a, [de]
	ld [hSpriteAnchorX], a

	; load dimension descriptor pointer
	ld e, [hl]
	inc hl
	ld d, [hl]
	; inc hl ; not needed since .object_loop moves the pointer at the beginning
	; instead of the end

	; in .object_loop,
	; HL = object list pointer
	; DE = dimension descriptor pointer

.object_loop:
	; move to the next object
	inc hl

	ld a, [hCurSpriteFlags]
	ld [hObjectFlags], a

	ld a, [hl]
	cp $ff
	jr z, .finished_handling

	cp $fd
	jr nz, .not_flip

	ld a, [hCurSpriteFlags]
	xor OAMF_XFLIP
	ld [hObjectFlags], a
	inc hl
	ld a, [hl]
	jr .got_sprite_id

.empty_spot:
	; move to the next dimension descriptor entry
	inc de
	inc de
	jr .object_loop

.not_flip:
	cp $fe
	jr z, .empty_spot

.got_sprite_id:
	ld [hCurSpriteID], a

	; calculate the Y coordinate for the object
	ld a, [hCurSpriteY]
	ld b, a
	ld a, [de]
	ld c, a
	ld a, [hCurSpriteFlip]
	bit OAMB_YFLIP, a
	jr nz, .mirrored_y

	ld a, [hSpriteAnchorY]
	add b
	adc c ; TODO: why adc?
	jr .got_y

.mirrored_y:
	ld a, b
	push af
	ld a, [hSpriteAnchorY]
	ld b, a
	pop af
	sub b
	sbc c ; TODO: why sbc?
	sbc 8

.got_y:
	ld [hObjectY], a

	; likewise, calculate the X coordinate
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
	ld [hObjectX], a

	; get the OAM pointer
	push hl
	ld a, [hOAMBufferPtrHi]
	ld h, a
	ld a, [hOAMBufferPtrLo]
	ld l, a

	; move sprites to the $ff line instead of just skipping them, so that the entries from a
	; previous update are overwritten
	ld a, [hSpriteHidden]
	and a
	jr z, .real_y
	ld a, $ff
	jr .done_hiding
.real_y:
	ld a, [hObjectY]
.done_hiding:
	ld [hl+], a ; Y
	ld a, [hObjectX]
	ld [hl+], a ; X
	ld a, [hCurSpriteID]
	ld [hl+], a ; ID

	ld a, [hObjectFlags]
	ld b, a
	ld a, [hCurSpriteFlip]
	or b
	ld b, a
	ld a, [hCurSpriteBelowBG]
	or b
	ld [hl+], a ; flags

	; save the new OAM pointer and restore the object list pointer
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
	; shift the cycle to start pointing down
	dw SpriteT2, SpriteT3, SpriteT0, SpriteT1
	dw SpriteTypeA, SpriteTypeB, SpriteTypeC, SpriteOff
	dw SpriteDigit0, SpriteDigit1, SpriteDigit2, SpriteDigit3, SpriteDigit4
	dw SpriteDigit5, SpriteDigit6, SpriteDigit7, SpriteDigit8, SpriteDigit9

INCBIN "baserom.gb", $2c00, $2c68 - $2c00

sprite_descriptor: MACRO
\1::
	dw \1Objects
	db \2, \3
ENDM

	sprite_descriptor SpriteL0, -17, -16
	sprite_descriptor SpriteL1, -17, -16
	sprite_descriptor SpriteL2, -17, -16
	sprite_descriptor SpriteL3, -17, -16

	sprite_descriptor SpriteJ0, -17, -16
	sprite_descriptor SpriteJ1, -17, -16
	sprite_descriptor SpriteJ2, -17, -16
	sprite_descriptor SpriteJ3, -17, -16

	sprite_descriptor SpriteI0, -17, -16
	sprite_descriptor SpriteI1, -17, -16
	sprite_descriptor SpriteI2, -17, -16
	sprite_descriptor SpriteI3, -17, -16

	sprite_descriptor SpriteO0, -17, -16
	sprite_descriptor SpriteO1, -17, -16
	sprite_descriptor SpriteO2, -17, -16
	sprite_descriptor SpriteO3, -17, -16

	sprite_descriptor SpriteZ0, -17, -16
	sprite_descriptor SpriteZ1, -17, -16
	sprite_descriptor SpriteZ2, -17, -16
	sprite_descriptor SpriteZ3, -17, -16

	sprite_descriptor SpriteS0, -17, -16
	sprite_descriptor SpriteS1, -17, -16
	sprite_descriptor SpriteS2, -17, -16
	sprite_descriptor SpriteS3, -17, -16

	sprite_descriptor SpriteT2, -17, -16
	sprite_descriptor SpriteT3, -17, -16
	sprite_descriptor SpriteT0, -17, -16
	sprite_descriptor SpriteT1, -17, -16

	sprite_descriptor SpriteTypeA, 0, -24
	sprite_descriptor SpriteTypeB, 0, -24
	sprite_descriptor SpriteTypeC, 0, -24
	sprite_descriptor SpriteOff, 0, -24

	sprite_descriptor SpriteDigit0, 0, 0
	sprite_descriptor SpriteDigit1, 0, 0
	sprite_descriptor SpriteDigit2, 0, 0
	sprite_descriptor SpriteDigit3, 0, 0
	sprite_descriptor SpriteDigit4, 0, 0
	sprite_descriptor SpriteDigit5, 0, 0
	sprite_descriptor SpriteDigit6, 0, 0
	sprite_descriptor SpriteDigit7, 0, 0
	sprite_descriptor SpriteDigit8, 0, 0
	sprite_descriptor SpriteDigit9, 0, 0

INCBIN "baserom.gb", $2d10, $2da0 - $2d10

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
	db $ff ; useless _ before $ff

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

SpriteTypeAObjects::
	dw SpriteDimHorizontal
	db "A-TYPE", $ff

SpriteTypeBObjects::
	dw SpriteDimHorizontal
	db "B-TYPE", $ff

SpriteTypeCObjects::
	dw SpriteDimHorizontal
	db "C-TYPE", $ff

SpriteOffObjects::
	dw SpriteDimHorizontal
	db " OFF  ", $ff ; you could just move the anchor instead of using spaces...

SpriteDigit0Objects::
	dw SpriteDimHorizontal
	db "0", $ff

SpriteDigit1Objects::
	dw SpriteDimHorizontal
	db "1", $ff

SpriteDigit2Objects::
	dw SpriteDimHorizontal
	db "2", $ff

SpriteDigit3Objects::
	dw SpriteDimHorizontal
	db "3", $ff

SpriteDigit4Objects::
	dw SpriteDimHorizontal
	db "4", $ff

SpriteDigit5Objects::
	dw SpriteDimHorizontal
	db "5", $ff

SpriteDigit6Objects::
	dw SpriteDimHorizontal
	db "6", $ff

SpriteDigit7Objects::
	dw SpriteDimHorizontal
	db "7", $ff

SpriteDigit8Objects::
	dw SpriteDimHorizontal
	db "8", $ff

SpriteDigit9Objects::
	dw SpriteDimHorizontal
	db "9", $ff

INCBIN "baserom.gb", $2fc1, $31f1 - $2fc1

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

SpriteDimHorizontal:
	db 0, 0
	db 0, 8
	db 0, 16
	db 0, 24
	db 0, 32
	db 0, 40
	db 0, 48
	db 0, 56

INCBIN "baserom.gb", $3221, $3287 - $3221
