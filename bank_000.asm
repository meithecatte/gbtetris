SECTION "rst0", ROM0[$0]
	jp Init

rept 5
	nop
endr

SECTION "rst8", ROM0[$8]
	jp Init

SECTION "rst28", ROM0[$28]
	; Implements the `jumptable` macro. A list of 16-bit code pointers should follow.
	; A = jumptable entry number
	; Clobbers A, DE and HL
	add a
	pop hl
	ld e, a
	ld d, 0
	add hl, de ; do this twice instead of add a at the beginning for increased range

	ld e, [hl] ; could do this part better:
	inc hl     ; ld a, [hli]
	ld d, [hl] ; ld h, [hl]
	push de    ; ld l, a
	pop hl     ; jp hl
	jp hl

SECTION "VBlank", ROM0[$40]
	jp VBlankInterrupt

SECTION "LCDC", ROM0[$48]
	jp EmptyInterrupt

SECTION "Timer", ROM0[$50]
	jp EmptyInterrupt

SECTION "Serial", ROM0[$58]
	jp SerialInterrupt

; In the japanese version of the game, the serial code is located later in the ROM, and this space
; is empty.
IF DEF(INTERNATIONAL)
	INCLUDE "serial.asm"
ENDC

SECTION "Entry Point", ROM0[$100]
	nop
	jp Boot

; Header set by rgbfix
	rept $150 - $104
	db $00
	endr

SECTION "Code", ROM0[$150]
Boot:
	jp Init

; I can't think of a way this could ever be useful. Maybe something to do with the hardware being
; a moving target in development? Maybe a simple testcase the programmer used to verify his
; understanding of the hblank timing?
Unused_WTF::
	call SpriteCoordToTilemapAddr

.wait_for_hblank1:
	ld a, [rSTAT]
	and STATF_MODE
	assert STATF_HB == 0
	jr nz, .wait_for_hblank1

	ld b, [hl]

.wait_for_hblank2:
	ld a, [rSTAT]
	and STATF_MODE
	assert STATF_HB == 0
	jr nz, .wait_for_hblank2

	ld a, [hl]
	and b
	ret

; Add two BCD numbers together stored in memory BCD first.
; HL = pointer to destination, first operand. 3 bytes
; DE = second operand, directly as a register
; On overflow, the result is 999999
; TODO: a quick CODE XREF check suggests this may be used for more than score updates
AddBCD::
	ld a, e
	add [hl]
	daa
	ld [hl+], a
	ld a, d
	adc [hl]
	daa
	ld [hl+], a
	ld a, $00 ; can't xor a - need to preserve flags
	adc [hl]
	daa
	ld [hl], a
	ld a, 1
	ld [$ff00+$e0], a
	ret nc

	ld a, $99
	ld [hl-], a
	ld [hl-], a
	ld [hl], a
	ret

IF !DEF(INTERNATIONAL)
	INCLUDE "serial.asm"
ENDC

INCLUDE "vblank.asm"
INCLUDE "mainloop.asm"
INCLUDE "titlescreen.asm"
INCLUDE "demo.asm"
INCLUDE "multiplayer.asm"

Call_000_0e21:
	ld a, [hDelayCounter]
	and a
	jr nz, jr_000_0e49

	ld hl, $ffc6
	dec [hl]
	ld a, $19
	ld [hDelayCounter], a
	call Call_000_0fc4
	ld hl, $c201
	ld a, [hl]
	xor $30
	ld [hl+], a
	cp $60
	call z, Call_000_0f7b
	inc l
	push af
	ld a, [hl]
	xor $01
	ld [hl], a
	ld l, $13
	ld [hl-], a
	pop af
	dec l
	ld [hl], a

jr_000_0e49:
	ld a, [$ff00+$d7]
	cp $05
	jr nz, jr_000_0e77

	ld a, [hDemoCountdown]
	ld hl, $c221
	cp $06
	jr z, jr_000_0e73

	cp $08
	jr nc, jr_000_0e77

	ld a, [hl]
	cp $72
	jr nc, jr_000_0e67

	cp $69
	ret z

	inc [hl]
	inc [hl]
	ret


jr_000_0e67:
	ld [hl], $69
	inc l
	inc l
	ld [hl], $57
	ld a, $06
	ld [wPlayPulseSFX], a
	ret


jr_000_0e73:
	dec l
	ld [hl], $80
	ret


jr_000_0e77:
	ld a, [hFastDropDelayCounter]
	and a
	ret nz

	ld a, $0f
	ld [hFastDropDelayCounter], a
	ld hl, $c223
	ld a, [hl]
	xor $01
	ld [hl], a
	ret

HandleState30::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld a, [$ff00+$ef]
	and a
	jr nz, jr_000_0e95

	ld a, [$ff00+$d8]
	inc a
	ld [$ff00+$d8], a

jr_000_0e95:
	call Call_000_0fd3
	ld de, $2771
	ld a, [hMasterSlave]
	cp $29
	jr z, jr_000_0ea4

	ld de, $277d

jr_000_0ea4:
	ld hl, $c200
	ld c, 2
	call LoadSprites
	ld a, $19
	ld [hDelayCounter], a
	ld a, [$ff00+$ef]
	and a
	jr z, jr_000_0eba

	ld hl, $c210
	ld [hl], $80

jr_000_0eba:
	ld a, $02
	call UpdateNSprites
	ld a, $21
	ld [hGameState], a
	ld a, $09
	ld [wPlaySong], a
	ld a, [$ff00+$d8]
	cp $05
	ret nz

	ld a, $11
	ld [wPlaySong], a
	ret


jr_000_0ed3:
	ld a, [$ff00+$d8]
	cp $05
	jr nz, jr_000_0ee0

	ld a, [hDemoCountdown]
	and a
	jr z, jr_000_0ee6

	jr jr_000_0f02

jr_000_0ee0:
	ld a, [hKeysPressed]
	bit 3, a
	jr z, jr_000_0f02

jr_000_0ee6:
	ld a, $60
	ld [hSendBuffer], a
	ld [hSendBufferValid], a
	jr jr_000_0f0b

HandleState33::
	ld a, $01
	ld [rIE], a
	ld a, [hSerialDone]
	jr z, jr_000_0f02

	ld a, [hMasterSlave]
	cp $29
	jr z, jr_000_0ed3

	ld a, [hRecvBuffer]
	cp $60
	jr z, jr_000_0f0b

jr_000_0f02:
	call Call_000_0f12
	ld a, $02
	call UpdateNSprites
	ret


jr_000_0f0b:
	ld a, $1f
	ld [hGameState], a
	ld [hSerialDone], a
	ret


Call_000_0f12:
	ld a, [hDelayCounter]
	and a
	jr nz, jr_000_0f33

	ld hl, $ffc6
	dec [hl]
	ld a, $19
	ld [hDelayCounter], a
	call Call_000_0fc4
	ld hl, $c211
	ld a, [hl]
	xor $08
	ld [hl+], a
	cp $68
	call z, Call_000_0f7b
	inc l
	ld a, [hl]
	xor $01
	ld [hl], a

jr_000_0f33:
	ld a, [$ff00+$d8]
	cp $05
	jr nz, jr_000_0f6b

	ld a, [hDemoCountdown]
	ld hl, $c201
	cp $05
	jr z, jr_000_0f67

	cp $06
	jr z, jr_000_0f57

	cp $08
	jr nc, jr_000_0f6b

	ld a, [hl]
	cp $72
	jr nc, jr_000_0f67

	cp $61
	ret z

	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret


jr_000_0f57:
	dec l
	ld [hl], $00
	inc l
	ld [hl], $61
	inc l
	inc l
	ld [hl], $56
	ld a, $06
	ld [wPlayPulseSFX], a
	ret


jr_000_0f67:
	dec l
	ld [hl], $80
	ret


jr_000_0f6b:
	ld a, [hFastDropDelayCounter]
	and a
	ret nz

	ld a, $0f
	ld [hFastDropDelayCounter], a
	ld hl, $c203
	ld a, [hl]
	xor $01
	ld [hl], a
	ret


Call_000_0f7b:
	push af
	push hl
	ld a, [$ff00+$d7]
	cp $05
	jr z, jr_000_0f9d

	ld a, [$ff00+$d8]
	cp $05
	jr z, jr_000_0f9d

	ld a, [hMasterSlave]
	cp $29
	jr nz, jr_000_0f9d

	ld hl, $c060
	ld b, $24
	ld de, $0fa0

jr_000_0f97:
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, jr_000_0f97

jr_000_0f9d:
	pop hl
	pop af
	ret


	ld b, d
	jr nc, jr_000_0fb0

	nop
	ld b, d
	jr c, @-$4c

	nop
	ld b, d
	ld b, b
	ld c, $00
	ld b, d
	ld c, b
	inc e
	nop

jr_000_0fb0:
	ld b, d
	ld e, b
	ld c, $00
	ld b, d
	ld h, b
	dec e
	nop
	ld b, d
	ld l, b
	or l
	nop
	ld b, d
	ld [hl], b
	cp e
	nop
	ld b, d
	ld a, b
	dec e
	nop

Call_000_0fc4:
	ld hl, $c060
	ld de, $0004
	ld b, $09
	xor a

jr_000_0fcd:
	ld [hl], a
	add hl, de
	dec b
	jr nz, jr_000_0fcd

	ret


Call_000_0fd3:
	call DisableLCD
	ld hl, ShuttleGFX
	ld bc, $1000
	call Call_000_2838
	call ClearTilemapA
	ld hl, $9800
	ld de, $552c
	ld b, $04
	call CopyRowsToTilemap
	ld hl, $9980
	ld b, $06
	call CopyRowsToTilemap
	ld a, [hMasterSlave]
	cp $29
	jr nz, jr_000_101d

	ld hl, $9841
	ld [hl], $bd
	inc l
	ld [hl], $b2
	inc l
	ld [hl], $2e
	inc l
	ld [hl], $be
	inc l
	ld [hl], $2e
	ld hl, $9a01
	ld [hl], $b4
	inc l
	ld [hl], $b5
	inc l
	ld [hl], $bb
	inc l
	ld [hl], $2e
	inc l
	ld [hl], $bc

jr_000_101d:
	ld a, [$ff00+$ef]
	and a
	jr nz, jr_000_1025

	call Call_000_10e9

jr_000_1025:
	ld a, [$ff00+$d7]
	and a
	jr z, jr_000_1073

	cp $05
	jr nz, jr_000_1044

	ld hl, $98a5
	ld b, $0b
	ld a, [hMasterSlave]
	cp $29
	ld de, $1157
	jr z, jr_000_103f

	ld de, $1162

jr_000_103f:
	call Call_000_113c
	ld a, $04

jr_000_1044:
	ld c, a
	ld a, [hMasterSlave]
	cp $29
	ld a, $93
	jr nz, jr_000_104f

	ld a, $8f

jr_000_104f:
	ld [hBuffer], a
	ld hl, $99e7
	call Call_000_10ce
	ld a, [$ff00+$d9]
	and a
	jr z, jr_000_1073

	ld a, $ac
	ld [hBuffer], a
	ld hl, $99f0
	ld c, $01
	call Call_000_10ce
	ld hl, $98a6
	ld de, $116d
	ld b, $09
	call Call_000_113c

jr_000_1073:
	ld a, [$ff00+$d8]
	and a
	jr z, jr_000_10b6

	cp $05
	jr nz, jr_000_1092

	ld hl, $98a5
	ld b, $0b
	ld a, [hMasterSlave]
	cp $29
	ld de, $1162
	jr z, jr_000_108d

	ld de, $1157

jr_000_108d:
	call Call_000_113c
	ld a, $04

jr_000_1092:
	ld c, a
	ld a, [hMasterSlave]
	cp $29
	ld a, $8f
	jr nz, jr_000_109d

	ld a, $93

jr_000_109d:
	ld [hBuffer], a
	ld hl, $9827
	call Call_000_10ce
	ld a, [$ff00+$da]
	and a
	jr z, jr_000_10b6

	ld a, $ac
	ld [hBuffer], a
	ld hl, $9830
	ld c, $01
	call Call_000_10ce

jr_000_10b6:
	ld a, [$ff00+$db]
	and a
	jr z, jr_000_10c6

	ld hl, $98a7
	ld de, $1151
	ld b, $06
	call Call_000_113c

jr_000_10c6:
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	call ClearOAM
	ret


Call_000_10ce:
jr_000_10ce:
	ld a, [hBuffer]
	push hl
	ld de, $0020
	ld b, $02

jr_000_10d6:
	push hl
	ld [hl+], a
	inc a
	ld [hl], a
	inc a
	pop hl
	add hl, de
	dec b
	jr nz, jr_000_10d6

	pop hl
	ld de, $0003
	add hl, de
	dec c
	jr nz, jr_000_10ce

	ret


Call_000_10e9:
	ld hl, $ffd7
	ld de, $ffd8
	ld a, [$ff00+$d9]
	and a
	jr nz, jr_000_112e

	ld a, [$ff00+$da]
	and a
	jr nz, jr_000_1135

	ld a, [$ff00+$db]
	and a
	jr nz, jr_000_111f

	ld a, [hl]
	cp $04
	jr z, jr_000_1114

	ld a, [de]
	cp $04
	ret nz

jr_000_1107:
	ld a, $05
	ld [de], a
	jr jr_000_1116

	ld a, [de]
	cp $03
	ret nz

jr_000_1110:
	ld a, $03
	jr jr_000_1119

jr_000_1114:
	ld [hl], $05

jr_000_1116:
	xor a
	ld [$ff00+$db], a

jr_000_1119:
	xor a
	ld [$ff00+$d9], a
	ld [$ff00+$da], a
	ret


jr_000_111f:
	ld a, [hl]
	cp $04
	jr nz, jr_000_112a

	ld [$ff00+$d9], a

jr_000_1126:
	xor a
	ld [$ff00+$db], a
	ret


jr_000_112a:
	ld [$ff00+$da], a
	jr jr_000_1126

jr_000_112e:
	ld a, [hl]
	cp $05
	jr z, jr_000_1114

	jr jr_000_1110

jr_000_1135:
	ld a, [de]
	cp $05
	jr z, jr_000_1107

	jr jr_000_1110

Call_000_113c:
	push bc
	push hl

jr_000_113e:
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, jr_000_113e

	pop hl
	ld de, $0020
	add hl, de
	pop bc
	ld a, $b6

jr_000_114c:
	ld [hl+], a
	dec b
	jr nz, jr_000_114c

	ret


	or b
	or c
	or d
	or e
	or c
	ld a, $b4
	or l
	cp e
	ld l, $bc
	cpl
	dec l
	ld l, $3d
	ld c, $3e
	cp l
	or d
	ld l, $be
	ld l, $2f
	dec l
	ld l, $3d
	ld c, $3e
	or l
	or b
	ld b, c
	or l
	dec a
	dec e
	or l
	cp [hl]
	or c

HandleState31::
	ld a, $01
	ld [rIE], a
	ld a, [hDelayCounter]
	and a
	ret nz

	call ClearOAM
	xor a
	ld [$ff00+$ef], a
	ld b, $27
	ld c, $79
	call Call_000_11a3
	call JumpResetAudio
	ld a, [$ff00+$d7]
	cp $05
	jr z, jr_000_119e

	ld a, [$ff00+$d8]
	cp $05
	jr z, jr_000_119e

	ld a, $01
	ld [$ff00+$d6], a

jr_000_119e:
	ld a, $16
	ld [hGameState], a
	ret


Call_000_11a3:
	ld a, [hSerialDone]
	and a
	jr z, jr_000_11bc

	xor a
	ld [hSerialDone], a
	ld a, [hMasterSlave]
	cp $29
	ld a, [hRecvBuffer]
	jr nz, jr_000_11c4

	cp b
	jr z, jr_000_11be

	ld a, $02
	ld [hSendBuffer], a
	ld [hSendBufferValid], a

jr_000_11bc:
	pop hl
	ret


jr_000_11be:
	ld a, c
	ld [hSendBuffer], a
	ld [hSendBufferValid], a
	ret


jr_000_11c4:
	cp c
	ret z

	ld a, b
	ld [hSendBuffer], a
	pop hl
	ret

HandleState38::
	call Call_000_1216
	ld hl, $9ce6
	ld de, $147f
	ld b, $07
	call CopyVerticalStrip
	ld hl, $9ce7
	ld de, $1486
	ld b, $07
	call CopyVerticalStrip
	ld hl, $9d08
	ld [hl], $72
	inc l
	ld [hl], $c4
	ld hl, $9d28
	ld [hl], $b7
	inc l
	ld [hl], $b8
	ld de, $27c5
	ld hl, wSpriteList
	ld c, 3
	call LoadSprites
	ld a, $03
	call UpdateNSprites
	ld a, $db
	ld [rLCDC], a
	ld a, $bb
	ld [hDelayCounter], a
	ld a, $27
	ld [hGameState], a
	ld a, $10
	ld [wPlaySong], a
	ret


Call_000_1216:
	call DisableLCD
	ld hl, ShuttleGFX
	ld bc, $1000
	call Call_000_2838
	ld hl, vBGMapB + BG_MAP_WIDTH * BG_MAP_HEIGHT - 1
	call ClearTilemap
	ld hl, $9dc0
	ld de, LaunchpadTilemap
	ld b, 4
	call CopyRowsToTilemap
	ld hl, $9cec
	ld de, $148d
	ld b, 7
	call CopyVerticalStrip
	ld hl, $9ced
	ld de, $1494
	ld b, 7
	call CopyVerticalStrip
	ret

HandleState39::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld hl, wSpriteList sprite 1 + SPRITE_OFFSET_VISIBILITY
	ld [hl], SPRITE_VISIBLE
	ld l, LOW(wSpriteList sprite 2 + SPRITE_OFFSET_VISIBILITY)
	ld [hl], SPRITE_VISIBLE
	ld a, $ff
	ld [hDelayCounter], a
	ld a, $28
	ld [hGameState], a
	ret

HandleState40::
	ld a, [hDelayCounter]
	and a
	jr z, jr_000_1269

	call Call_000_145e
	ret


jr_000_1269:
	ld a, $29
	ld [hGameState], a
	ld hl, $c213
	ld [hl], $35
	ld l, $23
	ld [hl], $35
	ld a, $ff
	ld [hDelayCounter], a
	ld a, " "
	call FillPlayfieldWithTileAndDoSomethingElseImNotSure
	ret

HandleState41::
	ld a, [hDelayCounter]
	and a
	jr z, jr_000_1289

	call Call_000_145e
	ret


jr_000_1289:
	ld a, $02
	ld [hGameState], a
	ld hl, $9d08
	ld b, $2f
	call WriteBInHBlank
	ld hl, $9d09
	call WriteBInHBlank
	ld hl, $9d28
	call WriteBInHBlank
	ld hl, $9d29
	call WriteBInHBlank
	ret

HandleState2::
	ld a, [hDelayCounter]
	and a
	jr nz, jr_000_12db

	ld a, 10
	ld [hDelayCounter], a
	ld hl, $c201
	dec [hl]
	ld a, [hl]
	cp $58
	jr nz, jr_000_12db

	ld hl, $c210
	ld [hl], $00
	inc l
	add $20
	ld [hl+], a
	ld [hl], $4c
	inc l
	ld [hl], $40
	ld l, $20
	ld [hl], $80
	ld a, $03
	call UpdateNSprites
	ld a, $03
	ld [hGameState], a
	ld a, $04
	ld [$dff8], a
	ret


jr_000_12db:
	call Call_000_145e
	ret

HandleState3::
	ld a, [hDelayCounter]
	and a
	jr nz, jr_000_1301

	ld a, $0a
	ld [hDelayCounter], a
	ld hl, $c211
	dec [hl]
	ld l, $01
	dec [hl]
	ld a, [hl]
	cp $d0
	jr nz, jr_000_1301

	ld a, $9c
	ld [hHighscoreNamePtrHi], a
	ld a, $82
	ld [hHighscoreNamePtrLo], a
	ld a, $2c
	ld [hGameState], a
	ret


jr_000_1301:
	ld a, [hFastDropDelayCounter]
	and a
	jr nz, jr_000_1311

	ld a, $06
	ld [hFastDropDelayCounter], a
	ld hl, $c213
	ld a, [hl]
	xor $01
	ld [hl], a

jr_000_1311:
	ld a, $03
	call UpdateNSprites
	ret

HandleState44::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld a, $06
	ld [hDelayCounter], a
	ld a, [hHighscoreNamePtrLo]
	sub $82
	ld e, a
	ld d, $00
	ld hl, $1359
	add hl, de
	push hl
	pop de
	ld a, [hHighscoreNamePtrHi]
	ld h, a
	ld a, [hHighscoreNamePtrLo]
	ld l, a
	ld a, [de]
	call WriteAInHBlank
	push hl
	ld de, $0020
	add hl, de
	ld b, $b6
	call WriteBInHBlank
	pop hl
	inc hl
	ld a, $02
	ld [wPlayPulseSFX], a
	ld a, h
	ld [hHighscoreNamePtrHi], a
	ld a, l
	ld [hHighscoreNamePtrLo], a
	cp $92
	ret nz

	ld a, $ff
	ld [hDelayCounter], a
	ld a, $2d
	ld [hGameState], a
	ret


	or e
	cp h
	dec a
	cp [hl]
	cp e
	or l
	dec e
	or d
	cp l
	or l
	dec e
	ld l, $bc
	dec a
	ld c, $3e

HandleState45::
	ld a, [hDelayCounter]
	and a
	ret nz

	call DisableLCD
	call LoadTileset
	call ClearedLinesListReset
	ld a, $93
	ld [rLCDC], a
	ld a, $05
	ld [hGameState], a
	ret

HandleState52::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld a, $2e
	ld [hGameState], a
	ret

HandleState46::
	call Call_000_1216
	ld de, $27d7
	ld hl, $c200
	ld c, 3
	call LoadSprites
	ld a, [$ff00+$f3]
	ld [$c203], a
	ld a, $03
	call UpdateNSprites
	xor a
	ld [$ff00+$f3], a
	ld a, $db
	ld [rLCDC], a
	ld a, $bb
	ld [hDelayCounter], a
	ld a, $2f
	ld [hGameState], a
	ld a, SONG_ENDING
	ld [wPlaySong], a
	ret

HandleState47::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld hl, $c210
	ld [hl], $00
	ld l, $20
	ld [hl], $00
	ld a, $a0
	ld [hDelayCounter], a
	ld a, $30
	ld [hGameState], a
	ret

HandleState48::
	ld a, [hDelayCounter]
	and a
	jr z, jr_000_13d4

	call Call_000_145e
	ret


jr_000_13d4:
	ld a, $31
	ld [hGameState], a
	ld a, $80
	ld [hDelayCounter], a
	ld a, " "
	call FillPlayfieldWithTileAndDoSomethingElseImNotSure
	ret

HandleState49::
	ld a, [hDelayCounter]
	and a
	jr nz, jr_000_1415

	ld a, $0a
	ld [hDelayCounter], a
	ld hl, $c201
	dec [hl]
	ld a, [hl]
	cp $6a
	jr nz, jr_000_1415

	ld hl, $c210
	ld [hl], $00
	inc l
	add $10
	ld [hl+], a
	ld [hl], $54
	inc l
	ld [hl], $5c
	ld l, $20
	ld [hl], $80
	ld a, $03
	call UpdateNSprites
	ld a, $32
	ld [hGameState], a
	ld a, $04
	ld [$dff8], a
	ret


jr_000_1415:
	call Call_000_145e
	ret

HandleState50::
	ld a, [hDelayCounter]
	and a
	jr nz, jr_000_1433

	ld a, $0a
	ld [hDelayCounter], a
	ld hl, $c211
	dec [hl]
	ld l, $01
	dec [hl]
	ld a, [hl]
	cp $e0
	jr nz, jr_000_1433

	ld a, $33
	ld [hGameState], a
	ret


jr_000_1433:
	ld a, [hFastDropDelayCounter]
	and a
	jr nz, jr_000_1443

	ld a, $06
	ld [hFastDropDelayCounter], a
	ld hl, $c213
	ld a, [hl]
	xor $01
	ld [hl], a

jr_000_1443:
	ld a, $03
	call UpdateNSprites
	ret

HandleState51::
	call DisableLCD
	call LoadTileset
	call JumpResetAudio
	call ClearedLinesListReset
	ld a, $93
	ld [rLCDC], a
	ld a, $10
	ld [hGameState], a
	ret


Call_000_145e:
	ld a, [hFastDropDelayCounter]
	and a
	ret nz

	ld a, $0a
	ld [hFastDropDelayCounter], a
	ld a, $03
	ld [$dff8], a
	ld b, $02
	ld hl, wSpriteList sprite 1

jr_000_1470:
	ld a, [hl]
	xor $80
	ld [hl], a
	ld l, $20
	dec b
	jr nz, jr_000_1470

	ld a, $03
	call UpdateNSprites
	ret


	jp nz, $caca

	jp z, $caca

	jp z, $cbc3

	ld e, b
	ld c, b
	ld c, b
	ld c, b
	ld c, b
	ret z

	ld [hl], e
	ld [hl], e
	ld [hl], e
	ld [hl], e
	ld [hl], e
	ld [hl], e
	ret

	ld [hl], h
	ld [hl], h
	ld [hl], h
	ld [hl], h
	ld [hl], h
	ld [hl], h

; Arrange a list of tiles vertically on the tilemap
; Input:
;   B = tile count
;   DE = tile list pointer
;   HL = tilemap pointer
; Output: none
; Clobbers A, B, DE, and HL
CopyVerticalStrip::
	ld a, [de]
	ld [hl], a
	inc de
	push de
	ld de, BG_MAP_WIDTH
	add hl, de
	pop de
	dec b
	jr nz, CopyVerticalStrip
	ret

INCLUDE "menus.asm"

; hl = wSpriteList pointer
; de = sprite list in ROM
; c = sprite count
LoadSprites::
	push hl
	ld b, 6

.inner_loop:
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .inner_loop

	pop hl
	ld a, SPRITE_SIZE
	add l
	ld l, a
	dec c
	jr nz, LoadSprites

	ld [hl], SPRITE_HIDDEN
	ret

ClearOAM::
	xor a
	ld hl, wOAMBuffer
	ld b, wOAMBuffer_End - wOAMBuffer
.loop:
	ld [hl+], a
	dec b
	jr nz, .loop
	ret

INCLUDE "highscores.asm"

WriteAInHBlank:
	ld b, a

WriteBInHBlank:
	ld a, [rSTAT]
	and STATF_MODE
	jr nz, WriteBInHBlank

	ld [hl], b
	ret

LoadPlayfield::
	call DisableLCD
	xor a
	assert SPRITE_VISIBLE == 0
	ld [wSpriteList sprite 1 + SPRITE_OFFSET_VISIBILITY], a
	ld [hLockdownStage], a
	ld [hBlinkCounter], a
	ld [hCollisionOccured_NeverRead], a
	ld [hFailedTetrominoPlacements], a
	ld [$ff00+$9f], a
	ld a, " "
	call FillPlayfieldWithTileAndDoSomethingElseImNotSure
	call Call_000_204d
	call ResetGameplayVariablesMaybe
	xor a
	ld [hRowToShift], a
IF !DEF(INTERNATIONAL)
	ld [$ff00+$e7], a
ENDC
	call ClearOAM
	ld a, [hGameType]
	ld de, $403f
	ld hl, hTypeBLevel
	cp GAME_TYPE_B
	ld a, $50
	jr z, .got_game_type_stuff
	ld a, $f1
	ld hl, hTypeALevel
	ld de, $3ed7
.got_game_type_stuff:
	push de
	ld [$ff00+$e6], a
	ld a, [hl]
	ld [hLevel], a
	call LoadTilemapA
	pop de
	ld hl, vBGMapB
	call LoadTilemap
	ld de, $288d
	ld hl, $9c63
	ld c, 10
	call Copy8TilesWide
	ld h, $98
	ld a, [$ff00+$e6]
	ld l, a
	ld a, [$ff00+$a9]
	ld [hl], a
	ld h, $9c
	ld [hl], a
	ld a, [hStartAtLevel10]
	and a
	jr z, jr_000_1ad7

	inc hl
	ld [hl], $27
	ld h, $98
	ld [hl], $27

jr_000_1ad7:
	ld hl, wSpriteList sprite SPRITEPOS_CURRENT_TETROMINO
	ld de, CurrentTetrominoSpriteList
	call LoadSingleSprite
	ld hl, wSpriteList sprite SPRITEPOS_NEXT_TETROMINO
	ld de, NextTetrominoSpriteList
	call LoadSingleSprite
	ld hl, $9951
	ld a, [hGameType]
	cp GAME_TYPE_B
	ld a, $25
	jr z, jr_000_1af5

	xor a

jr_000_1af5:
	ld [$ff00+$9e], a
	and $0f
	ld [hl-], a
	jr z, jr_000_1afe

	ld [hl], $02

jr_000_1afe:
	call Call_000_1b43
	call SpawnNewTetromino
	call SpawnNewTetromino
	call SpawnNewTetromino
IF DEF(INTERNATIONAL)
	ld a, [$c0de]
	and a
	jr z, .skip
	ld a, SPRITE_HIDDEN
	ld [wSpriteList sprite 1 + SPRITE_OFFSET_VISIBILITY], a
.skip
ENDC
	call UpdateCurrentTetromino
	xor a
	ld [hBuffer], a
	ld a, [hGameType]
	cp GAME_TYPE_B
	jr nz, jr_000_1b3b

	ld a, 52
	ld [hGravityCounter], a

	; display the "high" value on screen
	ld a, [hTypeBHigh]
	coord hl, vBGMapA, 16, 5
	ld [hl], a
	coordh h, vBGMapB, 16, 5
	ld [hl], a
	and a
	jr z, jr_000_1b3b

	ld b, a
	ld a, [hDemoNumber]
	and a
	jr z, .not_demo

	call Call_000_1b76
	jr jr_000_1b3b

.not_demo:
	ld a, b
	ld de, hGameType
	ld hl, $9a02
	call Call_000_1bc3

jr_000_1b3b:
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	assert STATE_GAMEPLAY == 0
	xor a
	ld [hGameState], a
	ret


Call_000_1b43:
	ld a, [$ff00+$a9]
	ld e, a
	ld a, [hStartAtLevel10]
	and a
	jr z, jr_000_1b55

	ld a, $0a
	add e
	cp $15
	jr c, jr_000_1b54

	ld a, $14

jr_000_1b54:
	ld e, a

jr_000_1b55:
	ld hl, $1b61
	ld d, $00
	add hl, de
	ld a, [hl]
	ld [hGravityCounter], a
	ld [hFallingSpeed], a
	ret


	inc [hl]
	jr nc, jr_000_1b90

	jr z, jr_000_1b8a

	jr nz, jr_000_1b83

	dec d
	DB $10
	ld a, [bc]
	add hl, bc
	ld [$0607], sp
	dec b
	dec b
	inc b
	inc b
	inc bc
	inc bc
	ld [bc], a

Call_000_1b76:
	ld hl, $99c2
	ld de, $1b9b
	ld c, $04

jr_000_1b7e:
	ld b, $0a
	push hl

jr_000_1b81:
	ld a, [de]
	ld [hl], a

jr_000_1b83:
	push hl
	ld a, h
	add $30
	ld h, a
	ld a, [de]
	ld [hl], a

jr_000_1b8a:
	pop hl
	inc l
	inc de
	dec b
	jr nz, jr_000_1b81

jr_000_1b90:
	pop hl
	push de
	ld de, $0020
	add hl, de
	pop de
	dec c
	jr nz, jr_000_1b7e

	ret


	add l
	cpl
	add d
	add [hl]
	add e
	cpl
	cpl
	add b
	add d
	add l
	cpl
	add d
	add h
	add d
	add e
	cpl
	add e
	cpl
	add a
	cpl
	cpl
	add l
	cpl
	add e
	cpl
	add [hl]
	add d
	add b
	add c
	cpl
	add e
	cpl
	add [hl]
	add e
	cpl
	add l
	cpl
	add l
	cpl
	cpl

Call_000_1bc3:
	ld b, a

jr_000_1bc4:
	dec b
	jr z, jr_000_1bca

	add hl, de
	jr jr_000_1bc4

jr_000_1bca:
	ld a, [rDIV]
	ld b, a

jr_000_1bcd:
	ld a, $80

jr_000_1bcf:
	dec b
	jr z, jr_000_1bda

	cp $80
	jr nz, jr_000_1bcd

	ld a, $2f
	jr jr_000_1bcf

jr_000_1bda:
	cp $2f
	jr z, jr_000_1be6

	ld a, [rDIV]
	and $07
	or $80
	jr jr_000_1be8

jr_000_1be6:
	ld [hBuffer], a

jr_000_1be8:
	push af
	ld a, l
	and $0f
	cp $0b
	jr nz, jr_000_1bfb

	ld a, [hBuffer]
	cp $2f
	jr z, jr_000_1bfb

	pop af
	ld a, $2f
	jr jr_000_1bfc

jr_000_1bfb:
	pop af

jr_000_1bfc:
	ld [hl], a
	push hl
	push af
	ld a, [hMultiplayer]
	and a
	jr nz, jr_000_1c08

	ld de, $3000
	add hl, de

jr_000_1c08:
	pop af
	ld [hl], a
	pop hl
	inc hl

Call_000_1c0c:
	ld a, l
	and $0f
	cp $0c
	jr nz, jr_000_1bca

	xor a
	ld [hBuffer], a
	ld a, h
	and $0f
	cp $0a
	jr z, jr_000_1c23

jr_000_1c1d:
	ld de, $0016
	add hl, de
	jr jr_000_1bca

jr_000_1c23:
	ld a, l
	cp $2c
	jr nz, jr_000_1c1d
	ret

HandleGameplay::
	call Call_000_1c68
	ld a, [$ff00+$ab]
	and a
	ret nz

	call CheckDemoEnd
	call HandleDemoPlayback
	call HandleDemoRecording
	call HandleGameplayMovement
	call HandleGravity
	call LookForFullLines
	call HandleLockdownTransferToTilemap
	call HandleRowShift
	call Call_000_1fec
	call RestoreInputsAfterDemoFrame
	ret

jr_000_1c4f:
	bit 2, a
	ret z

	ld a, [$c0de]
	xor $01
	ld [$c0de], a
	jr z, jr_000_1c65

	ld a, SPRITE_HIDDEN

jr_000_1c5e:
	ld [wSpriteList sprite 1 + SPRITE_OFFSET_VISIBILITY], a
	call UpdateNextTetromino
	ret

jr_000_1c65:
	xor a
	assert SPRITE_VISIBLE == 0
	jr jr_000_1c5e

Call_000_1c68:
	ld a, [hKeysHeld]
	and A_BUTTON | B_BUTTON | SELECT | START
	cp A_BUTTON | B_BUTTON | SELECT | START
	jp z, SoftReset

	ld a, [hDemoNumber]
	and a
	ret nz

	ld a, [hKeysPressed]
	bit START_BIT, a
	jr z, jr_000_1c4f

	ld a, [hMultiplayer]
	and a
	jr nz, .unk1cc5

	ld hl, rLCDC
	ld a, [$ff00+$ab]
	xor 1
	ld [$ff00+$ab], a
	jr z, .unk1cb5

	set 3, [hl]
	ld a, $01
	ld [$df7f], a
	ld hl, $994e
	ld de, $9d4e
	ld b, $04

.unk1c9a:
	ld a, [rSTAT]
	and $03
	jr nz, .unk1c9a

	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .unk1c9a

	ld a, SPRITE_HIDDEN

.unk1ca8:
	ld [wSpriteList sprite 1], a

.unk1cab:
	ld [wSpriteList sprite 0], a
	call UpdateCurrentTetromino
	call UpdateNextTetromino
	ret

.unk1cb5:
	res 3, [hl]
	ld a, $02
	ld [$df7f], a
	ld a, [$c0de]
	and a
	jr z, .unk1ca8

	xor a
	jr .unk1cab

.unk1cc5:
	ld a, [hMasterSlave]
	cp $29
	ret nz

	ld a, [$ff00+$ab]
	xor $01
	ld [$ff00+$ab], a
	jr z, jr_000_1d05

	ld a, $01
	ld [$df7f], a
	ld a, [hRecvBuffer]
	ld [$ff00+$f2], a
	ld a, [hSendBuffer]
	ld [$ff00+$f1], a
	call Call_000_1d26
	ret

Call_000_1ce3:
	ld a, [$ff00+$ab]
	and a
	ret z

	ld a, [hSerialDone]
	jr z, jr_000_1d24

	xor a
	ld [hSerialDone], a
	ld a, [hMasterSlave]
	cp $29
	jr nz, jr_000_1cfc

	ld a, $94
	ld [hSendBuffer], a
	ld [hSendBufferValid], a
	pop hl
	ret


jr_000_1cfc:
	xor a
	ld [hSendBuffer], a
	ld a, [hRecvBuffer]
	cp $94
	jr z, jr_000_1d24

jr_000_1d05:
	ld a, [$ff00+$f2]
	ld [hRecvBuffer], a
	ld a, [$ff00+$f1]
	ld [hSendBuffer], a
	ld a, $02
	ld [$df7f], a
	xor a
	ld [$ff00+$ab], a
	ld hl, $98ee
	ld b, $8e
	ld c, $05

jr_000_1d1c:
	call WriteBInHBlank
	inc l
	dec c
	jr nz, jr_000_1d1c

	ret


jr_000_1d24:
	pop hl
	ret


Call_000_1d26:
	ld hl, $98ee
	ld c, $05
	ld de, $1d38

jr_000_1d2e:
	ld a, [de]
	call WriteAInHBlank
	inc de
	inc l
	dec c
	jr nz, jr_000_1d2e
	ret

	add hl, de
	ld a, [bc]
	ld e, $1c
	db $0e

HandleGameOver::
	ld a, SPRITE_HIDDEN
	ld [wSpriteList sprite SPRITEPOS_CURRENT_TETROMINO + SPRITE_OFFSET_VISIBILITY], a
	ld [wSpriteList sprite SPRITEPOS_NEXT_TETROMINO + SPRITE_OFFSET_VISIBILITY], a
	call UpdateCurrentTetromino
	call UpdateNextTetromino
	xor a
	ld [hLockdownStage], a
	ld [hBlinkCounter], a
	call ClearedLinesListReset
	ld a, $87
	call FillPlayfieldWithTileAndDoSomethingElseImNotSure
	ld a, $46
	ld [hDelayCounter], a
	ld a, $0d
	ld [hGameState], a
	ret

HandleState4::
	ld a, [hKeysPressed]
	bit 0, a
	jr nz, jr_000_1d6a

	bit 3, a
	ret z

jr_000_1d6a:
	xor a
	ld [hRowToShift], a
	ld a, [hMultiplayer]
	and a
	ld a, $16
	jr nz, jr_000_1d7e

	ld a, [$ff00+$c0]
	cp $37
	ld a, $10
	jr z, jr_000_1d7e

	ld a, $12

jr_000_1d7e:
	ld [hGameState], a
	ret

HandleState5::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld hl, $c802
	ld de, $28dd
	call Call_000_2858
	ld a, [$ff00+$c3]
	and a
	jr z, jr_000_1dc1

	ld de, $0040
	ld hl, $c827
	call Call_000_1ddf
	ld de, $0100
	ld hl, $c887
	call Call_000_1ddf
	ld de, $0300
	ld hl, $c8e7
	call Call_000_1ddf
	ld de, $1200
	ld hl, $c947
	call Call_000_1ddf
	ld hl, $c0a0
	ld b, $03
	xor a

jr_000_1dbd:
	ld [hl+], a
	dec b
	jr nz, jr_000_1dbd

jr_000_1dc1:
	ld a, $80
	ld [hDelayCounter], a
	ld a, SPRITE_HIDDEN
	ld [wSpriteList sprite SPRITEPOS_CURRENT_TETROMINO + SPRITE_OFFSET_VISIBILITY], a
	ld [wSpriteList sprite SPRITEPOS_NEXT_TETROMINO + SPRITE_OFFSET_VISIBILITY], a
	call UpdateCurrentTetromino
	call UpdateNextTetromino
	call JumpResetAudio
	ld a, $25
	ld [$ff00+$9e], a
	ld a, $0b
	ld [hGameState], a
	ret


Call_000_1ddf:
	push hl
	ld hl, $c0a0
	ld b, $03
	xor a

jr_000_1de6:
	ld [hl+], a
	dec b
	jr nz, jr_000_1de6

	ld a, [$ff00+$c3]
	ld b, a
	inc b

jr_000_1dee:
	ld hl, wScore
	call AddBCD
	dec b
	jr nz, jr_000_1dee

	pop hl
	ld b, $03
	ld de, $c0a2

jr_000_1dfd:
	ld a, [de]
	and $f0
	jr nz, jr_000_1e0c

	ld a, [de]
	and $0f
	jr nz, jr_000_1e12

	dec e
	dec b
	jr nz, jr_000_1dfd

	ret


jr_000_1e0c:
	ld a, [de]
	and $f0
	swap a
	ld [hl+], a

jr_000_1e12:
	ld a, [de]
	and $0f
	ld [hl+], a
	dec e
	dec b
	jr nz, jr_000_1e0c

	ret

HandleState11::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld a, $01
	ld [$c0c6], a
	ld a, $05
	ld [hDelayCounter], a
	ret

HandleState34::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld hl, $c802
	ld de, VictoryDanceTilemap
	call Call_000_2858
	call ClearOAM
	ld hl, $c200
	ld de, $2789
	ld c, $0a
	call LoadSprites
	ld a, $10
	ld hl, $c266
	ld [hl], a
	ld l, $76
	ld [hl], a
	ld hl, $c20e
	ld de, $1e8c
	ld b, $0a

jr_000_1e55:
	ld a, [de]
	ld [hl+], a
	ld [hl+], a
	inc de
	push de
	ld de, $000e
	add hl, de
	pop de
	dec b
	jr nz, jr_000_1e55

	ld a, [$ff00+$c4]
	cp $05
	jr nz, jr_000_1e6a

	ld a, $09

jr_000_1e6a:
	inc a
	ld b, a
	ld hl, $c200
	ld de, $0010
	xor a

jr_000_1e73:
	ld [hl], a
	add hl, de
	dec b
	jr nz, jr_000_1e73

	ld a, [$ff00+$c4]
	add $0a
	ld [wPlaySong], a
	ld a, $25
	ld [$ff00+$9e], a
	ld a, $1b
	ld [hDelayCounter], a
	ld a, $23
	ld [hGameState], a
	ret


	inc e
	rrca
	ld e, $32
	jr nz, jr_000_1eaa

	ld h, $1d
	jr z, jr_000_1ec1

jr_000_1e96:
	ld a, $0a
	call UpdateNSprites
	ret

HandleState35::
	ld a, [hDelayCounter]
	cp $14
	jr z, jr_000_1e96

	and a
	ret nz

	ld hl, $c20e
	ld de, $0010

jr_000_1eaa:
	ld b, $0a

jr_000_1eac:
	push hl
	dec [hl]
	jr nz, jr_000_1ec5

	inc l
	ld a, [hl-]
	ld [hl], a
	ld a, l
	and $f0
	or $03
	ld l, a
	ld a, [hl]
	xor $01
	ld [hl], a
	cp $50
	jr z, jr_000_1ee4

jr_000_1ec1:
	cp $51
	jr z, jr_000_1eea

jr_000_1ec5:
	pop hl
	add hl, de
	dec b
	jr nz, jr_000_1eac

	ld a, $0a
	call UpdateNSprites
	ld a, [wCurSong]
	and a
	ret nz

	call ClearOAM
	ld a, [$ff00+$c4]
	cp $05
	ld a, $26
	jr z, jr_000_1ee1

	ld a, $05

jr_000_1ee1:
	ld [hGameState], a
	ret


jr_000_1ee4:
	dec l
	dec l
	ld [hl], $67
	jr jr_000_1ec5

jr_000_1eea:
	dec l
	dec l
	ld [hl], $5d
	jr jr_000_1ec5

jr_000_1ef0:
	xor a
	ld [$c0c6], a
	ld de, $c0c0
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	or l
	jp z, Jump_000_268e

	dec hl
	ld a, h
	ld [de], a
	dec de
	ld a, l
	ld [de], a
	ld de, $0001
	ld hl, $c0c2
	push de
	call AddBCD
	ld de, $c0c4
	ld hl, $99a5
	call LazyUpdateScore
	xor a
	ld [hDelayCounter], a
	pop de
	ld hl, wScore
	call AddBCD
	ld de, $c0a2
	ld hl, $9a25
	call DisplayBCD_ThreeBytes
	ld a, PULSESFX_CONFIRM_BEEP
	ld [wPlayPulseSFX], a
	ret

VBlank_TypeBScoringScreen::
	ld a, [wTypeBScoring_DoTick]
	and a
	ret z

	ld a, [wTypeBScoring_DisplayStage]
	cp 4
	jr z, jr_000_1ef0

	ld de, $0040
	coord bc, vBGMapA, 3, 1
	ld hl, wTypeBScoring_SingleCount
	and a
	jr z, .got_scoring_info

	ld de, $0100
	coord bc, vBGMapA, 3, 4
	ld hl, wTypeBScoring_DoubleCount
	cp 1
	jr z, .got_scoring_info

	ld de, $0300
	coord bc, vBGMapA, 3, 7
	ld hl, wTypeBScoring_TripleCount
	cp 2
	jr z, .got_scoring_info

	ld de, $1200
	coord bc, vBGMapA, 3, 10
	ld hl, wTypeBScoring_TetrisCount

.got_scoring_info:
	call Call_000_262d ; why no TCO?
	ret

HandleState12::
	ld a, [hKeysPressed]
	and a
	ret z

	ld a, $02
	ld [hGameState], a
	ret

HandleState13::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld a, SONG_A_END_JINGLE
	ld [wPlaySong], a
	ld a, [hMultiplayer]
	and a
	jr z, .skip_multiplayer

	ld a, 63
	ld [hDelayCounter], a
	ld a, $1b ; TODO: why this value?
	ld [hSerialDone], a
	jr jr_000_1fc9

.skip_multiplayer:
	ld a, " "
	call FillPlayfieldWithTileAndDoSomethingElseImNotSure
	ld hl, $c843
	ld de, GameoverTilemap
	ld c, 7
	call Copy8TilesWide
	ld hl, $c983
	ld de, PleaseTryAgainTilemap
	ld c, 6
	call Copy8TilesWide
	ld a, [hGameType]
	cp GAME_TYPE_A
	jr nz, jr_000_1fc7

	ld hl, wScore + SCORE_SIZE - 1
	ld a, [hl]
	ld b, $58
	cp $15
	jr nc, jr_000_1fcc

	inc b
	cp $10
	jr nc, jr_000_1fcc

	inc b
	cp $05
	jr nc, jr_000_1fcc

jr_000_1fc7:
	ld a, $04

jr_000_1fc9:
	ld [hGameState], a
	ret

jr_000_1fcc:
	ld a, b
	ld [$ff00+$f3], a
	ld a, $90
	ld [hDelayCounter], a
	ld a, $34
	ld [hGameState], a
	ret

Copy8TilesWide::
.row_loop:
	ld b, 8
	push hl

.tile_loop:
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .tile_loop

	pop hl
	push de
	ld de, BG_MAP_WIDTH
	add hl, de
	pop de
	dec c
	jr nz, .row_loop
	ret


Call_000_1fec:
	ld a, [hGameType]
	cp GAME_TYPE_A
	ret nz

	ld a, [hGameState]
	assert STATE_GAMEPLAY == 0
	and a
	ret nz

	ld a, [hRowToShift]
	cp $05
	ret nz

	ld hl, $c0ac
	ld bc, $0005
	ld a, [hl]
	ld de, $0040
	and a
	jr nz, jr_000_201e

	add hl, bc
	ld a, [hl]
	ld de, $0100
	and a
	jr nz, jr_000_201e

	add hl, bc
	ld a, [hl]
	ld de, $0300
	and a
	jr nz, jr_000_201e

	add hl, bc
	ld de, $1200
	ld a, [hl]
	and a
	ret z

jr_000_201e:
	ld [hl], $00
	ld a, [$ff00+$a9]
	ld b, a
	inc b

jr_000_2024:
	push bc
	push de
	ld hl, wScore
	call AddBCD
	pop de
	pop bc
	dec b
	jr nz, jr_000_2024

	ret

FillPlayfieldWithTileAndDoSomethingElseImNotSure::
	push af
	ld a, $02
	ld [hRowToShift], a
	pop af
	; fallthrough
FillPlayfieldWithTile::
	coord hl, wTileMap, 2, 0
	ld c, SCREEN_HEIGHT
	ld de, BG_MAP_WIDTH
.row_loop:
	push hl
	ld b, PLAYFIELD_WIDTH
.inner_loop:
	ld [hl+], a
	dec b
	jr nz, .inner_loop

	pop hl
	add hl, de
	dec c
	jr nz, .row_loop
	ret


Call_000_204d:
	ld hl, $cbc2
	ld de, $0016
	ld c, $02
	ld a, $2f

jr_000_2057:
	ld b, $0a

jr_000_2059:
	ld [hl+], a
	dec b
	jr nz, jr_000_2059

	add hl, de
	dec c
	jr nz, jr_000_2057

	ret

; Move the piece from the next tetromino box to the top of the screen. Put hNextNextPiece in that
; box, and generate a new value for the variable.
; Input: none
; Output: none
; Clobbers all registers
SpawnNewTetromino::
	ld hl, wSpriteList sprite 0
	ld [hl], SPRITE_VISIBLE
	inc l
	ld [hl], INITIAL_TETROMINO_Y
	inc l
	ld [hl], INITIAL_TETROMINO_X
	inc l
	ld a, [wSpriteList sprite SPRITEPOS_NEXT_TETROMINO + SPRITE_OFFSET_ID]
	ld [hl], a
	and $ff ^ SPRITE_ID_ROTATION_MASK
	ld c, a
	ld a, [hDemoNumber]
	and a
	jr nz, .predefined

	ld a, [hMultiplayer]
	and a
	jr z, .random

.predefined:
	ld h, HIGH(wRandomness) ; aligned to a 256-byte boundary
	ld a, [hRandomnessPtrLo]
	ld l, a
	ld e, [hl]
	inc hl
	ld a, h ; so it didn't occur to you to just use the overflow?
	cp HIGH(wRandomness) + 1
	jr nz, .save_pointer
	ld hl, wRandomness
.save_pointer: ; </bullshit>
	ld a, l
	ld [hRandomnessPtrLo], a
	ld a, [$ff00+$d3]
	and a
	jr z, .end

	or $80
	ld [$ff00+$d3], a
	jr .end

.random:
	ld h, 3
.try_again:
	ld a, [rDIV]
	ld b, a
.back_to_zero:
	xor a
.division_loop:
	dec b
	jr z, .try_next_next_piece

	inc a ; just use a normal add instruction!
	inc a
	inc a
	inc a
	cp SPRITE_TYPE_A ; first sprite that's not a tetromino
	jr z, .back_to_zero
	jr .division_loop

.try_next_next_piece:
	ld d, a
	ld a, [hNextNextPiece]
	ld e, a
	dec h ; accept any piece on the third try
	jr z, .got_next_next_piece

	; e - will be shown as the next piece in a moment
	; d - candidate for a hidden next next piece
	; c - the piece just moved to the top of the playfield
	or d
	or c
	and $ff ^ SPRITE_ID_ROTATION_MASK ; this is guaranteed to be a noop
	cp c
	jr z, .try_again
.got_next_next_piece:
	ld a, d
	ld [hNextNextPiece], a
.end:
	ld a, e
	ld [wSpriteList sprite SPRITEPOS_NEXT_TETROMINO + SPRITE_OFFSET_ID], a
	call UpdateNextTetromino ; could do it after the hGravityCounter copy and TCO
	ld a, [hFallingSpeed]
	ld [hGravityCounter], a
	ret

Gameplay_HoldingDown:
	ld a, [wDidntUseFastDropOnThisPiece]
	and a
	jr z, .not_first_time

	; make it so you need to release and start holding again for a new piece
	ld a, [hKeysPressed]
	and D_DOWN | D_LEFT | D_RIGHT
	cp D_DOWN
	jr nz, HandleGravity.after_joypad_check

	xor a
	ld [wDidntUseFastDropOnThisPiece], a
.not_first_time:
	ld a, [hFastDropDelayCounter]
	and a
	jr nz, HandleGravity.end

	ld a, [hLockdownStage]
	and a
	jr nz, HandleGravity.end

	ld a, [hRowToShift]
	and a
	jr nz, HandleGravity.end

	ld a, FASTDROP_RATE
	ld [hFastDropDelayCounter], a
	ld hl, hFastDropDistance
	inc [hl]
	jr HandleGravity.apply_gravity

HandleGravity::
	ld a, [hKeysHeld]
	and D_DOWN | D_LEFT | D_RIGHT
	cp D_DOWN
	jr z, Gameplay_HoldingDown

.after_joypad_check:
	ld hl, hFastDropDistance ; normal xor a / ldh is shorter, faster, and less unusual
	ld [hl], 0
	ld a, [hGravityCounter]
	and a
	jr z, .timing_ok
	dec a
	ld [hGravityCounter], a
.end:
	call UpdateCurrentTetromino ; why no TCO?
	ret

.timing_ok:
	ld a, [hLockdownStage]
	cp LOCKDOWN_STAGE_BLINK
	ret z

	ld a, [hRowToShift]
	and a
	ret nz

	ld a, [hFallingSpeed]
	ld [hGravityCounter], a

.apply_gravity:
	ld hl, wSpriteList sprite 0 + SPRITE_OFFSET_Y
	ld a, [hl]
	ld [hBuffer], a
	add 8
	ld [hl], a
	call UpdateCurrentTetromino
	call CheckCollision
	and a
	ret z

	; lock the tetromino in place
	ld a, [hBuffer]
	ld hl, wSpriteList sprite 0 + SPRITE_OFFSET_Y
	ld [hl], a
	call UpdateCurrentTetromino
	ld a, LOCKDOWN_STAGE_TRANSFER_TO_TILEMAP
	ld [hLockdownStage], a
	ld [wDidntUseFastDropOnThisPiece], a
	ld a, [hFastDropDistance]
	and a
	jr z, .scoring_done ; didn't fast drop? then there's no points to award

	ld c, a
	ld a, [hGameType]
	cp GAME_TYPE_A
	jr z, .apply_type_a_score

	ld de, wTypeBScoring_Drop
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a

	ld b, 0
	dec c
	add hl, bc

	ld a, h
	ld [de], a
	ld a, l
	dec de
	ld [de], a

.scoring_applied:
	xor a
	ld [hFastDropDistance], a

.scoring_done:
	ld a, [wSpriteList sprite 0 + SPRITE_OFFSET_Y]
	cp INITIAL_TETROMINO_Y
	ret nz

	ld a, [wSpriteList sprite 0 + SPRITE_OFFSET_X]
	cp INITIAL_TETROMINO_X
	ret nz

	ld hl, hFailedTetrominoPlacements
	ld a, [hl]
	cp 1
	jr nz, .no_game_over_yet

	call JumpResetAudio
	ld a, STATE_GAME_OVER
	ld [hGameState], a
	ld a, WAVESFX_GAME_OVER
	ld [wPlayWaveSFX], a
	ret

.no_game_over_yet:
	inc [hl]
	ret

.apply_type_a_score:
	xor a

.score_loop:
	dec c
	jr z, .got_score

	inc a
	daa
	jr .score_loop

.got_score:
	ld e, a
	ld d, 0
	ld hl, wScore
	call AddBCD
	ld a, $01
	ld [$c0ce], a
	jr .scoring_applied

LookForFullLines::
	ld a, [hLockdownStage]
	cp LOCKDOWN_STAGE_LOOK_FOR_FULL_LINES
	ret nz

	ld a, NOISESFX_LOCKDOWN
	ld [wPlayNoiseSFX], a
	xor a
	ld [hBuffer], a
	ld de, wClearedLinesList
	coord hl, wTileMap, 2, 2 ; TODO: why row 2 instead of 0?
	ld b, SCREEN_HEIGHT - 2

.row_loop:
	ld c, PLAYFIELD_WIDTH

	push hl
.inner_loop:
	ld a, [hl+]
	cp " "
	jp z, .row_not_full
	dec c
	jr nz, .inner_loop
	pop hl

	ld a, h
	ld [de], a
	inc de

	ld a, l
	ld [de], a
	inc de

	ld a, [hBuffer]
	inc a
	ld [hBuffer], a

.next_row:
	push de
	ld de, BG_MAP_WIDTH
	add hl, de
	pop de
	dec b
	jr nz, .row_loop

	ld a, LOCKDOWN_STAGE_BLINK
	ld [hLockdownStage], a
	assert LOCKDOWN_STAGE_BLINK == 3
	dec a
	ld [hDelayCounter], a
	ld a, [hBuffer]
	and a
	ret z

	; found full lines
	ld b, a
	ld hl, hLineCount
	ld a, [hGameType]
	cp GAME_TYPE_B
	jr z, .type_b

IF !DEF(INTERNATIONAL)
	ld a, [$ff00+$e7] ; TODO
	add b
	ld [$ff00+$e7], a
ENDC

	ld a, b
	add [hl]
	daa
	ld [hl+], a
	ld a, 0
	adc [hl]
	daa
	ld [hl], a
	jr nc, .line_count_done

	ld [hl], $99 ; cap at 9999
	dec hl
	ld [hl], $99
	jr .line_count_done

.type_b:
	ld a, [hl]
	or a ; useless
	sub b
	jr z, .zero_cap
	jr c, .zero_cap

	daa
	ld [hl], a
	and $f0
	cp $90
	jr z, .zero_cap

.line_count_done:
	ld a, b
	ld c, PULSESFX_LINE_CLEAR
	ld hl, wTypeBScoring_SingleCount
	ld b, 0 ; could just dec b and remove all the loads below (apart from the tetris one)
	cp 1
	jr z, .end

	ld hl, wTypeBScoring_DoubleCount
	ld b, 1
	cp 2
	jr z, .end

	ld hl, wTypeBScoring_TripleCount
	ld b, 2
	cp 3
	jr z, .end

	ld hl, wTypeBScoring_TetrisCount
	ld b, 4
	ld c, PULSESFX_TETRIS

.end:
	inc [hl]
	ld a, b
	ld [$ff00+$dc], a ; TODO
	ld a, c
	ld [wPlayPulseSFX], a
	ret

.row_not_full:
	pop hl
	jr .next_row

.zero_cap:
	xor a
	ld [hLineCount], a
	jr .line_count_done

VBlank_HandleLineClearBlink::
	ld a, [hLockdownStage]
	cp LOCKDOWN_STAGE_BLINK
	ret nz

	ld a, [hDelayCounter]
	and a
	ret nz

	ld de, wClearedLinesList
	ld a, [hBlinkCounter]
	bit 0, a
	jr nz, .show_line_loop

	ld a, [de]
	and a
	jr z, .no_line_clear
.tile_fill_loop:
	sub HIGH(wTileMap - vBGMapA) ; convert to VRAM address
	ld h, a
	inc de
	ld a, [de]
	ld l, a

	ld a, [hBlinkCounter]
	cp 6
	ld a, $8c
	jr nz, .got_fill_tile
	ld a, " "
.got_fill_tile:
	ld c, PLAYFIELD_WIDTH
.tile_fill_loop_inner:
	ld [hl+], a
	dec c
	jr nz, .tile_fill_loop_inner

	inc de
	ld a, [de]
	and a
	jr nz, .tile_fill_loop

.end:
	ld a, [hBlinkCounter]
	inc a
	ld [hBlinkCounter], a
	cp 7
	jr z, .finished_blinking

	ld a, 10
	ld [hDelayCounter], a
	ret

.finished_blinking:
	xor a
	ld [hBlinkCounter], a
	ld a, 13
	ld [hDelayCounter], a
	ld a, 1
	ld [hRowToShift], a

.finish_lockdown:
	assert LOCKDOWN_STAGE_IDLE == 0
	xor a
	ld [hLockdownStage], a
	ret

.show_line_loop:
	ld a, [de]
	ld h, a
	sub HIGH(wTileMap - vBGMapA)
	ld c, a
	inc de
	ld a, [de]
	ld l, a
	ld b, PLAYFIELD_WIDTH

.show_line_loop_inner:
	ld a, [hl]
	push hl
	ld h, c
	ld [hl], a
	pop hl
	inc hl
	dec b
	jr nz, .show_line_loop_inner

	inc de
	ld a, [de]
	and a
	jr nz, .show_line_loop
	jr .end

.no_line_clear:
	call SpawnNewTetromino
	jr .finish_lockdown

; If the line clear stage calls for it, loop over every cleared line from the top to the bottom,
; and shift every line above it down by one. Finally, the very top line is cleared.
; Input: none
; Output: none
; Clobbers all registers
HandleRowShift::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld a, [hRowToShift]
	cp 1
	ret nz

	ld de, wClearedLinesList
	ld a, [de]

.cleared_line_loop:
	ld h, a
	inc de
	ld a, [de]
	ld l, a

	push de
	push hl
	ld bc, -BG_MAP_WIDTH
	add hl, bc
	pop de

.screen_line_loop:
	push hl
	ld b, PLAYFIELD_WIDTH

.tile_copy_loop:
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .tile_copy_loop

	pop hl
	push hl
	pop de
	ld bc, -BG_MAP_WIDTH
	add hl, bc
	ld a, h
	cp HIGH(wTileMap) - 1
	jr nz, .screen_line_loop

	pop de
	inc de
	ld a, [de]
	and a
	jr nz, .cleared_line_loop

	coord hl, wTileMap, 2, 0
	ld a, " "
	ld b, PLAYFIELD_WIDTH

.clear_loop:
	ld [hl+], a
	dec b
	jr nz, .clear_loop

	call ClearedLinesListReset
	ld a, 2
	ld [hRowToShift], a
	ret

ClearedLinesListReset::
	ld hl, wClearedLinesList
	xor a
	ld b, 9
.loop:
	ld [hl+], a
	dec b
	jr nz, .loop
	ret

rowshift: MACRO
ShiftRow\1::
	ld a, [hRowToShift]
	cp \1
	ret nz

	coord hl, vBGMapA, 2, 19 - \1
	coord de, wTileMap, 2, 19 - \1
	call ShiftRow
ENDM

justrowshift: MACRO
	rowshift \1
	ret
ENDM

	justrowshift 2
	justrowshift 3
	justrowshift 4
	justrowshift 5
	justrowshift 6
	justrowshift 7

	rowshift 8
	ld a, [hMultiplayer]
	and a
	ld a, [hGameState]
	jr nz, .multiplayer

	and a
	ret nz

.end:
	ld a, NOISESFX_LINE_REMOVED
	ld [wPlayNoiseSFX], a
	ret

.multiplayer:
	cp STATE_26
	ret nz

	ld a, [$ff00+$d4]
	and a
	jr z, .end

	ld a, $05
	ld [wPlayPulseSFX], a
	ret

	justrowshift 9
	justrowshift 10
	justrowshift 11
	justrowshift 12
	justrowshift 13
	justrowshift 14
	justrowshift 15

	rowshift 16
	call Call_000_24ab ; why no TCO?
	ret

	rowshift 17
	coord hl, vBGMapB, 13, 3
	call RenderScore
	ld a, 1
	ld [$ff00+$e0], a
	ret

	rowshift 18
	coord hl, vBGMapA, 13, 3
	call RenderScore ; why no TCO?
	ret

ShiftRow19::
	ld a, [hRowToShift]
	cp 19
	ret nz

	ld [wDidntUseFastDropOnThisPiece], a ; redundant - already set by HandleGravity
	coord hl, vBGMapA, 2, 0
	coord de, wTileMap, 2, 0
	call ShiftRow
	xor a
	ld [hRowToShift], a
	ld a, [hMultiplayer]
	and a
	ld a, [hGameState]
	jr nz, .multiplayer

	and a
	ret nz

.unk2449:
	coord hl, vBGMapA, 14, 10
	ld de, hLineCount + 1
	ld c, 2
	ld a, [hGameType]
	cp GAME_TYPE_A
	jr z, .got_line_count_display_params
	coord hl, vBGMapA, 16, 10
	ld de, hLineCount
	ld c, 1
.got_line_count_display_params:
	call DisplayBCD
	ld a, [hGameType]
	cp GAME_TYPE_A
	jr z, .normal

	ld a, [hLineCount]
	and a
	jr nz, .normal

	ld a, 100
	ld [hDelayCounter], a
	ld a, SONG_B_END_JINGLE
	ld [wPlaySong], a
	ld a, [hMultiplayer]
	and a
	jr z, .singleplayer

	ld [$ff00+$d5], a
	ret

.singleplayer:
	ld a, [hTypeBLevel]
	cp 9
	ld a, STATE_05
	jr nz, .got_new_state
	ld a, STATE_34
.got_new_state:
	ld [hGameState], a
	ret

.normal:
	call SpawnNewTetromino
	ret


.multiplayer:
	cp STATE_26
	ret nz

	ld a, [$ff00+$d4]
	and a
	jr z, .unk2449

	xor a
	ld [$ff00+$d4], a
	ret

; If the game is playing, and the game type is A, update the score on the tilemap.
; Input:
;   HL = tilemap pointer
;   hScoreDirty - if set to zero, nothing will be done
RenderScore::
	ld a, [hGameState]
	assert STATE_GAMEPLAY == 0
	and a
	ret nz

	ld a, [hGameType]
	cp GAME_TYPE_A
	ret nz

	ld de, wScore + SCORE_SIZE - 1
	call LazyUpdateScore ; why no TCO?
	ret


Call_000_24ab:
	ld a, [hGameState]
	assert STATE_GAMEPLAY == 0
	and a
	ret nz

	ld a, [hGameType]
	cp GAME_TYPE_A
	ret nz

	ld hl, hLevel
	ld a, [hl]

IF DEF(INTERNATIONAL)
	cp 20
	ret z

	call LevelToBCD
	ld a, [$ff00+$9f]
	ld d, a
	and $f0
	ret nz
	ld a, d
	and $0f
	swap a
	ld d, a
	ld a, [$ff00+$9e]
	and $f0
	swap a
	or d
	cp b
	ret c
	ret z
	inc [hl]
	call LevelToBCD
ELSE
	cp 9
	jr nc, jr_000_24fd

	ld a, [$ff00+$e7]
	cp $0a
	ret c

	sub $0a

jr_000_24c3:
	ld [$ff00+$e7], a
	inc [hl]
	ld a, [hl]
	cp $15
	jr nz, jr_000_24cd

	ld [hl], $14

jr_000_24cd:
	ld b, [hl]
	xor a

jr_000_24cf:
	or a
	inc a
	daa
	dec b
	jr z, jr_000_24d7

	jr jr_000_24cf

jr_000_24d7:
	ld b, a
ENDC
	and $0f
	ld c, a
	ld hl, $98f1

jr_000_24de:
	ld [hl], c
	ld h, $9c
	ld [hl], c
	ld a, b
	and $f0
	jr z, jr_000_24f4

	swap a
	ld c, a
	ld a, l
	cp $f0
	jr z, jr_000_24f4

	ld hl, $98f0
	jr jr_000_24de

jr_000_24f4:
IF DEF(INTERNATIONAL)
	ld a, PULSESFX_LEVELUP
ELSE
	ld a, PULSESFX_CONFIRM_BEEP
ENDC
	ld [wPlayPulseSFX], a
	call Call_000_1b43 ; why no TCO?
	ret

IF !DEF(INTERNATIONAL)
jr_000_24fd:
	ld a, [$ff00+$e7]
	cp $14
	ret c

	sub $14
	jr jr_000_24c3
ELSE
LevelToBCD::
	ld a, [hl]
	ld b, a ; this can be done below
	and a
	ret z
	xor a
.loop:
	or a
	inc a
	daa
	dec b
	jr z, .skip ; why not jr nz?
	jr .loop
.skip:
	ld b, a
	ret
ENDC

ShiftRow::
	ld b, PLAYFIELD_WIDTH
.loop:
	ld a, [de]
	ld [hl], a
	inc l
	inc e
	dec b
	jr nz, .loop

	ld a, [hRowToShift]
	inc a
	ld [hRowToShift], a
	ret

; If the player has pressed left or right, and the current position allows such movement, move the
; current tetromino. Play the corresponding sound effect and handle auto fire.
; Input: none
; Output: none
; Clobbers all registers
HandleGameplayMovement::
IF DEF(INTERNATIONAL)
	; the sprite is not visible if a line clear is in progress
	ld hl, wSpriteList sprite 0 + SPRITE_OFFSET_VISIBILITY
	ld a, [hl]
	cp SPRITE_HIDDEN
	ret z
	ld l, SPRITE_OFFSET_ID
ELSE
	ld hl, wSpriteList sprite 0 + SPRITE_OFFSET_ID
ENDC
	ld a, [hl]
	ld [hBuffer], a
	ld a, [hKeysPressed]
	ld b, a
	bit B_BUTTON_BIT, b
	jr nz, .rotate_left
	bit A_BUTTON_BIT, b
	jr z, .finished_rotation

	ld a, [hl]
	and SPRITE_ID_ROTATION_MASK
	jr z, .wrap_right_rotation
	dec [hl]
	jr .did_rotation
.wrap_right_rotation:
	ld a, [hl]
	or SPRITE_ID_ROTATION_MASK
	ld [hl], a
	jr .did_rotation

.rotate_left:
	ld a, [hl]
	and SPRITE_ID_ROTATION_MASK
	cp 3
	jr z, .wrap_left_rotation

	inc [hl]
	jr .did_rotation

.wrap_left_rotation:
	ld a, [hl]
	and $ff ^ SPRITE_ID_ROTATION_MASK
	ld [hl], a

.did_rotation:
	ld a, PULSESFX_ROTATE
	ld [wPlayPulseSFX], a
	call UpdateCurrentTetromino
	call CheckCollision
	and a
	jr z, .finished_rotation

	; cancel rotation, we've got a collision
	xor a
	ld [wPlayPulseSFX], a
	ld hl, wSpriteList sprite 0 + SPRITE_OFFSET_ID
	ld a, [hBuffer]
	ld [hl], a ; you'd be better off specifying the address directly
	call UpdateCurrentTetromino
.finished_rotation:
	ld hl, wSpriteList sprite 0 + SPRITE_OFFSET_X
	ld a, [hKeysPressed]
	ld b, a
	ld a, [hKeysHeld]
	ld c, a
	ld a, [hl]
	ld [hBuffer], a
	bit D_RIGHT_BIT, b
	ld a, AUTOFIRE_DELAY
	jr nz, .pressed_right
	bit D_RIGHT_BIT, c
	jr z, .not_holding_right

	ld a, [hAutoFireCountdown]
	dec a
	ld [hAutoFireCountdown], a
	ret nz

	ld a, AUTOFIRE_RATE
.pressed_right:
	ld [hAutoFireCountdown], a
	ld a, [hl]
	add 8
	ld [hl], a
	call UpdateCurrentTetromino
	ld a, PULSESFX_MOVE_PIECE
	ld [wPlayPulseSFX], a
	call CheckCollision
	and a
	ret z

.cancel_movement:
	ld hl, wSpriteList sprite 0 + SPRITE_OFFSET_X
	xor a
	ld [wPlayPulseSFX], a
	ld a, [hBuffer]
	ld [hl], a
	call UpdateCurrentTetromino

	; make sure to check it next frame, since the player may want to move just before lock in
	ld a, 1
.end:
	ld [hAutoFireCountdown], a
	ret

.not_holding_right:
	bit D_LEFT_BIT, b
	ld a, AUTOFIRE_DELAY
	jr nz, .pressed_left

	bit D_LEFT_BIT, c
	jr z, .end

	ld a, [hAutoFireCountdown]
	dec a
	ld [hAutoFireCountdown], a
	ret nz

	ld a, AUTOFIRE_RATE
.pressed_left:
	ld [hAutoFireCountdown], a
	ld a, [hl]
	sub 8
	ld [hl], a
	ld a, PULSESFX_MOVE_PIECE
	ld [wPlayPulseSFX], a
	call UpdateCurrentTetromino
	call CheckCollision
	and a
	ret z
	jr .cancel_movement

; Check if the current tetromino is colliding with the pieces already on the playfield.
; Input: none
; Output: A = 1 if collision occured, A = 0 otherwise
; Clobbers A, B, DE, HL
CheckCollision::
	ld hl, wOAMBuffer_CurrentPiece
	ld b, 4

.square_loop:
	ld a, [hl+] ; Y
	ld [hCoordConversionY], a
	ld a, [hl+] ; X
	and a ; AFAIK, this never happens
	jr z, .out_of_bounds

	ld [hCoordConversionX], a
	push hl
	push bc
	call SpriteCoordToTilemapAddr
	ld a, h
	add HIGH(wTileMap - vBGMapA)
	ld h, a
	ld a, [hl]
	cp " "
	jr nz, .found_collision

	pop bc
	pop hl
	inc l ; this is fine since the OAM buffer is aligned to a 256-byte boundary, and must be to
	inc l ; take advantage of the OAM DMA
	dec b
	jr nz, .square_loop

.out_of_bounds:
	xor a
	ld [hCollisionOccured_NeverRead], a
	ret

.found_collision:
	pop bc
	pop hl
	ld a, 1
	ld [hCollisionOccured_NeverRead], a
	ret

HandleLockdownTransferToTilemap:
	ld a, [hLockdownStage]
	cp LOCKDOWN_STAGE_TRANSFER_TO_TILEMAP
	ret nz

	ld hl, wOAMBuffer_CurrentPiece
	ld b, 4

.loop:
	ld a, [hl+] ; y
	ld [hCoordConversionY], a
	ld a, [hl+] ; x
	and a
	jr z, .end

	ld [hCoordConversionX], a
	push hl
	push bc
	call SpriteCoordToTilemapAddr
	push hl
	pop de
	pop bc
	pop hl

.wait_vblank:
	ld a, [rSTAT]
	and STATF_MODE
	jr nz, .wait_vblank

	ld a, [hl] ; tile
	ld [de], a

	ld a, d
	add HIGH(wTileMap - vBGMapA)
	ld d, a

	ld a, [hl+]
	ld [de], a

	inc l
	dec b
	jr nz, .loop

.end:
	ld a, LOCKDOWN_STAGE_LOOK_FOR_FULL_LINES
	ld [hLockdownStage], a
	ld hl, wSpriteList sprite 0 + SPRITE_OFFSET_VISIBILITY
	ld [hl], SPRITE_HIDDEN
	ret


Call_000_262d:
	ld a, [wTypeBScoring_DoTick]
	cp $02
	jr z, jr_000_267a

	push de
	ld a, [hl]
	or a
	jr z, jr_000_268d

	dec a
	ld [hl+], a
	ld a, [hl]
	inc a
	daa
	ld [hl], a
	and $0f
	ld [bc], a
	dec c
	ld a, [hl+]
	swap a
	and $0f
	jr z, jr_000_264b

	ld [bc], a

jr_000_264b:
	push bc
	ld a, [$ff00+$c3]
	ld b, a
	inc b

jr_000_2650:
	push hl
	call AddBCD
	pop hl
	dec b
	jr nz, jr_000_2650

	pop bc
	inc hl
	inc hl
	push hl
	ld hl, $0023
	add hl, bc
	pop de
	call DisplayBCD_ThreeBytes
	pop de
	ld a, [$ff00+$c3]
	ld b, a
	inc b
	ld hl, $c0a0

jr_000_266c:
	push hl
	call AddBCD
	pop hl
	dec b
	jr nz, jr_000_266c

	ld a, $02
	ld [$c0c6], a
	ret


jr_000_267a:
	ld de, $c0a2
	ld hl, $9a25
	call DisplayBCD_ThreeBytes
	ld a, $02
	ld [wPlayPulseSFX], a
	xor a
	ld [$c0c6], a
	ret


jr_000_268d:
	pop de

Jump_000_268e:
	ld a, $21
	ld [hDelayCounter], a
	xor a
	ld [$c0c6], a
	ld a, [$c0c5]
	inc a
	ld [$c0c5], a
	cp $05
	ret nz

	ld a, STATE_04
	ld [hGameState], a
	ret

ResetGameplayVariablesMaybe:: ; TODO
	ld hl, wTypeBScoring
	ld b, 27
	xor a

jr_000_26ab:
	ld [hl+], a
	dec b
	jr nz, jr_000_26ab

	ld hl, wScore
	ld b, SCORE_SIZE

.clear_score:
	ld [hl+], a
	dec b
	jr nz, .clear_score
	ret

Unused_PrintHex::
	ld a, [hl]
	and $f0
	swap a
	ld [de], a
	ld a, [hl]
	and $0f
	inc e
	ld [de], a
	ret

UpdateTwoSprites::
	ld a, $02

UpdateNSprites::
	ld [hSpriteCount], a
	xor a
	ld [hOAMBufferPtrLo], a ; how about a tail merge?
	ld a, HIGH(wOAMBuffer) ; you could even load hl earlier
	ld [hOAMBufferPtrHi], a
	ld hl, wSpriteList
	call UpdateSprites ; why no TCO?
	ret

UpdateCurrentTetromino::
	ld a, 1
	ld [hSpriteCount], a
	ld a, LOW(wOAMBuffer_CurrentPiece)
	ld [hOAMBufferPtrLo], a
	ld a, HIGH(wOAMBuffer_CurrentPiece)
	ld [hOAMBufferPtrHi], a
	ld hl, wSpriteList sprite SPRITEPOS_CURRENT_TETROMINO
	call UpdateSprites ; why no TCO?
	ret

UpdateNextTetromino::
	ld a, 1
	ld [hSpriteCount], a
	ld a, LOW(wOAMBuffer_NextPiece)
	ld [hOAMBufferPtrLo], a
	ld a, HIGH(wOAMBuffer_NextPiece)
	ld [hOAMBufferPtrHi], a
	ld hl, wSpriteList sprite SPRITEPOS_NEXT_TETROMINO
	call UpdateSprites ; why no TCO?
	ret

DrawBlackVerticalStrip::
	ld b, BG_MAP_HEIGHT
	ld a, $8e
	ld de, BG_MAP_WIDTH
.loop:
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loop
	ret

; Copy a single sprite descriptor terminated by $ff
; Input:
; DE = pointer to the sprite descriptor in ROM
; HL = pointer to the wSpriteList entry to be filled
; Clobbers A, DE, HL
LoadSingleSprite::
	ld a, [de]
	cp -1
	ret z

	ld [hl+], a
	inc de
	jr LoadSingleSprite
	; fallthrough
EmptyInterrupt::
	reti

CurrentTetrominoSpriteList::
	db SPRITE_VISIBLE, 24, 63, 0, SPRITE_BELOW_BG, SPRITE_DONT_FLIP, 0, $ff

NextTetrominoSpriteList::
	db SPRITE_VISIBLE, 128, 143, 0, SPRITE_BELOW_BG, SPRITE_DONT_FLIP, 0, $ff

ModeSelectSpriteList::
	db SPRITE_VISIBLE, 112, 55, SPRITE_TYPE_A, SPRITE_ABOVE_BG, SPRITE_DONT_FLIP
	db SPRITE_VISIBLE, 56,  55, SPRITE_TYPE_A, SPRITE_ABOVE_BG, SPRITE_DONT_FLIP

TypeAMenuSpriteList::
	db SPRITE_VISIBLE, 64, 52, SPRITE_DIGIT_0, SPRITE_ABOVE_BG, SPRITE_DONT_FLIP

TypeBMenuSpriteList::
	db SPRITE_VISIBLE, 64, 28, SPRITE_DIGIT_0, SPRITE_ABOVE_BG, SPRITE_DONT_FLIP
	db SPRITE_VISIBLE, 64, 116, SPRITE_DIGIT_0, SPRITE_ABOVE_BG, SPRITE_DONT_FLIP

INCBIN "baserom.gb", $2741, $27e9 - $2741

ClearTilemapA::
	ld hl, vBGMapA + BG_MAP_HEIGHT * BG_MAP_WIDTH - 1
ClearTilemap::
	ld bc, BG_MAP_HEIGHT * BG_MAP_WIDTH
.loop:
	ld a, $2f
	ld [hl-], a
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

CopyBytes::
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, CopyBytes
	ret

LoadTileset::
	call LoadFont
	ld bc, 10 tiles
	call CopyBytes
	ld hl, GFX_Common2
	ld de, vBGTiles tile $30 ; necessary, since GFX_Common has an unused tile that gets overwritten
	ld bc, 208 tiles
	call CopyBytes ; why no TCO?
	ret

LoadFont::
	ld hl, GFX_Font
	ld bc, GFX_Font_End - GFX_Font
	ld de, vBGTiles tile $00
.loop:
	ld a, [hl+] ; while unintuitive, swapping de with hl could save space and execution time
	ld [de], a ; ld a, [de]
	inc de     ; inc de
	ld [de], a ; ld [hl+], a
	inc de     ; ld [hl+], a
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

LoadTitlescreenTileset::
	call LoadFont
	ld bc, 218 tiles ; GFX_Common and GFX_Titlescreen
	call CopyBytes ; why no TCO?
	ret

	ld bc, $1000

Call_000_2838:
	ld de, $8000
	call CopyBytes ; why no TCO?
GenericEmptyRoutine::
	ret

LoadTilemapA::
	ld hl, vBGMapA
	; fallthrough
LoadTilemap::
	ld b, SCREEN_HEIGHT
	; fallthrough
CopyRowsToTilemap::
	push hl
	ld c, SCREEN_WIDTH

.inner_loop:
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, .inner_loop

	pop hl
	push de
	ld de, BG_MAP_WIDTH
	add hl, de
	pop de
	dec b
	jr nz, CopyRowsToTilemap
	ret


Call_000_2858:
jr_000_2858:
	ld b, $0a
	push hl

jr_000_285b:
	ld a, [de]
	cp $ff
	jr z, jr_000_286e

	ld [hl+], a
	inc de
	dec b
	jr nz, jr_000_285b

	pop hl
	push de
	ld de, $0020
	add hl, de
	pop de
	jr jr_000_2858

jr_000_286e:
	pop hl
	ld a, $02
	ld [hRowToShift], a
	ret

DisableLCD::
	ld a, [rIE]
	ld [hSavedIE], a
	res IEF_VBLANK_BIT, a
	ld [rIE], a

.wait_vblank:
	ld a, [rLY]
	cp SCREEN_HEIGHT_PX + 1
	jr nz, .wait_vblank

	ld a, [rLCDC]
	and LCDCF_ON ^ $ff
	ld [rLCDC], a
	ld a, [hSavedIE]
	ld [rIE], a
	ret

INCBIN "baserom.gb", $288d, $2992 - $288d

GameoverTilemap::
INCBIN "gfx/gameover_tilemap.bin"

PleaseTryAgainTilemap::
INCBIN "gfx/please_try_again_tilemap.bin"

INCLUDE "utils.asm"
INCLUDE "sprites.asm"

GFX_Common2::
INCBIN "gfx/common2.trunc.2bpp"

TypeAPlayfieldTilemap::
INCBIN "gfx/playfield_a.bin"

TypeBPlayfieldTilemap::
INCBIN "gfx/playfield_b.bin"

; LoadTileset and LoadTitlescreenTileset assume this order
GFX_Font::
INCBIN "gfx/font.1bpp"
GFX_Font_End::

GFX_Common::
INCBIN "gfx/common.2bpp"

GFX_Titlescreen::
INCBIN "gfx/titlescreen.trunc.2bpp"
; end order assumption

CopyrightTilemap::
	db "                    "
	db "'TM AND c1987 ELORG,"
	db " TETRIS LICENSED TO "
	db "    BULLET PROOF    "
	db "    SOFTWARE AND    "
	db "   SUB-LICENSED TO  "
	db "      NINTENDO.     "
	db "                    "
	db " c1989 BULLET PROOF "
	db "      SOFTWARE.     "
	db "   c", $30, $31, $32, $31, " ", $34, $35, $36, $37, $38, $39, "     " ; 1989 Nintendo
	db "                    "
	db "ALL RIGHTS RESERVED."
	db "                    "
	db "  ORIGINAL CONCEPT, "
	db " DESIGN AND PROGRAM "
	db "BY ALEXEY PAZHITNOV.'"
	db "                    "

TitlescreenTilemap::
INCBIN "gfx/titlescreen_tilemap.bin"

ModeSelectTilemap::
INCBIN "gfx/mode_select_tilemap.bin"

TypeAMenuTilemap::
INCBIN "gfx/type_a_menu_tilemap.bin"

TypeBMenuTilemap::
INCBIN "gfx/type_b_menu_tilemap.bin"

VictoryDanceTilemap::
INCBIN "gfx/victory_dance_tilemap.bin"

	db $ff

LaunchpadTilemap::
INCBIN "gfx/launchpad_tilemap.bin"

MultiplayerMenuTilemap::
INCBIN "gfx/multiplayer_menu_tilemap.bin"

INCBIN "baserom.gb", $53c4, $55f4 - $53c4

ShuttleGFX::
INCBIN "gfx/shuttle.trunc.2bpp"

INCBIN "baserom.gb", $62c4, $6330 - $62c4

INCLUDE "demodata.asm"

DemoRandomness::
	; type A demo
	db SPRITE_Z0, SPRITE_T0, SPRITE_L0, SPRITE_J0
	db SPRITE_I0, SPRITE_L0, SPRITE_J0, SPRITE_I0
	db SPRITE_I0, SPRITE_L0, SPRITE_J0, SPRITE_S0
	db SPRITE_Z0, SPRITE_I0, SPRITE_Z0, SPRITE_Z0
DemoRandomnessTypeAEnd::
	db SPRITE_S0
DemoRandomnessTypeB::
	; type B demo
	db SPRITE_T0, SPRITE_S0, SPRITE_L0, SPRITE_O0
	db SPRITE_J0, SPRITE_T0, SPRITE_L0, SPRITE_S0
	db SPRITE_S0, SPRITE_I0, SPRITE_J0, SPRITE_J0
DemoRandomnessTypeBEnd::
	; unused
	db SPRITE_O0, SPRITE_L0, SPRITE_T0, SPRITE_J0
	db SPRITE_L0, SPRITE_I0, SPRITE_O0, SPRITE_O0
	db SPRITE_T0, SPRITE_L0, SPRITE_O0, SPRITE_I0
	; ...
INCBIN "baserom.gb", $64f9, $6552 - $64f9
