Init::
	xor a
	ld hl, $dfff
	ld c, $10 ; could ld bc,
	ld b, $00

.clear_wramx:
	ld [hl-], a
	dec b
	jr nz, .clear_wramx

	dec c
	jr nz, .clear_wramx

SoftReset:
	ld a, IEF_VBLANK
	di
	ld [rIF], a
	ld [rIE], a
	xor a
	ld [rSCY], a
	ld [rSCX], a
	ld [$ff00+$a4], a
	ld [rSTAT], a
	ld [rSB], a
	ld [rSC], a
	ld a, LCDCF_ON
	ld [rLCDC], a

.vblank_wait:
	ld a, [rLY]
	cp SCREEN_HEIGHT_PX + 4
	jr nz, .vblank_wait

	ld a, LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a
	ld a, %11000100
	ld [rOBP1], a

	ld hl, rAUDENA
	ld a, AUDENA_ENABLED
	ld [hl-], a
	assert rAUDENA +- 1 == rAUDTERM
	ld a, AUDTERM_ALL
	ld [hl-], a
	assert rAUDTERM +- 1 == rAUDVOL
	ld [hl], AUDVOL_MAX

	ld a, 1 ; noop on the cartridge used
	ld [$2000], a

	ld sp, wStackEnd - 1

	xor a
	ld hl, wAudioEnd - 1
	ld b, 0
.clear_audio:
	ld [hl-], a
	dec b
	jr nz, .clear_audio

	ld hl, $cfff
	ld c, $10
	ld b, 0 ; unnecessary
.clear_wram0:
	ld [hl-], a
	dec b
	jr nz, .clear_wram0
	dec c
	jr nz, .clear_wram0

	ld hl, $9fff ; could just load h
	ld c, $20
	xor a ; unnecessary
	ld b, $00 ; unnecessary
.clear_vram:
	ld [hl-], a
	dec b
	jr nz, .clear_vram
	dec c
	jr nz, .clear_vram

	ld hl, $feff
	ld b, $00 ; unnecessary
.clear_oam:
	ld [hl-], a
	dec b
	jr nz, .clear_oam

	ld hl, $fffe
	; writes to ff7f too, could break forward compat if Nintendo did something on new consoles
	ld b, $80
.clear_hram:
	ld [hl-], a
	dec b
	jr nz, .clear_hram

	ld c, LOW(hOAMDMA) ; could ld bc,
	ld b, 12 ; the routine is only 10 bytes long
	ld hl, DMA_Routine
.copy_dma_routine:
	ld a, [hl+]
	ld [$ff00+c], a
	inc c
	dec b
	jr nz, .copy_dma_routine

	call ClearTilemapA
	call JumpResetAudio
	ld a, IEF_SERIAL | IEF_VBLANK
	ld [rIE], a
	ld a, GAME_TYPE_A
	ld [hGameType], a
	ld a, MUSIC_TYPE_A
	ld [hMusicType], a
	ld a, STATE_LOAD_COPYRIGHT
	ld [hGameState], a
	ld a, LCDCF_ON
	ld [rLCDC], a
	ei
	xor a
	ld [rIF], a
	ld [rWY], a
	ld [rWX], a
	ld [rTMA], a

MainLoop::
	call ReadJoypad
	call HandleGameState
	call JumpUpdateAudio

	ld a, [hKeysHeld]
	and A_BUTTON | B_BUTTON | SELECT | START
	cp  A_BUTTON | B_BUTTON | SELECT | START
	jp z, SoftReset

	assert hDelayCounter + 1 == hFastDropDelayCounter
	ld hl, hDelayCounter
	ld b, 2
.counter_loop:
	ld a, [hl]
	and a
	jr z, .already_zero
	dec [hl]
.already_zero:
	inc l
	dec b
	jr nz, .counter_loop

	ld a, [hMultiplayer]
	and a
	jr z, .wait_vblank

	ld a, IEF_SERIAL | IEF_VBLANK
	ld [rIE], a

.wait_vblank:
	ld a, [hVBlankOccured]
	and a
	jr z, .wait_vblank

	xor a
	ld [hVBlankOccured], a
	jp MainLoop

HandleGameState::
	ld a, [hGameState]
	jumptable
	dw HandleGameplay
	dw HandleGameOver
	dw HandleState2
	dw HandleState3
	dw HandleState4
	dw HandleState5
	dw LoadTitlescreen
	dw HandleTitlescreen
	dw LoadModeSelect
	dw GenericEmptyRoutine2
	dw LoadPlayfield
	dw HandleState11
	dw HandleState12
	dw HandleState13
	dw HandleModeSelect
	dw HandleMusicSelect
	dw LoadTypeAMenu
	dw HandleTypeAMenu
	dw LoadTypeBMenu
	dw HandleTypeBLevelSelect
	dw HandleTypeBHighSelect
	dw HandleHighscoreEnterName
	dw HandleState22
	dw HandleState23
	dw HandleState24
	dw HandleState25
	dw HandleState26
	dw HandleState27
	dw HandleState28
	dw HandleState29
	dw HandleState30
	dw HandleState31
	dw HandleState32
	dw HandleState33
	dw HandleState34
	dw HandleState35
	dw LoadCopyrightScreen
	dw HandleCopyrightScreen
	dw HandleState38
	dw HandleState39
	dw HandleState40
	dw HandleState41
	dw LoadMultiplayerMusicSelect
	dw HandleState43
	dw HandleState44
	dw HandleState45
	dw HandleState46
	dw HandleState47
	dw HandleState48
	dw HandleState49
	dw HandleState50
	dw HandleState51
	dw HandleState52
IF DEF(INTERNATIONAL)
	dw MoreCopyrightScreenDelay
ENDC
	dw GenericEmptyRoutine
