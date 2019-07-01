VBlankInterrupt::
	push af
	push bc
	push de
	push hl
	ld a, [hSendBufferValid]
	and a
	jr z, .serial_done

	ld a, [hMasterSlave]
	cp SERIAL_MASTER
	jr nz, .serial_done

	xor a
	ld [hSendBufferValid], a
	ld a, [hSendBuffer]
	ld [rSB], a
	ld hl, rSC
	ld [hl], SCF_RQ | SCF_MASTER

.serial_done:
	call VBlank_HandleLineClearBlink
	call ShiftRow19
	call ShiftRow18
	call ShiftRow17
	call ShiftRow16
	call ShiftRow15
	call ShiftRow14
	call ShiftRow13
	call ShiftRow12
	call ShiftRow11
	call ShiftRow10
	call ShiftRow9
	call ShiftRow8
	call ShiftRow7
	call ShiftRow6
	call ShiftRow5
	call ShiftRow4
	call ShiftRow3
	call ShiftRow2
	call VBlank_TypeBScoringScreen
	call hOAMDMA
	call VBlank_HighscoreTilemap

	ld a, [wScoreDirty]
	and a
	jr z, .score_done

	ld a, [hLockdownStage]
	cp LOCKDOWN_STAGE_BLINK
	jr nz, .score_done

	ld hl, vBGMapA + 3 * BG_MAP_WIDTH + 13
	call RenderScore
	ld a, 1
	ld [hScoreDirty], a
	ld hl, vBGMapB + 3 * BG_MAP_WIDTH + 13
	call RenderScore
	xor a
	ld [wScoreDirty], a

.score_done:
	ld hl, $ffe2
	inc [hl]
	xor a
	ld [rSCX], a
	ld [rSCY], a
	inc a
	ld [hVBlankOccured], a
	pop hl
	pop de
	pop bc
	pop af
	reti
