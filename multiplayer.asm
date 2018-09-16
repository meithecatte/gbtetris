LoadMultiplayerMusicSelect_Slave::
	ld hl, rSC
	set SCB_RQ, [hl]
	jr LoadMultiplayerMusicSelect.continue

LoadMultiplayerMusicSelect::
	ld a, SERIAL_STATE_3
	ld [hSerialState], a
	ld a, [hMasterSlave]
	cp SERIAL_MASTER
	jr nz, LoadMultiplayerMusicSelect_Slave ; put the _Slave part below and do a jr z, .continue

.continue:
	call LoadModeSelectScreen
	ld a, SPRITE_HIDDEN
	ld [wSpriteList sprite 1 + SPRITE_OFFSET_VISIBILITY], a ; hide the game type cursor
	call UpdateTwoSprites
	ld [hSendBufferValid], a ; always set to 0 by UpdateTwoSprites...
	xor a ; so this is pointless
	ld [rSB], a
	ld [hSendBuffer], a
	ld [$ff00+$dc], a
	ld [$ff00+$d2], a
	ld [$ff00+$d3], a
	ld [$ff00+$d4], a
	ld [$ff00+$d5], a
	ld [hRowToShift], a
	call JumpResetAudio
	ld a, STATE_43
	ld [hGameState], a
	ret

HandleState43::
	ld a, [hMasterSlave]
	cp SERIAL_MASTER
	jr z, .maybe_handle_movement

	ld a, [hMultiplayerNewMusic]
	and a
	jr z, .no_movement

	xor a
	ld [hMultiplayerNewMusic], a
	ld de, wSpriteList sprite 0 + SPRITE_OFFSET_Y
	call UpdateMusicCursor_NoSFX
	call PlaySelectedMusic
	call UpdateTwoSprites
	jr .no_movement

.maybe_handle_movement:
	ld a, [hKeysPressed]
	bit A_BUTTON_BIT, a
	jr nz, .no_movement

	bit START_BIT, a
	jr nz, .no_movement

	call HandleMusicSelect
.no_movement:
	ld a, [hMasterSlave]
	cp SERIAL_MASTER
	jr z, .handle_transfer_as_master

	ld a, [hSerialDone]
	and a
	ret z

	xor a
	ld [hSerialDone], a
	ld a, SERIAL_MUSIC_ACK
	ld [hSendBuffer], a
	ld a, [hRecvBuffer]
	cp SERIAL_MUSIC_DONE
	jr z, .decided_and_serial_completed

	ld b, a ; ld hl, hMusicType / cp [hl] to save on ld a, b below
	ld a, [hMusicType]
	cp b
	ret z

	ld a, b
	ld [hMusicType], a
	ld a, 1 ; hMultiplayerNewMusic is only checked for non-zero, so you don't need to set a to 1
	ld [hMultiplayerNewMusic], a
	ret

.handle_transfer_as_master:
	ld a, [hKeysPressed]
	bit START_BIT, a
	jr nz, .decided_as_master

	bit A_BUTTON_BIT, a
	jr nz, .decided_as_master

	ld a, [hSerialDone]
	and a
	ret z

	xor a
	ld [hSerialDone], a
	ld a, [hSendBuffer]
	cp SERIAL_MUSIC_DONE
	jr z, .decided_and_serial_completed

	ld a, [hMusicType]

.send_and_end:
	ld [hSendBuffer], a
	ld a, 1
	ld [hSendBufferValid], a
	ret

.decided_and_serial_completed:
	call ClearOAM
	ld a, STATE_22
	ld [hGameState], a
	ret

.decided_as_master:
	ld a, SERIAL_MUSIC_DONE
	jr .send_and_end

HandleState22_unk06dd::
	ld hl, rSC
	set SCB_RQ, [hl]
	jr jr_000_0703

HandleState22::
	ld a, SERIAL_STATE_3
	ld [hSerialState], a
	ld a, [hMasterSlave]
	cp SERIAL_MASTER
	jr nz, HandleState22_unk06dd

	call Call_000_0b10
	call Call_000_0b10
	call Call_000_0b10
	ld b, $00
	ld hl, $c300

jr_000_06fc:
	call Call_000_0b10
	ld [hl+], a
	dec b
	jr nz, jr_000_06fc

jr_000_0703:
	call DisableLCD
	call LoadTileset
	ld de, MultiplayerMenuTilemap
	call LoadTilemapA
	call ClearOAM
	ld a, " "
	call FillPlayfieldWithTile
	ld a, 3 ; why use a different constant than usual? also FillPlayfieldWithTile does not modify A.
	ld [hSendBufferValid], a
	xor a
	ld [rSB], a
	ld [hSendBuffer], a
	ld [$ff00+$dc], a
	ld [$ff00+$d2], a
	ld [$ff00+$d3], a
	ld [$ff00+$d4], a
	ld [$ff00+$d5], a
	ld [hRowToShift], a

jr_000_072c:
	ld [hSerialDone], a
	ld hl, $c400
	ld b, $0a
	ld a, $28

jr_000_0735:
	ld [hl+], a
	dec b
	jr nz, jr_000_0735

	ld a, [$ff00+$d6]
	and a
	jp nz, Jump_000_07da

	call PlaySelectedMusic
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	ld hl, $c080

jr_000_0749:
	ld de, $0772
	ld b, $20

jr_000_074e:
	call unk0792
	ld hl, $c200
	ld de, $2741
	ld c, 2
	call LoadSprites
	call Call_000_087b
	call UpdateTwoSprites
	xor a
	ld [$ff00+$d7], a
	ld [$ff00+$d8], a
	ld [$ff00+$d9], a
	ld [$ff00+$da], a
	ld [$ff00+$db], a
	ld a, $17
	ld [hGameState], a
	ret


	ld b, b
	jr z, @-$50

	nop
	ld b, b
	jr nc, @-$50

	jr nz, @+$4a

	jr z, jr_000_072c

	nop
	ld c, b
	jr nc, @-$4f

	jr nz, jr_000_07fb

	jr z, @-$3e

	nop
	ld a, b
	jr nc, jr_000_0749

	jr nz, @-$7e

	jr z, jr_000_074e

	nop
	add b
	jr nc, @-$3d

	db $20

unk0792::
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, @-$04

	ret

HandleState23::
	ld a, [hMasterSlave]
	cp $29
	jr z, jr_000_07c2

	ld a, [hSerialDone]
	and a
	jr z, jr_000_07b7

	ld a, [hRecvBuffer]
	cp $60
	jr z, jr_000_07d7

	cp $06
	jr nc, jr_000_07b0

	ld [$ff00+$ac], a

jr_000_07b0:
	ld a, [$ff00+$ad]
	ld [hSendBuffer], a
	xor a
	ld [hSerialDone], a

jr_000_07b7:
	ld de, $c210
	call HandleBlinkingCursor
	ld hl, $ffad
	jr jr_000_082a

jr_000_07c2:
	ld a, [hKeysPressed]
	bit 3, a
	jr z, jr_000_07cc

	ld a, $60
	jr jr_000_0819

jr_000_07cc:
	ld a, [hSerialDone]
	and a
	jr z, jr_000_0821

	ld a, [hSendBuffer]
	cp $60
	jr nz, jr_000_080f

jr_000_07d7:
	call ClearOAM

Jump_000_07da:
	ld a, [$ff00+$d6]
	and a
	jr nz, jr_000_07f7

	ld a, $18
	ld [hGameState], a
	ld a, [hMasterSlave]
	cp $29
	ret nz

	xor a
	ld [hBuffer], a
	ld a, $06
	ld de, $ffe0
	ld hl, $c9a2
	call Call_000_1bc3
	ret


jr_000_07f7:
	ld a, [hMasterSlave]
	cp $29

jr_000_07fb:
	jp nz, Jump_000_0895

	xor a
	ld [hBuffer], a
	ld a, $06
	ld de, $ffe0
	ld hl, $c9a2
	call Call_000_1bc3
	jp Jump_000_0895


jr_000_080f:
	ld a, [hRecvBuffer]
	cp $06
	jr nc, jr_000_0817

	ld [$ff00+$ad], a

jr_000_0817:
	ld a, [$ff00+$ac]

jr_000_0819:
	ld [hSendBuffer], a
	xor a
	ld [hSerialDone], a
	inc a
	ld [hSendBufferValid], a

jr_000_0821:
	ld de, $c200
	call HandleBlinkingCursor
	ld hl, $ffac

jr_000_082a:
	ld a, [hl]
	bit 4, b
	jr nz, jr_000_0843

	bit 5, b
	jr nz, jr_000_0855

	bit 6, b
	jr nz, jr_000_085b

	bit 7, b
	jr z, jr_000_084e

	cp $03
	jr nc, jr_000_084e

	add $03
	jr jr_000_0848

jr_000_0843:
	cp $05
	jr z, jr_000_084e

	inc a

jr_000_0848:
	ld [hl], a
	ld a, $01
	ld [wPlayPulseSFX], a

jr_000_084e:
	call Call_000_087b
	call UpdateTwoSprites
	ret


jr_000_0855:
	and a
	jr z, jr_000_084e

	dec a
	jr jr_000_0848

jr_000_085b:
	cp $03
	jr c, jr_000_084e

	sub $03
	jr jr_000_0848

	ld b, b
	ld h, b
	ld b, b
	ld [hl], b
	ld b, b
	add b
	ld d, b
	ld h, b
	ld d, b
	ld [hl], b
	ld d, b
	add b
	ld a, b
	ld h, b
	ld a, b
	ld [hl], b
	ld a, b
	add b
	adc b
	ld h, b
	adc b
	ld [hl], b
	adc b
	add b

Call_000_087b:
	ld a, [$ff00+$ac]
	ld de, $c201
	ld hl, $0863
	call UpdateDigitCursor_NoSFX
	ld a, [$ff00+$ad]
	ld de, $c211
	ld hl, $086f
	call UpdateDigitCursor_NoSFX
	ret

HandleState24::
	call DisableLCD

Jump_000_0895:
	xor a
	ld [$c210], a
	ld [hLockdownStage], a
	ld [hBlinkCounter], a
	ld [hCollisionOccured_NeverRead], a
	ld [hFailedTetrominoPlacements], a
	ld [$ff00+$9f], a
	ld [hSerialDone], a
	ld [rSB], a
	ld [hSendBufferValid], a
	ld [hRecvBuffer], a
	ld [hSendBuffer], a
	ld [$ff00+$d1], a
	call ResetGameplayVariablesMaybe
	call ClearedLinesListReset
	call Call_000_204d
	xor a

jr_000_08b9:
	ld [hRowToShift], a
IF !DEF(INTERNATIONAL)
	ld [$ff00+$e7], a
ENDC
	call ClearOAM
	ld de, $53c4
	push de
	ld a, $01
	ld [$ff00+$a9], a
	ld [hMultiplayer], a
	call LoadTilemapA

jr_000_08cd:
	pop de
	ld hl, $9c00
	call LoadTilemap
	ld de, $288d
	ld hl, $9c63
	ld c, 10
	call Copy8TilesWide
	ld hl, $c200
	ld de, CurrentTetrominoSpriteList
	call LoadSingleSprite
	ld hl, $c210
	ld de, NextTetrominoSpriteList
	call LoadSingleSprite
	ld hl, $9951
	ld a, $30
	ld [$ff00+$9e], a
	ld [hl], $00
	dec l
	ld [hl], $03
	call Call_000_1b43
	xor a
	ld [hBuffer], a
	ld a, [hMasterSlave]
	cp $29
	ld de, $0943
	ld a, [$ff00+$ac]
	jr z, jr_000_0913

	ld de, $0933
	ld a, [$ff00+$ad]

jr_000_0913:
	ld hl, $98b0
	ld [hl], a
	ld h, $9c
	ld [hl], a
	ld hl, $c080
	ld b, $10
	call unk0792
	ld a, $77
	ld [$ff00+$c0], a
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	ld a, $19
	ld [hGameState], a
	ld a, $01
	ld [hSerialState], a
	ret


	jr jr_000_08b9

	ret nz

	nop
	jr @-$72

	ret nz

	jr nz, jr_000_095c

	add h
	pop bc
	nop
	jr nz, jr_000_08cd

	pop bc
	jr nz, jr_000_095c

	add h
	xor [hl]
	nop
	jr @-$72

	xor [hl]
	jr nz, jr_000_096c

	add h
	xor a
	nop
	jr nz, @-$72

	xor a
	db $20

HandleState25::
	ld a, IEF_SERIAL
	ld [rIE], a
	xor a
	ld [rIF], a
	ld a, [hMasterSlave]

jr_000_095c:
	cp $29
	jp nz, Jump_000_0a65

jr_000_0961:
	call DelayLoop
	call DelayLoop
	xor a
	ld [hSerialDone], a
	ld a, $29

jr_000_096c:
	ld [rSB], a
	ld a, $81
	ld [rSC], a

jr_000_0972:
	ld a, [hSerialDone]
	and a
	jr z, jr_000_0972

	ld a, [rSB]
	cp $55
	jr nz, jr_000_0961

	ld de, $0016
	ld c, $0a
	ld hl, $c902

jr_000_0985:
	ld b, $0a

jr_000_0987:
	xor a
	ld [hSerialDone], a
	call DelayLoop
	ld a, [hl+]
	ld [rSB], a
	ld a, $81

jr_000_0992:
	ld [rSC], a

jr_000_0994:
	ld a, [hSerialDone]
	and a
	jr z, jr_000_0994

	dec b
	jr nz, jr_000_0987

	add hl, de
	dec c
	jr nz, jr_000_0985

	ld a, [$ff00+$ac]
	cp $05
	jr z, jr_000_09e3

	ld hl, $ca22
	ld de, $0040

jr_000_09ac:
	add hl, de
	inc a
	cp $05
	jr nz, jr_000_09ac

	ld de, $ca22
	ld c, $0a

jr_000_09b7:
	ld b, $0a

jr_000_09b9:
	ld a, [de]
	ld [hl+], a
	inc e
	dec b
	jr nz, jr_000_09b9

	push de
	ld de, $ffd6
	add hl, de
	pop de
	push hl
	ld hl, $ffd6
	add hl, de
	push hl
	pop de
	pop hl
	dec c
	jr nz, jr_000_09b7

	ld de, $ffd6

jr_000_09d3:
	ld b, $0a
	ld a, h
	cp $c8
	jr z, jr_000_09e3

	ld a, $2f

jr_000_09dc:
	ld [hl+], a
	dec b
	jr nz, jr_000_09dc

	add hl, de
	jr jr_000_09d3

jr_000_09e3:
	call DelayLoop
	call DelayLoop
	xor a
	ld [hSerialDone], a
	ld a, $29
	ld [rSB], a
	ld a, $81
	ld [rSC], a

jr_000_09f4:
	ld a, [hSerialDone]
	and a
	jr z, jr_000_09f4

	ld a, [rSB]
	cp $55
	jr nz, jr_000_09e3

	ld hl, $c300
	ld b, $00

jr_000_0a04:
	xor a
	ld [hSerialDone], a
	ld a, [hl+]
	call DelayLoop
	ld [rSB], a
	ld a, $81
	ld [rSC], a

jr_000_0a11:
	ld a, [hSerialDone]
	and a
	jr z, jr_000_0a11

	inc b
	jr nz, jr_000_0a04

jr_000_0a19:
	call DelayLoop
	call DelayLoop
	xor a
	ld [hSerialDone], a
	ld a, $30
	ld [rSB], a
	ld a, $81
	ld [rSC], a

jr_000_0a2a:
	ld a, [hSerialDone]
	and a
	jr z, jr_000_0a2a

	ld a, [rSB]
	cp $56
	jr nz, jr_000_0a19

Jump_000_0a35:
	call Call_000_0afb
	ld a, $09
	ld [rIE], a
	ld a, $1c
	ld [hGameState], a
	ld a, $02
	ld [hRowToShift], a
	ld a, $03
	ld [hSerialState], a
	ld a, [hMasterSlave]
	cp $29
	jr z, jr_000_0a53

	ld hl, $ff02
	set 7, [hl]

jr_000_0a53:
	ld hl, wRandomness
	ld a, [hl+]
	ld [wSpriteList sprite 0 + SPRITE_OFFSET_ID], a
	ld a, [hl+]
	ld [wSpriteList sprite 1 + SPRITE_OFFSET_ID], a
	ld a, h
	ld [hRandomnessPtrHi_NeverRead], a
	ld a, l
	ld [hRandomnessPtrLo], a
	ret


Jump_000_0a65:
	ld a, [$ff00+$ad]
	inc a
	ld b, a
	ld hl, $ca42
	ld de, $ffc0

jr_000_0a6f:
	dec b
	jr z, jr_000_0a75

	add hl, de
	jr jr_000_0a6f

jr_000_0a75:
	call DelayLoop
	xor a
	ld [hSerialDone], a
	ld a, $55
	ld [rSB], a
	ld a, $80
	ld [rSC], a

jr_000_0a83:
	ld a, [hSerialDone]
	and a
	jr z, jr_000_0a83

	ld a, [rSB]
	cp $29
	jr nz, jr_000_0a75

	ld de, $0016
	ld c, $0a

jr_000_0a93:
	ld b, $0a

jr_000_0a95:
	xor a
	ld [hSerialDone], a
	ld [rSB], a
	ld a, $80
	ld [rSC], a

jr_000_0a9e:
	ld a, [hSerialDone]
	and a
	jr z, jr_000_0a9e

	ld a, [rSB]
	ld [hl+], a
	dec b
	jr nz, jr_000_0a95

	add hl, de
	dec c
	jr nz, jr_000_0a93

jr_000_0aad:
	call DelayLoop
	xor a
	ld [hSerialDone], a
	ld a, $55
	ld [rSB], a
	ld a, $80
	ld [rSC], a

jr_000_0abb:
	ld a, [hSerialDone]
	and a
	jr z, jr_000_0abb

	ld a, [rSB]
	cp $29
	jr nz, jr_000_0aad

	ld b, $00
	ld hl, $c300

jr_000_0acb:
	xor a
	ld [hSerialDone], a
	ld [rSB], a
	ld a, $80
	ld [rSC], a

jr_000_0ad4:
	ld a, [hSerialDone]
	and a
	jr z, jr_000_0ad4

	ld a, [rSB]
	ld [hl+], a
	inc b
	jr nz, jr_000_0acb

jr_000_0adf:
	call DelayLoop
	xor a
	ld [hSerialDone], a
	ld a, $56
	ld [rSB], a
	ld a, $80
	ld [rSC], a

jr_000_0aed:
	ld a, [hSerialDone]
	and a
	jr z, jr_000_0aed

	ld a, [rSB]
	cp $30
	jr nz, jr_000_0adf

	jp Jump_000_0a35


Call_000_0afb:
	ld hl, $ca42
	ld a, $80
	ld b, $0a

jr_000_0b02:
	ld [hl+], a
	dec b
	jr nz, jr_000_0b02

	ret

DelayLoop::
	push bc
	ld b, 250
.loop:
	ld b, b
	dec b
	jr nz, .loop
	pop bc
	ret


Call_000_0b10:
	push hl
	push bc
	ld a, [hHighscorePtrLo]
	and $fc
	ld c, a
	ld h, $03

.outer_loop:
	ld a, [rDIV]
	ld b, a

.zero_and_loop:
	xor a

.loop:
	dec b
	jr z, .break_inner

	inc a
	inc a
	inc a
	inc a
	cp $1c
	jr z, .zero_and_loop

	jr .loop

.break_inner:
	ld d, a
	ld a, [hNextNextPiece]
	ld e, a
	dec h
	jr z, .break_outer

	or d
	or c
	and $fc
	cp c
	jr z, .outer_loop

.break_outer:
	ld a, d
	ld [hNextNextPiece], a
	ld a, e
	ld [hHighscorePtrLo], a
	pop bc
	pop hl
	ret

HandleState28::
	ld a, IEF_VBLANK
	ld [rIE], a
	ld a, [hRowToShift]
	and a
	jr nz, jr_000_0b66

	ld b, $44
	ld c, $20
	call Call_000_11a3
	ld a, $02
	ld [hSerialState], a
IF DEF(INTERNATIONAL)
	ld a, [$c0de]
	and a
	jr z, .skip
	ld a, SPRITE_HIDDEN
	ld [wSpriteList sprite 1 + SPRITE_OFFSET_VISIBILITY], a
.skip
ENDC
	call UpdateCurrentTetromino
	call UpdateNextTetromino
	call PlaySelectedMusic
	xor a
	ld [$ff00+$d6], a
	ld a, $1a
	ld [hGameState], a
	ret


jr_000_0b66:
	cp $05
	ret nz

	ld hl, $c030
	ld b, $12

jr_000_0b6e:
	ld [hl], $f0
	inc hl
	ld [hl], $10
	inc hl
	ld [hl], $b6
	inc hl
	ld [hl], $80
	inc hl
	dec b
	jr nz, jr_000_0b6e

	ld a, [$c3ff]

jr_000_0b80:
	ld b, $0a
	ld hl, $c400

jr_000_0b85:
	dec a
	jr z, jr_000_0b8e

	inc l
	dec b
	jr nz, jr_000_0b85

	jr jr_000_0b80

jr_000_0b8e:
	ld [hl], $2f
	ld a, $03
	ld [hSendBufferValid], a
	ret

HandleState26::
	ld a, $01
	ld [rIE], a
	ld hl, $c09c
	xor a
	ld [hl+], a
	ld [hl], $50
	inc l
	ld [hl], $27
	inc l
	ld [hl], $00
	call Call_000_1c68
	call Call_000_1ce3
	call HandleGameplayMovement
	call HandleGravity
	call LookForFullLines
	call HandleLockdownTransferToTilemap
	call HandleRowShift
	call Call_000_0bff
	ld a, [$ff00+$d5]
	and a
	jr z, jr_000_0bd7

	ld a, $77
	ld [hSendBuffer], a
	ld [$ff00+$b1], a
	ld a, $aa
	ld [$ff00+$d1], a
	ld a, STATE_27
	ld [hGameState], a
	ld a, $05
	ld [hFastDropDelayCounter], a
	jr jr_000_0be7

jr_000_0bd7:
	ld a, [hGameState]
	cp $01
	jr nz, jr_000_0bf8

	ld a, $aa
	ld [hSendBuffer], a
	ld [$ff00+$b1], a
	ld a, $77
	ld [$ff00+$d1], a

jr_000_0be7:
	xor a
	ld [$ff00+$dc], a
	ld [$ff00+$d2], a
	ld [$ff00+$d3], a
	ld [$ff00+$d4], a
	ld a, [hMasterSlave]
	cp $29
	jr nz, jr_000_0bf8

	ld [hSendBufferValid], a

jr_000_0bf8:
	call Call_000_0c54
	call Call_000_0cf0
	ret


Call_000_0bff:
	ld de, $0020
	ld hl, $c802
	ld a, $2f
	ld c, $12

jr_000_0c09:
	ld b, $0a
	push hl

jr_000_0c0c:
	cp [hl]
	jr nz, jr_000_0c19

	inc hl
	dec b
	jr nz, jr_000_0c0c

	pop hl
	add hl, de
	dec c
	jr nz, jr_000_0c09

	push hl

jr_000_0c19:
	pop hl
	ld a, c
	ld [$ff00+$b1], a
	cp $0c
	ld a, [wCurSong]
	jr nc, jr_000_0c2b

	cp $08
	ret nz

	call PlaySelectedMusic
	ret


jr_000_0c2b:
	cp $08
	ret z

	ld a, [$dff0]
	cp $02
	ret z

	ld a, $08
	ld [wPlaySong], a
	ret


jr_000_0c3a:
	ld a, [hMasterSlave]
	cp $29
	jr z, jr_000_0c92

	ld a, $01
	ld [$df7f], a
	ld [$ff00+$ab], a
	ld a, [hSendBuffer]
	ld [$ff00+$f1], a
	xor a
	ld [$ff00+$f2], a
	ld [hSendBuffer], a
	call Call_000_1d26
	ret


Call_000_0c54:
	ld a, [hSerialDone]
	and a
	ret z

	ld hl, $c030
	ld de, $0004
	xor a
	ld [hSerialDone], a
	ld a, [hRecvBuffer]
	cp $aa
	jr z, jr_000_0cc8

	cp $77
	jr z, jr_000_0cb4

	cp $94
	jr z, jr_000_0c3a

	ld b, a
	and a
	jr z, jr_000_0cc4

	bit 7, a
	jr nz, jr_000_0ce6

	cp $13
	jr nc, jr_000_0c92

	ld a, $12
	sub b
	ld c, a
	inc c

jr_000_0c80:
	ld a, $98

jr_000_0c82:
	ld [hl], a
	add hl, de
	sub $08
	dec b
	jr nz, jr_000_0c82

jr_000_0c89:
	ld a, $f0

jr_000_0c8b:
	dec c
	jr z, jr_000_0c92

	ld [hl], a
	add hl, de
	jr jr_000_0c8b

jr_000_0c92:
	ld a, [$ff00+$dc]
	and a
	jr z, jr_000_0c9e

	or $80
	ld [$ff00+$b1], a
	xor a
	ld [$ff00+$dc], a

jr_000_0c9e:
	ld a, $ff
	ld [hRecvBuffer], a
	ld a, [hMasterSlave]
	cp $29
	ld a, [$ff00+$b1]
	jr nz, jr_000_0cb1

	ld [hSendBuffer], a
	ld a, $01
	ld [hSendBufferValid], a
	ret


jr_000_0cb1:
	ld [hSendBuffer], a
	ret


jr_000_0cb4:
	ld a, [$ff00+$d1]
	cp $aa
	jr z, jr_000_0ce0

	ld a, $77
	ld [$ff00+$d1], a
	ld a, $01
	ld [hGameState], a
	jr jr_000_0c92

jr_000_0cc4:
	ld c, $13
	jr jr_000_0c89

jr_000_0cc8:
	ld a, [$ff00+$d1]
	cp $77
	jr z, jr_000_0ce0

	ld a, $aa
	ld [$ff00+$d1], a
	ld a, $1b
	ld [hGameState], a
	ld a, $05
	ld [hFastDropDelayCounter], a
	ld c, $01
	ld b, $12
	jr jr_000_0c80

jr_000_0ce0:
	ld a, $01
	ld [$ff00+$ef], a
	jr jr_000_0c92

jr_000_0ce6:
	and $7f
	cp $05
	jr nc, jr_000_0c92

	ld [$ff00+$d2], a
	jr jr_000_0c9e

Call_000_0cf0:
	ld a, [$ff00+$d3]
	and a
	jr z, jr_000_0cfc

	bit 7, a
	ret z

	and $07
	jr jr_000_0d06

jr_000_0cfc:
	ld a, [$ff00+$d2]
	and a
	ret z

	ld [$ff00+$d3], a
	xor a
	ld [$ff00+$d2], a
	ret

jr_000_0d06:
	ld c, a
	push bc
	ld hl, $c822
	ld de, $ffe0

jr_000_0d0e:
	add hl, de
	dec c
	jr nz, jr_000_0d0e

	ld de, $c822
	ld c, $11

jr_000_0d17:
	ld b, $0a

jr_000_0d19:
	ld a, [de]
	ld [hl+], a
	inc e
	dec b
	jr nz, jr_000_0d19

	push de
	ld de, $0016
	add hl, de
	pop de
	push hl
	ld hl, $0016
	add hl, de
	push hl
	pop de
	pop hl
	dec c
	jr nz, jr_000_0d17

	pop bc

jr_000_0d31:
	ld de, $c400
	ld b, $0a

jr_000_0d36:
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, jr_000_0d36

	push de
	ld de, $0016
	add hl, de
	pop de
	dec c
	jr nz, jr_000_0d31

	ld a, $02
	ld [hRowToShift], a
	ld [$ff00+$d4], a
	xor a
	ld [$ff00+$d3], a
	ret

HandleState27::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld a, $01
	ld [rIE], a
	ld a, $03
	ld [hSerialState], a
	ld a, [$ff00+$d1]
	cp $77
	jr nz, jr_000_0d6d

	ld a, [hRecvBuffer]
	cp $aa
	jr nz, jr_000_0d77

jr_000_0d67:
	ld a, $01
	ld [$ff00+$ef], a
	jr jr_000_0d77

jr_000_0d6d:
	cp $aa
	jr nz, jr_000_0d77

	ld a, [hRecvBuffer]
	cp $77
	jr z, jr_000_0d67

jr_000_0d77:
	ld b, $34
	ld c, $43
	call Call_000_11a3
	xor a
	ld [hRowToShift], a
	ld a, [$ff00+$d1]
	cp $aa
	ld a, $1e
	jr nz, jr_000_0d8b

	ld a, $1d

jr_000_0d8b:
	ld [hGameState], a
	ld a, $28
	ld [hDelayCounter], a
	ld a, $1d
	ld [hDemoCountdown], a
	ret

HandleState29::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld a, [$ff00+$ef]
	and a
	jr nz, jr_000_0da4

	ld a, [$ff00+$d7]
	inc a
	ld [$ff00+$d7], a

jr_000_0da4:
	call Call_000_0fd3
	ld de, $274d
	ld a, [hMasterSlave]
	cp $29
	jr z, jr_000_0db3

	ld de, $275f

jr_000_0db3:
	ld hl, $c200
	ld c, 3
	call LoadSprites
	ld a, $19
	ld [hDelayCounter], a
	ld a, [$ff00+$ef]
	and a
	jr z, jr_000_0dc9

	ld hl, $c220
	ld [hl], $80

jr_000_0dc9:
	ld a, $03
	call UpdateNSprites
	ld a, $20
	ld [hGameState], a
	ld a, $09
	ld [wPlaySong], a
	ld a, [$ff00+$d7]
	cp $05
	ret nz

	ld a, $11
	ld [wPlaySong], a
	ret


jr_000_0de2:
	ld a, [$ff00+$d7]
	cp $05
	jr nz, jr_000_0def

	ld a, [hDemoCountdown]
	and a
	jr z, jr_000_0df5

	jr jr_000_0e11

jr_000_0def:
	ld a, [hKeysPressed]
	bit 3, a
	jr z, jr_000_0e11

jr_000_0df5:
	ld a, $60
	ld [hSendBuffer], a
	ld [hSendBufferValid], a
	jr jr_000_0e1a

HandleState32::
	ld a, $01
	ld [rIE], a
	ld a, [hSerialDone]
	jr z, jr_000_0e11

	ld a, [hMasterSlave]
	cp $29
	jr z, jr_000_0de2

	ld a, [hRecvBuffer]
	cp $60
	jr z, jr_000_0e1a

jr_000_0e11:
	call Call_000_0e21
	ld a, $03
	call UpdateNSprites
	ret


jr_000_0e1a:
	ld a, $1f
	ld [hGameState], a
	ld [hSerialDone], a
	ret
