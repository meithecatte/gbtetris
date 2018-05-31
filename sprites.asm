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
	dw SpriteL0
	dw SpriteL1
INCBIN "baserom.gb", $2bb0, $2c68 - $2bb0

SpriteL0::
	dw SpriteL0Objects
	db -17, -16

SpriteL1::
	dw SpriteL1Objects
	db -17, -16

INCBIN "baserom.gb", $2c70, $2da0 - $2c70

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

INCBIN "baserom.gb", $2dc2, $31f1 - $2dc2

PURGE _

SpriteDim4x4::
INCBIN "baserom.gb", $31f1, $3287 - $31f1
