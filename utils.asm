ReadJoypad::
	ld a, JOYP_DPAD
	ld [rJOYP], a

REPT 2
	ld a, [rJOYP]
ENDR

IF DEF(INTERNATIONAL)
	REPT 2
		ld a, [rJOYP]
	ENDR
ENDC

	cpl
	and $0f
	swap a
	ld b, a
	ld a, JOYP_BUTTONS
	ld [rJOYP], a

REPT 6
	ld a, [rJOYP]
ENDR

IF DEF(INTERNATIONAL)
	REPT 4
		ld a, [rJOYP]
	ENDR
ENDC

	cpl
	and $0f
	or b
	ld c, a
	ld a, [hKeysHeld]
	xor c
	and c
	ld [hKeysPressed], a
	ld a, c
	ld [hKeysHeld], a
	ld a, JOYP_DESELECT
	ld [rJOYP], a
	ret

; convert a grid-aligned sprite coordinate pair into a tilemap address of the corresponding tile
; Input: hCoordConversionX, hCoordConversionY
; Output in HL as well as hCoordConversionHi and hCoordConversionLo
; Clobbers A, B, DE
SpriteCoordToTilemapAddr::
	ld a, [hCoordConversionY]
	sub 16
	srl a ; rrca + and would be shorter
	srl a
	srl a
	ld de, 0 ; could just load d
	ld e, a
	ld hl, vBGMapA
	ld b, BG_MAP_WIDTH ; you can do this with a simple shift. No need for loops
.multiply_loop:
	add hl, de
	dec b
	jr nz, .multiply_loop

	ld a, [hCoordConversionX]
	sub 8
	srl a ; as above, rrca + and would be shorter
	srl a
	srl a
	ld de, 0 ; e doesn't need touching and d is already zero
	ld e, a
	add hl, de ; the alignment means an 8-bit add would suffice
	ld a, h
	ld [hCoordConversionHi], a
	ld a, l
	ld [hCoordConversionLo], a
	ret

Unused_TilemapAddrToSpriteCoord::
	; better way to write this:
	; ld a, [hCoordConversionLo]
	; ld e, a
	; ld a, [hCoordConversionHi]
	; rept 3
	; rl e
	; rlca
	; endr
	; and $1f
	; add 16
	; ld [hCoordConversionY], a

	ld a, [hCoordConversionHi]
	ld d, a
	ld a, [hCoordConversionLo]
	ld e, a

	ld b, 4
.shift_loop:
	rr d
	rr e
	dec b
	jr nz, .shift_loop

	ld a, e
	sub $84 ; this feels wrong - in fact, a wrong value here makes it break
	and $fe
	rlca ; or add a, without the carry nastiness
	rlca
	add 8
	ld [hCoordConversionY], a

	ld a, [hCoordConversionLo]
	and $1f
	rla ; again, carry nastiness
	rla
	rla
	add 8
	ld [hCoordConversionX], a
	ret

Call_000_2a7e:
	ld a, [$ff00+$e0]
	and a
	ret z

Call_000_2a82:
	ld c, $03

; Display a BCD value stored LSB-first. Leading zeroes are shown as spaces. Therefore, the number is
; right-aligned.
; Input:
;   HL = tilemap pointer (leftmost tile)
;   DE = MSB of the number
;   C  = number length in bytes
; Output: none
; Clobbers all registers
DisplayBCD::
	xor a
	ld [hSeenNonZero], a

.loop:
	ld a, [de]
	ld b, a ; it would take less code bytes while taking the same amount of time to not save this byte
	swap a
	and $0f
	jr nz, .found_nonzero_high

	ld a, [hSeenNonZero]
	and a
	ld a, "0"
	jr nz, .got_high_digit
	ld a, " "
.got_high_digit:
	ld [hl+], a
	ld a, b
	and $0f
	jr nz, .found_nonzero_low

	ld a, [hSeenNonZero]
	and a
	ld a, "0"
	jr nz, .got_low_digit

	ld a, 1 ; if it's the last digit
	cp c
	ld a, "0"
	jr z, .got_low_digit
	ld a, " "
.got_low_digit:
	ld [hl+], a
	dec e
	dec c
	jr nz, .loop

	xor a
	ld [$ff00+$e0], a
	ret

.found_nonzero_high:
	push af
	ld a, 1
	ld [hSeenNonZero], a
	pop af
	jr .got_high_digit

.found_nonzero_low:
	push af
	ld a, 1
	ld [hSeenNonZero], a
	pop af
	jr .got_low_digit