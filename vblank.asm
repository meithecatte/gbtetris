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
	call Call_000_242c
	call Call_000_2417
	call Call_000_23fe
	call Call_000_23ec
	call Call_000_23dd
	call Call_000_23ce
	call Call_000_23bf
	call Call_000_23b0
	call Call_000_23a1
	call Call_000_2392
	call Call_000_2383
	call Call_000_2358
	call Call_000_2349
	call Call_000_233a
	call Call_000_232b
	call Call_000_231c
	call Call_000_230d
	call Call_000_22fe
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
	ld a, $01
	ld [$ff00+$e0], a
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
