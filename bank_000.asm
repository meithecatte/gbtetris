SECTION "rst0", ROM0[$0]
	jp Init

rept 5
	nop
endr

SECTION "rst8", ROM0[$8]
	jp Init

SECTION "rst28", ROM0[$28]
	; A = jumptable entry number
	; jumptable follows rst instruction
	; clobbers de, hl and a
	add a
	pop hl
	ld e, a
	ld d, $00
	add hl, de ; do this twice instead of add a at the beginning for increased range

	ld e, [hl] ; better:
	inc hl     ; ld a, [hli]
	ld d, [hl] ; ld h, [hl]
	push de    ; ld l, a
	pop hl     ; could easily make this save DE
	jp hl

SECTION "VBlank", ROM0[$40]
	jp VBlankInterrupt

SECTION "LCDC", ROM0[$48]
	jp EmptyInterrupt

SECTION "Timer", ROM0[$50]
	jp EmptyInterrupt

SECTION "Serial", ROM0[$58]
	jp SerialInterrupt

IF DEF(INTERNATIONAL)
	INCLUDE "serial.asm"
ENDC

SECTION "Entry Point", ROM0[$100]
	nop
	jp Boot

	rept $14E - $104
	db $00
	endr

SECTION "Code", ROM0[$150]
Boot:
	jp Init


	call Call_000_2a2b

jr_000_0156:
	ld a, [rSTAT]
	and $03
	jr nz, jr_000_0156

	ld b, [hl]

jr_000_015d:
	ld a, [rSTAT]
	and $03
	jr nz, jr_000_015d

	ld a, [hl]
	and b
	ret


Call_000_0166:
	ld a, e
	add [hl]
	daa
	ld [hl+], a
	ld a, d
	adc [hl]
	daa
	ld [hl+], a
	ld a, $00
	adc [hl]
	daa
	ld [hl], a
	ld a, $01
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
	call Call_000_2240
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
	call Call_000_1f32
	call hOAMDMA
	call CopyHighscoresFromTilemapBuffer
	ld a, [$c0ce]
	and a
	jr z, jr_000_027a

	ld a, [$ff00+$98]
	cp $03
	jr nz, jr_000_027a

	ld hl, $986d
	call Call_000_249b
	ld a, $01
	ld [$ff00+$e0], a
	ld hl, $9c6d
	call Call_000_249b
	xor a
	ld [$c0ce], a

jr_000_027a:
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

	ld a, $01 ; noop on the cartridge used
	ld [$2000], a

	ld sp, wStackEnd - 1

	xor a
	ld hl, wAudioEnd - 1
	ld b, $00
.clear_audio:
	ld [hl-], a
	dec b
	jr nz, .clear_audio

	ld hl, $cfff
	ld c, $10
	ld b, $00 ; unnecessary
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

	assert hDelayCounter + 1 == hDelayCounter2
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
	dw HandleState0 ; 0
	dw HandleState1 ; 1
	dw HandleState2 ; 2
	dw HandleState3 ; 3
	dw HandleState4 ; 4
	dw HandleState5 ; 5
	dw LoadTitlescreen
	dw HandleTitlescreen
	dw LoadModeSelect
	dw GenericEmptyRoutine2 ; 9
	dw HandleState10 ; STATE_10
	dw HandleState11 ; 11
	dw HandleState12 ; 12
	dw HandleState13 ; 13
	dw HandleModeSelect
	dw HandleMusicSelect
	dw LoadTypeAMenu
	dw HandleState17 ; 17
	dw LoadTypeBMenu
	dw HandleState19 ; 19
	dw HandleState20 ; 20
	dw HandleHighscoreEnterName
	dw HandleState22
	dw HandleState23 ; 23
	dw HandleState24 ; 24
	dw HandleState25 ; 25
	dw HandleState26 ; 26
	dw HandleState27 ; 27
	dw HandleState28 ; 28
	dw HandleState29 ; 29
	dw HandleState30 ; 30
	dw HandleState31 ; 31
	dw HandleState32 ; 32
	dw HandleState33 ; 33
	dw HandleState34 ; 34
	dw HandleState35 ; STATE_35
	dw LoadCopyrightScreen ; STATE_LOAD_COPYRIGHT
	dw HandleCopyrightScreen ; STATE_COPYRIGHT
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

LoadCopyrightScreen::
	call DisableLCD
	call LoadTitlescreenTileset
	ld de, CopyrightTilemap
	call LoadTilemapA
	call ClearOAM

	ld hl, $c300 ; TODO
	ld de, $64d0
.loop:
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, h
	cp $c4
	jr nz, .loop

	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
IF DEF(INTERNATIONAL)
	ld a, 250
ELSE
	ld a, 125
ENDC
	ld [hDelayCounter], a
	ld a, STATE_COPYRIGHT
	ld [hGameState], a
	ret

HandleCopyrightScreen::
	ld a, [hDelayCounter]
	and a
	ret nz

IF DEF(INTERNATIONAL)
	ld a, 250
	ld [hDelayCounter], a
	ld a, STATE_MORE_COPYRIGHT
	ld [hGameState], a
	ret

MoreCopyrightScreenDelay::
	ld a, [hKeysPressed]
	and a
	jr nz, .skip
	ld a, [hDelayCounter]
	and a
	ret nz
.skip
ENDC
	ld a, STATE_LOAD_TITLESCREEN
	ld [hGameState], a
	ret

LoadTitlescreen::
	call DisableLCD
	xor a
	ld [$ff00+$e9], a ; TODO
	ld [$ff00+$98], a
	ld [$ff00+$9c], a
	ld [$ff00+$9b], a
	ld [hHighscorePtrHi], a
	ld [$ff00+$9f], a
	ld [$ff00+$e3], a
IF !DEF(INTERNATIONAL)
	ld [$ff00+$e7], a
ENDC
	ld [hHighscoreEnterName], a
	call Call_000_22f3
	call ResetGameplayVariablesMaybe
	call LoadTitlescreenTileset

	ld hl, $c800 ; TODO
.clear_unk:
	ld a, $2f
	ld [hl+], a
	ld a, h
	cp $cc
	jr nz, .clear_unk

	ld hl, $c801
	call unk26fd
	ld hl, $c80c
	call unk26fd
	ld hl, $ca41
	ld b, 12
	ld a, $8e

.loop:
	ld [hl+], a
	dec b
	jr nz, .loop

	ld de, TitlescreenTilemap
	call LoadTilemapA
	call ClearOAM

	ld hl, wOAMBuffer
	ld [hl], 128 ; y
	inc l
	ld [hl], 16 ; x
	inc l
	ld [hl], $58 ; tile, attr stays 0

	ld a, $03 ; TODO
	ld [wPlaySong], a
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	ld a, STATE_TITLESCREEN
	ld [hGameState], a
	ld a, 125
	ld [hDelayCounter], a
	ld a, 4 ; if just finished demo, shorter wait
	ld [hDemoCountdown], a
	ld a, [hDemoNumber]
	and a
	ret nz

	ld a, 19
	ld [hDemoCountdown], a
	ret

StartDemo::
	ld a, $37 ; TODO
	ld [$ff00+$c0], a
	ld a, $09
	ld [$ff00+$c2], a
	xor a
	ld [hMultiplayer], a
	ld [$ff00+$b0], a
	ld [$ff00+$ed], a
	ld [$ff00+$ea], a
	ld a, $63
	ld [$ff00+$eb], a
	ld a, $30
	ld [$ff00+$ec], a
	ld a, [hDemoNumber]
	cp 2
	ld a, 2
	jr nz, .got_params

	ld a, $77
	ld [$ff00+$c0], a
	ld a, $09
	ld [$ff00+$c3], a
	ld a, $02
	ld [$ff00+$c4], a
	ld a, $64
	ld [$ff00+$eb], a
	ld a, $30
	ld [$ff00+$ec], a
	ld a, $11
	ld [$ff00+$b0], a
	ld a, 1

.got_params:
	ld [hDemoNumber], a
	ld a, STATE_10
	ld [hGameState], a
	call DisableLCD
	call LoadTileset
	ld de, ModeSelectTilemap
	call LoadTilemapA
	call ClearOAM
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	ret


	ld a, $ff
	ld [$ff00+$e9], a
	ret

HandleTitlescreen::
	ld a, [hDelayCounter]
	and a
	jr nz, .no_demo

	ld hl, hDemoCountdown
	dec [hl]
	jr z, StartDemo

	ld a, 125
	ld [hDelayCounter], a

.no_demo:
	call DelayLoop
	ld a, SERIAL_SLAVE ; if any byte is sent, respond
	ld [rSB], a
	ld a, SCF_RQ
	ld [rSC], a
	ld a, [hSerialDone]
	and a
	jr z, .no_serial_data

	ld a, [hMasterSlave]
	and a
	jr nz, .start_multiplayer

	xor a
	ld [hSerialDone], a
	jr .go_single

.no_serial_data:
	ld a, [hKeysPressed]
	ld b, a
	ld a, [hMultiplayer]
	bit SELECT_BIT, b
	jr nz, .switch

	bit D_RIGHT_BIT, b
	jr nz, .pressed_right

	bit D_LEFT_BIT, b
	jr nz, .pressed_left

	bit START_BIT, b
	ret z

	and a
	ld a, STATE_LOAD_MODE_SELECT ; this should be set just before jumping to .done - that way you don't need to save it
	jr z, .start_singleplayer

	ld a, b
	cp START
	ret nz

	ld a, [hMasterSlave]
	cp SERIAL_MASTER
	jr z, .start_multiplayer

	ld a, SERIAL_MASTER
	ld [rSB], a
	ld a, SCF_RQ | SCF_MASTER
	ld [rSC], a

.wait_serial:
	ld a, [hSerialDone]
	and a
	jr z, .wait_serial

	ld a, [hMasterSlave]
	and a
	jr z, .go_single

.start_multiplayer
	ld a, STATE_LOAD_MULTIPLAYER_MUSIC_SELECT

.done:
	ld [hGameState], a
	xor a
	ld [hDelayCounter], a
	ld [hTypeALevel], a
	ld [hTypeBLevel], a
	ld [hTypeBHigh], a
	ld [hDemoNumber], a
	ret

.start_singleplayer:
	push af
	ld a, [hKeysHeld]
	bit D_DOWN_BIT, a
	jr z, .no_down_press
	ld [hStartAtLevel10], a
.no_down_press:
	pop af
	jr .done

.switch:
	xor $01

.move_cursor:
	ld [hMultiplayer], a
	and a
	ld a, $10
	jr z, .got_pos
	ld a, $60
.got_pos:
	ld [wOAMBuffer + 1], a
	ret


.pressed_right:
	and a ; just set a to 1 and jump to move_cursor!
	ret nz

	xor a ; redundant
	jr .switch

.pressed_left:
	and a ; just set a to 0 and jump to move_cursor!
	ret z

.go_single:
	xor a
	jr .move_cursor

Call_000_0579:
	ld a, [hDemoNumber]
	and a
	ret z

	call DelayLoop
	xor a
	ld [rSB], a
	ld a, $80
	ld [rSC], a
	ld a, [hKeysPressed]
	bit 3, a
	jr z, jr_000_059a

	ld a, $33
	ld [rSB], a
	ld a, $81
	ld [rSC], a
	ld a, $06
	ld [hGameState], a
	ret


jr_000_059a:
	ld hl, $ffb0
	ld a, [hDemoNumber]
	cp $02
	ld b, $10
	jr z, jr_000_05a7

	ld b, $1d

jr_000_05a7:
	ld a, [hl]
	cp b
	ret nz

	ld a, $06
	ld [hGameState], a
	ret


Call_000_05af:
	ld a, [hDemoNumber]
	and a
	ret z

	ld a, [$ff00+$e9]
	cp $ff
	ret z

	ld a, [$ff00+$ea]
	and a
	jr z, jr_000_05c2

	dec a
	ld [$ff00+$ea], a
	jr jr_000_05de

jr_000_05c2:
	ld a, [$ff00+$eb]
	ld h, a
	ld a, [$ff00+$ec]
	ld l, a
	ld a, [hl+]
	ld b, a
	ld a, [$ff00+$ed]
	xor b
	and b
	ld [hKeysPressed], a
	ld a, b
	ld [$ff00+$ed], a
	ld a, [hl+]
	ld [$ff00+$ea], a
	ld a, h
	ld [$ff00+$eb], a
	ld a, l
	ld [$ff00+$ec], a
	jr jr_000_05e1

jr_000_05de:
	xor a
	ld [hKeysPressed], a

jr_000_05e1:
	ld a, [hKeysHeld]
	ld [$ff00+$ee], a
	ld a, [$ff00+$ed]
	ld [hKeysHeld], a
	ret


	xor a
	ld [$ff00+$ed], a
	jr jr_000_05de

	ret


Call_000_05f0:
	ld a, [hDemoNumber]
	and a
	ret z

	ld a, [$ff00+$e9]
	cp $ff
	ret nz

	ld a, [hKeysHeld]
	ld b, a
	ld a, [$ff00+$ed]
	cp b
	jr z, jr_000_061a

	ld a, [$ff00+$eb]
	ld h, a
	ld a, [$ff00+$ec]
	ld l, a
	ld a, [$ff00+$ed]
	ld [hl+], a
	ld a, [$ff00+$ea]
	ld [hl+], a
	ld a, h
	ld [$ff00+$eb], a
	ld a, l
	ld [$ff00+$ec], a
	ld a, b
	ld [$ff00+$ed], a
	xor a
	ld [$ff00+$ea], a
	ret


jr_000_061a:
	ld a, [$ff00+$ea]
	inc a
	ld [$ff00+$ea], a
	ret


Call_000_0620:
	ld a, [hDemoNumber]
	and a
	ret z

	ld a, [$ff00+$e9]
	and a
	ret nz

	ld a, [$ff00+$ee]
	ld [hKeysHeld], a
	ret

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
	ld [$ff00+$e3], a
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
	ld a, $2f
	call Call_000_2038
	ld a, 3 ; why use a different constant than usual? also Call_000_2038 does not modify A.
	ld [hSendBufferValid], a
	xor a
	ld [rSB], a
	ld [hSendBuffer], a
	ld [$ff00+$dc], a
	ld [$ff00+$d2], a
	ld [$ff00+$d3], a
	ld [$ff00+$d4], a
	ld [$ff00+$d5], a
	ld [$ff00+$e3], a

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
	call $0792
	ld hl, $c200
	ld de, $2741
	ld c, $02
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

	jr nz, @+$1c

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
	ld [$ff00+$a0], a
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
	ld [$ff00+$a0], a
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
	ld [wPlaySFX], a

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
	ld [$ff00+$98], a
	ld [$ff00+$9c], a
	ld [$ff00+$9b], a
	ld [hHighscorePtrHi], a
	ld [$ff00+$9f], a
	ld [hSerialDone], a
	ld [rSB], a
	ld [hSendBufferValid], a
	ld [hRecvBuffer], a
	ld [hSendBuffer], a
	ld [$ff00+$d1], a
	call ResetGameplayVariablesMaybe
	call Call_000_22f3
	call Call_000_204d
	xor a

jr_000_08b9:
	ld [$ff00+$e3], a
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
	ld c, $0a
	call Call_000_1fd8
	ld hl, $c200
	ld de, $2713
	call Call_000_270a
	ld hl, $c210
	ld de, $271b
	call Call_000_270a
	ld hl, $9951
	ld a, $30
	ld [$ff00+$9e], a
	ld [hl], $00
	dec l
	ld [hl], $03
	call Call_000_1b43
	xor a
	ld [$ff00+$a0], a
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
	call $0792
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
	ld [$ff00+$e3], a
	ld a, $03
	ld [hSerialState], a
	ld a, [hMasterSlave]
	cp $29
	jr z, jr_000_0a53

	ld hl, $ff02
	set 7, [hl]

jr_000_0a53:
	ld hl, $c300
	ld a, [hl+]
	ld [$c203], a
	ld a, [hl+]
	ld [$c213], a
	ld a, h
	ld [$ff00+$af], a
	ld a, l
	ld [$ff00+$b0], a
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
	ld a, [$ff00+$ae]
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
	ld [$ff00+$ae], a
	ld a, e
	ld [hHighscorePtrLo], a
	pop bc
	pop hl
	ret

HandleState28::
	ld a, $01
	ld [rIE], a
	ld a, [$ff00+$e3]
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
	ld a, $80
	ld [$c210], a
.skip
ENDC
	call UpdateFirstSprite
	call UpdateSecondSprite
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
	call Call_000_2515
	call Call_000_20f7
	call Call_000_2199
	call Call_000_25f5
	call Call_000_22ad
	call Call_000_0bff
	ld a, [$ff00+$d5]
	and a
	jr z, jr_000_0bd7

	ld a, $77
	ld [hSendBuffer], a
	ld [$ff00+$b1], a
	ld a, $aa
	ld [$ff00+$d1], a
	ld a, $1b
	ld [hGameState], a
	ld a, $05
	ld [hDelayCounter2], a
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
	ld [hDelayCounter2], a
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
	ld [$ff00+$e3], a
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
	ld [$ff00+$e3], a
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
	ld c, $03
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
	ld [wPlaySFX], a
	ret


jr_000_0e73:
	dec l
	ld [hl], $80
	ret


jr_000_0e77:
	ld a, [hDelayCounter2]
	and a
	ret nz

	ld a, $0f
	ld [hDelayCounter2], a
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
	ld c, $02
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
	ld [wPlaySFX], a
	ret


jr_000_0f67:
	dec l
	ld [hl], $80
	ret


jr_000_0f6b:
	ld a, [hDelayCounter2]
	and a
	ret nz

	ld a, $0f
	ld [hDelayCounter2], a
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
	ld hl, $55f4
	ld bc, $1000
	call Call_000_2838
	call $27e9
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
	ld [$ff00+$a0], a
	ld hl, $99e7
	call Call_000_10ce
	ld a, [$ff00+$d9]
	and a
	jr z, jr_000_1073

	ld a, $ac
	ld [$ff00+$a0], a
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
	ld [$ff00+$a0], a
	ld hl, $9827
	call Call_000_10ce
	ld a, [$ff00+$da]
	and a
	jr z, jr_000_10b6

	ld a, $ac
	ld [$ff00+$a0], a
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
	ld a, [$ff00+$a0]
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
	call $7ff3
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
	call Call_000_149b
	ld hl, $9ce7
	ld de, $1486
	ld b, $07
	call Call_000_149b
	ld hl, $9d08
	ld [hl], $72
	inc l
	ld [hl], $c4
	ld hl, $9d28
	ld [hl], $b7
	inc l
	ld [hl], $b8
	ld de, $27c5
	ld hl, $c200
	ld c, $03
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
	ld hl, $55f4
	ld bc, $1000
	call Call_000_2838
	ld hl, $9fff
	call ClearTilemap
	ld hl, $9dc0
	ld de, $520c
	ld b, $04
	call CopyRowsToTilemap
	ld hl, $9cec
	ld de, $148d
	ld b, $07
	call Call_000_149b
	ld hl, $9ced
	ld de, $1494
	ld b, $07
	call Call_000_149b
	ret

HandleState39::
	ld a, [hDelayCounter]
	and a
	ret nz

	ld hl, $c210
	ld [hl], $00
	ld l, $20
	ld [hl], $00
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
	ld a, $2f
	call Call_000_2032
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
	ld [hHighscoreNamePointerHi], a
	ld a, $82
	ld [hHighscoreNamePointerLo], a
	ld a, $2c
	ld [hGameState], a
	ret


jr_000_1301:
	ld a, [hDelayCounter2]
	and a
	jr nz, jr_000_1311

	ld a, $06
	ld [hDelayCounter2], a
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
	ld a, [hHighscoreNamePointerLo]
	sub $82
	ld e, a
	ld d, $00
	ld hl, $1359
	add hl, de
	push hl
	pop de
	ld a, [hHighscoreNamePointerHi]
	ld h, a
	ld a, [hHighscoreNamePointerLo]
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
	ld [wPlaySFX], a
	ld a, h
	ld [hHighscoreNamePointerHi], a
	ld a, l
	ld [hHighscoreNamePointerLo], a
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
	call Call_000_22f3
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
	ld c, $03
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
	ld a, $10
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
	ld a, $2f
	call Call_000_2032
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
	ld a, [hDelayCounter2]
	and a
	jr nz, jr_000_1443

	ld a, $06
	ld [hDelayCounter2], a
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
	call $7ff3
	call Call_000_22f3
	ld a, $93
	ld [rLCDC], a
	ld a, $10
	ld [hGameState], a
	ret


Call_000_145e:
	ld a, [hDelayCounter2]
	and a
	ret nz

	ld a, $0a
	ld [hDelayCounter2], a
	ld a, $03
	ld [$dff8], a
	ld b, $02
	ld hl, $c210

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

Call_000_149b:
jr_000_149b:
	ld a, [de]
	ld [hl], a
	inc de
	push de
	ld de, $0020
	add hl, de
	pop de
	dec b
	jr nz, jr_000_149b

	ret

LoadModeSelect::
	ld a, IEF_VBLANK
	ld [rIE], a
	xor a
	ld [rSB], a
	ld [rSC], a
	ld [rIF], a

LoadModeSelectScreen::
	call DisableLCD
	call LoadTileset
	ld de, ModeSelectTilemap
	call LoadTilemapA
	call ClearOAM
	ld hl, wSpriteList
	ld de, ModeSelectSpriteList
	ld c, 2
	call LoadSprites
	ld de, wSpriteList sprite 0 + SPRITE_OFFSET_Y
	call UpdateMusicCursor
	ld a, [hGameType]
	ld e, LOW(wSpriteList sprite 1 + SPRITE_OFFSET_X)
	ld [de], a
	assert SPRITE_OFFSET_X + 1 == SPRITE_OFFSET_ID
	inc de
	cp GAME_TYPE_A
	ld a, SPRITE_TYPE_A
	jr z, .got_game_type_sprite
	ld a, SPRITE_TYPE_B
.got_game_type_sprite
	ld [de], a
	call UpdateTwoSprites
	call PlaySelectedMusic
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	ld a, STATE_MODE_SELECT
	ld [hGameState], a
GenericEmptyRoutine2::
	ret

; de = sprite list pointer + SPRITE_OFFSET_Y
UpdateMusicCursor::
	ld a, SFX_CURSOR_BEEP
	ld [wPlaySFX], a

UpdateMusicCursor_NoSFX::
	ld a, [hMusicType]
	push af
	sub MUSIC_TYPE_A
	add a
	ld c, a
	ld b, 0
	ld hl, MusicCursorPositions
	add hl, bc

	ld a, [hl+] ; Y
	ld [de], a
	inc de

	ld a, [hl] ; X
	ld [de], a
	inc de

	pop af
	ld [de], a ; sprite ID
	ret

MusicCursorPositions::
	db 112, 55  ; y, x
	db 112, 119
	db 128, 55
	db 128, 119

HandleMusicSelect::
	ld de, wSpriteList sprite 0
	call HandleBlinkingCursor
	ld hl, hMusicType
	ld a, [hl]
	bit START_BIT, b
	jp nz, HandleModeSelect.pressed_start

	bit A_BUTTON_BIT, b
	jp nz, HandleModeSelect.pressed_start

	bit B_BUTTON_BIT, b
	jr nz, .go_back

.no_going_back:
	inc e ; now DE points to Y coord
	bit D_RIGHT_BIT, b
	jr nz, .pressed_right

	bit D_LEFT_BIT, b
	jr nz, .pressed_left

	bit D_UP_BIT, b
	jr nz, .pressed_up

	bit D_DOWN_BIT, b
	jp z, HandleModeSelect.end ; use local .end to save a byte

	cp MUSIC_TYPE_C
	jr nc, .end
	add 2
.update_cursor:
	ld [hl], a
	call UpdateMusicCursor
	call PlaySelectedMusic

.end: ; sometimes you use HandleModeSelect.end, sometimes you use your own. And it doesn't make sense to do so since you can just JUMP TO UpdateTwoSprites!
	call UpdateTwoSprites
	ret

.pressed_up:
	cp MUSIC_TYPE_C
	jr c, .end
	sub 2
	jr .update_cursor

.pressed_right:
	cp MUSIC_TYPE_B
	jr z, .end
	cp MUSIC_OFF
	jr z, .end
	inc a
	jr .update_cursor

.pressed_left:
	cp MUSIC_TYPE_A
	jr z, .end
	cp MUSIC_TYPE_C
	jr z, .end
	dec a
	jr .update_cursor

.go_back:
	push af
	ld a, [hMultiplayer]
	and a
	jr z, .can_go_back

	pop af
	jr .no_going_back ; The concept of game type A/B does not exist on multiplayer

.can_go_back:
	pop af
	ld a, STATE_MODE_SELECT
	jr HandleModeSelect.got_new_state

PlaySelectedMusic::
	ld a, [hMusicType]
	sub MUSIC_TYPE_A - SONG_A
	cp SONG_C + 1
	jr nz, .got_song_id
	ld a, SONG_STOP
.got_song_id:
	ld [wPlaySong], a
	ret

HandleModeSelect::
	ld de, wSpriteList sprite 1
	call HandleBlinkingCursor
	ld hl, hGameType
	ld a, [hl]
	bit START_BIT, b
	jr nz, .pressed_start

	bit A_BUTTON_BIT, b
	jr nz, .pressed_a

	inc e
	inc e ; now DE is on X coord of cursor
	bit D_RIGHT_BIT, b
	jr nz, .pressed_right

	bit D_LEFT_BIT, b
	jr z, .end ; no interesting button presses

	; pressed left
	cp GAME_TYPE_A
	jr z, .end

	ld a, GAME_TYPE_A
	ld b, SPRITE_TYPE_A
	jr .update_cursor

.pressed_right:
	cp GAME_TYPE_B
	jr z, .end

	ld a, GAME_TYPE_B
	ld b, SPRITE_TYPE_B

.update_cursor:
	ld [hl], a
	push af ; write to [de] sooner so you don't have to save this
	ld a, SFX_CURSOR_BEEP
	ld [wPlaySFX], a
	pop af
	ld [de], a ; X coord
	inc de
	ld a, b

.write_sprite_param:
	ld [de], a ; sprite ID when fallthrough, but hidden/visible when jumping from .got_new_state

.end:
	call UpdateTwoSprites ; why no TCO?
	ret

.pressed_start:
	ld a, SFX_CONFIRM_BEEP
	ld [wPlaySFX], a
	ld a, [hGameType]
	cp GAME_TYPE_A
	ld a, STATE_LOAD_TYPE_A_MENU
	jr z, .got_new_state

	ld a, STATE_LOAD_TYPE_B_MENU
.got_new_state:
	ld [hGameState], a
	xor a
	jr .write_sprite_param

.pressed_a:
	ld a, STATE_MUSIC_SELECT
	jr .got_new_state

LoadTypeAMenu::
	call DisableLCD
	ld de, TypeATilemap
	call LoadTilemapA
	call FillHighscoreTilemapWithDots
	call ClearOAM
	ld hl, wSpriteList
	ld de, TypeAMenuSpriteList
	ld c, 1
	call LoadSprites
	ld de, wSpriteList sprite 0 + SPRITE_OFFSET_Y
	ld a, [hTypeALevel]
	ld hl, TypeAMenuCursorPositions
	call UpdateDigitCursor
	call UpdateTwoSprites
	call RenderTypeAHighscores
	call CopyHighscoresFromTilemapBuffer
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	ld a, $11
	ld [hGameState], a
	ld a, [hHighscoreEnterName]
	and a
	jr nz, jr_000_161e

	call PlaySelectedMusic
	ret


jr_000_161e:
	ld a, STATE_HIGHSCORE_ENTER_NAME

jr_000_1620:
	ld [hGameState], a
	ret

HandleState17::
	ld de, $c200
	call HandleBlinkingCursor
	ld hl, $ffc2
	ld a, $0a
	bit 3, b
	jr nz, jr_000_1620

	bit 0, b
	jr nz, jr_000_1620

	ld a, $08
	bit 1, b
	jr nz, jr_000_1620

	ld a, [hl]
	bit 4, b
	jr nz, jr_000_1655

	bit 5, b
	jr nz, jr_000_166b

	bit 6, b
	jr nz, jr_000_1671

	bit 7, b
	jr z, jr_000_1667

	cp $05
	jr nc, jr_000_1667

	add $05
	jr jr_000_165a

jr_000_1655:
	cp $09
	jr z, jr_000_1667

	inc a

jr_000_165a:
	ld [hl], a
	ld de, $c201
	ld hl, TypeAMenuCursorPositions
	call UpdateDigitCursor
	call RenderTypeAHighscores

jr_000_1667:
	call UpdateTwoSprites
	ret


jr_000_166b:
	and a
	jr z, jr_000_1667

	dec a
	jr jr_000_165a

jr_000_1671:
	cp $05
	jr c, jr_000_1667

	sub $05
	jr jr_000_165a

TypeAMenuCursorPositions::
	db 64, 48
	db 64, 64
	db 64, 80
	db 64, 96
	db 64, 112
	db 80, 48
	db 80, 64
	db 80, 80
	db 80, 96
	db 80, 112

LoadTypeBMenu::
	call DisableLCD
	ld de, $4fef
	call LoadTilemapA
	call ClearOAM
	ld hl, $c200
	ld de, $2735
	ld c, $02
	call LoadSprites
	ld de, $c201
	ld a, [$ff00+$c3]
	ld hl, $1736
	call UpdateDigitCursor
	ld de, $c211
	ld a, [$ff00+$c4]
	ld hl, $17a5
	call UpdateDigitCursor
	call UpdateTwoSprites
	call RenderTypeBHighscores
	call CopyHighscoresFromTilemapBuffer
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	ld a, $13
	ld [hGameState], a
	ld a, [hHighscoreEnterName]
	and a
	jr nz, jr_000_16d4

	call PlaySelectedMusic
	ret


jr_000_16d4:
	ld a, STATE_HIGHSCORE_ENTER_NAME

jr_000_16d6:
	ld [hGameState], a
	ret


jr_000_16d9:
	ld [hGameState], a
	xor a
	ld [de], a
	ret

HandleState19::
	ld de, $c200
	call HandleBlinkingCursor
	ld hl, $ffc3
	ld a, $0a
	bit 3, b
	jr nz, jr_000_16d9

	ld a, $14
	bit 0, b
	jr nz, jr_000_16d9

	ld a, $08
	bit 1, b
	jr nz, jr_000_16d9

	ld a, [hl]
	bit 4, b
	jr nz, jr_000_1712

	bit 5, b
	jr nz, jr_000_1728

	bit 6, b
	jr nz, jr_000_172e

	bit 7, b
	jr z, jr_000_1724

	cp $05
	jr nc, jr_000_1724

	add $05
	jr jr_000_1717

jr_000_1712:
	cp $09
	jr z, jr_000_1724

	inc a

jr_000_1717:
	ld [hl], a
	ld de, $c201
	ld hl, $1736
	call UpdateDigitCursor
	call RenderTypeBHighscores

jr_000_1724:
	call UpdateTwoSprites
	ret


jr_000_1728:
	and a
	jr z, jr_000_1724

	dec a
	jr jr_000_1717

jr_000_172e:
	cp $05
	jr c, jr_000_1724

	sub $05
	jr jr_000_1717

	ld b, b
	jr jr_000_1779

	jr z, jr_000_177b

	jr c, jr_000_177d

	ld c, b
	ld b, b
	ld e, b
	ld d, b
	jr jr_000_1793

	jr z, @+$52

	jr c, jr_000_1797

	ld c, b
	ld d, b
	ld e, b

jr_000_174a:
	ld [hGameState], a
	xor a
	ld [de], a
	ret

HandleState20::
	ld de, $c210
	call HandleBlinkingCursor
	ld hl, $ffc4
	ld a, $0a
	bit 3, b
	jr nz, jr_000_174a

	bit 0, b
	jr nz, jr_000_174a

	ld a, $13
	bit 1, b
	jr nz, jr_000_174a

	ld a, [hl]
	bit 4, b
	jr nz, jr_000_1781

	bit 5, b
	jr nz, jr_000_1797

	bit 6, b
	jr nz, jr_000_179d

	bit 7, b
	jr z, jr_000_1793

jr_000_1779:
	cp $03

jr_000_177b:
	jr nc, jr_000_1793

jr_000_177d:
	add $03
	jr jr_000_1786

jr_000_1781:
	cp $05
	jr z, jr_000_1793

	inc a

jr_000_1786:
	ld [hl], a
	ld de, $c211
	ld hl, $17a5
	call UpdateDigitCursor
	call RenderTypeBHighscores

jr_000_1793:
	call UpdateTwoSprites
	ret


jr_000_1797:
	and a
	jr z, jr_000_1793

	dec a
	jr jr_000_1786

jr_000_179d:
	cp $03
	jr c, jr_000_1793

	sub $03
	jr jr_000_1786

	ld b, b
	ld [hl], b
	ld b, b
	add b
	ld b, b
	sub b
	ld d, b
	ld [hl], b
	ld d, b
	add b
	ld d, b
	sub b
	nop

UpdateDigitCursor:
	push af
	ld a, SFX_CURSOR_BEEP
	ld [wPlaySFX], a
	pop af

UpdateDigitCursor_NoSFX:
	push af
	add a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	inc de
	pop af
	add SPRITE_DIGIT_0
	ld [de], a
	ret

HandleBlinkingCursor::
	ld a, [hKeysPressed]
	ld b, a
	ld a, [hDelayCounter]
	and a
	ret nz

	ld a, 16
	ld [hDelayCounter], a
	ld a, [de]
	xor $80
	ld [de], a
	ret

; hl = wSpriteList pointer
; de = ROM list
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
	length b, wOAMBuffer
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

HandleState10::
	call DisableLCD
	xor a
	ld [$c210], a
	ld [$ff00+$98], a
	ld [$ff00+$9c], a
	ld [$ff00+$9b], a
	ld [hHighscorePtrHi], a
	ld [$ff00+$9f], a
	ld a, $2f
	call Call_000_2032
	call Call_000_204d
	call ResetGameplayVariablesMaybe
	xor a
	ld [$ff00+$e3], a
IF !DEF(INTERNATIONAL)
	ld [$ff00+$e7], a
ENDC
	call ClearOAM
	ld a, [$ff00+$c0]
	ld de, $403f
	ld hl, $ffc3
	cp $77
	ld a, $50
	jr z, jr_000_1aa5

	ld a, $f1
	ld hl, $ffc2
	ld de, $3ed7

jr_000_1aa5:
	push de
	ld [$ff00+$e6], a
	ld a, [hl]
	ld [$ff00+$a9], a
	call LoadTilemapA
	pop de
	ld hl, $9c00
	call LoadTilemap
	ld de, $288d
	ld hl, $9c63
	ld c, $0a
	call Call_000_1fd8
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
	ld hl, $c200
	ld de, $2713
	call Call_000_270a
	ld hl, $c210
	ld de, $271b
	call Call_000_270a
	ld hl, $9951
	ld a, [$ff00+$c0]
	cp $77
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
	call Call_000_2062
	call Call_000_2062
	call Call_000_2062
IF DEF(INTERNATIONAL)
	ld a, [$c0de]
	and a
	jr z, .skip
	ld a, $80
	ld [$c210], a
.skip
ENDC
	call UpdateFirstSprite
	xor a
	ld [$ff00+$a0], a
	ld a, [$ff00+$c0]
	cp $77
	jr nz, jr_000_1b3b

	ld a, $34
	ld [$ff00+$99], a
	ld a, [$ff00+$c4]
	ld hl, $98b0
	ld [hl], a
	ld h, $9c
	ld [hl], a
	and a
	jr z, jr_000_1b3b

	ld b, a
	ld a, [hDemoNumber]
	and a
	jr z, jr_000_1b31

	call Call_000_1b76
	jr jr_000_1b3b

jr_000_1b31:
	ld a, b
	ld de, $ffc0
	ld hl, $9a02
	call Call_000_1bc3

jr_000_1b3b:
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
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
	ld [$ff00+$99], a
	ld [$ff00+$9a], a
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
	ld [$ff00+$a0], a

jr_000_1be8:
	push af
	ld a, l
	and $0f
	cp $0b
	jr nz, jr_000_1bfb

	ld a, [$ff00+$a0]
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
	ld [$ff00+$a0], a
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

HandleState0::
	call Call_000_1c68
	ld a, [$ff00+$ab]
	and a
	ret nz

	call Call_000_0579
	call Call_000_05af
	call Call_000_05f0
	call Call_000_2515
	call Call_000_20f7
	call Call_000_2199
	call Call_000_25f5
	call Call_000_22ad
	call Call_000_1fec
	call Call_000_0620
	ret


jr_000_1c4f:
	bit 2, a
	ret z

	ld a, [$c0de]
	xor $01
	ld [$c0de], a
	jr z, jr_000_1c65

	ld a, $80

jr_000_1c5e:
	ld [$c210], a
	call UpdateSecondSprite
	ret


jr_000_1c65:
	xor a
	jr jr_000_1c5e

Call_000_1c68:
	ld a, [hKeysHeld]
	and $0f
	cp $0f
	jp z, SoftReset

	ld a, [hDemoNumber]
	and a
	ret nz

	ld a, [hKeysPressed]
	bit 3, a
	jr z, jr_000_1c4f

	ld a, [hMultiplayer]
	and a
	jr nz, jr_000_1cc5

	ld hl, $ff40
	ld a, [$ff00+$ab]
	xor $01
	ld [$ff00+$ab], a
	jr z, jr_000_1cb5

	set 3, [hl]
	ld a, $01
	ld [$df7f], a
	ld hl, $994e
	ld de, $9d4e
	ld b, $04

jr_000_1c9a:
	ld a, [rSTAT]
	and $03
	jr nz, jr_000_1c9a

	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_1c9a

	ld a, $80

jr_000_1ca8:
	ld [$c210], a

jr_000_1cab:
	ld [$c200], a
	call UpdateFirstSprite
	call UpdateSecondSprite
	ret


jr_000_1cb5:
	res 3, [hl]
	ld a, $02
	ld [$df7f], a
	ld a, [$c0de]
	and a
	jr z, jr_000_1ca8

	xor a
	jr jr_000_1cab

jr_000_1cc5:
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
HandleState1::
	ld a, $80
	ld [$c200], a
	ld [$c210], a
	call UpdateFirstSprite
	call UpdateSecondSprite
	xor a
	ld [$ff00+$98], a
	ld [$ff00+$9c], a
	call Call_000_22f3
	ld a, $87
	call Call_000_2032
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
	ld [$ff00+$e3], a
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
	ld a, $80
	ld [$c200], a
	ld [$c210], a
	call UpdateFirstSprite
	call UpdateSecondSprite
	call $7ff3
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
	ld hl, $c0a0
	call Call_000_0166
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
	ld de, $5157
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
	call Call_000_0166
	ld de, $c0c4
	ld hl, $99a5
	call Call_000_2a7e
	xor a
	ld [hDelayCounter], a
	pop de
	ld hl, $c0a0
	call Call_000_0166
	ld de, $c0a2
	ld hl, $9a25
	call Call_000_2a82
	ld a, $02
	ld [wPlaySFX], a
	ret


Call_000_1f32:
	ld a, [$c0c6]
	and a
	ret z

	ld a, [$c0c5]
	cp $04
	jr z, jr_000_1ef0

	ld de, $0040
	ld bc, $9823
	ld hl, $c0ac
	and a
	jr z, jr_000_1f6d

	ld de, $0100
	ld bc, $9883
	ld hl, $c0b1
	cp $01
	jr z, jr_000_1f6d

	ld de, $0300
	ld bc, $98e3
	ld hl, $c0b6
	cp $02
	jr z, jr_000_1f6d

	ld de, $1200
	ld bc, $9943
	ld hl, $c0bb

jr_000_1f6d:
	call Call_000_262d
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

	ld a, $04
	ld [wPlaySong], a
	ld a, [hMultiplayer]
	and a
	jr z, jr_000_1f92

	ld a, $3f
	ld [hDelayCounter], a
	ld a, $1b
	ld [hSerialDone], a
	jr jr_000_1fc9

jr_000_1f92:
	ld a, $2f
	call Call_000_2032
	ld hl, $c843
	ld de, $2992
	ld c, $07
	call Call_000_1fd8
	ld hl, $c983
	ld de, $29ca
	ld c, $06
	call Call_000_1fd8
	ld a, [$ff00+$c0]
	cp $37
	jr nz, jr_000_1fc7

	ld hl, $c0a2
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


Call_000_1fd8:
jr_000_1fd8:
	ld b, $08
	push hl

jr_000_1fdb:
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, jr_000_1fdb

	pop hl
	push de
	ld de, $0020
	add hl, de
	pop de
	dec c
	jr nz, jr_000_1fd8

	ret


Call_000_1fec:
	ld a, [$ff00+$c0]
	cp $37
	ret nz

	ld a, [hGameState]
	and a
	ret nz

	ld a, [$ff00+$e3]
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
	ld hl, $c0a0
	call Call_000_0166
	pop de
	pop bc
	dec b
	jr nz, jr_000_2024

	ret


Call_000_2032:
	push af
	ld a, $02
	ld [$ff00+$e3], a
	pop af
	; fallthrough
Call_000_2038:
	ld hl, $c802
	ld c, $12
	ld de, $0020

jr_000_2040:
	push hl
	ld b, $0a

jr_000_2043:
	ld [hl+], a
	dec b
	jr nz, jr_000_2043

	pop hl
	add hl, de
	dec c
	jr nz, jr_000_2040

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


Call_000_2062:
	ld hl, $c200
	ld [hl], $00
	inc l
	ld [hl], $18
	inc l
	ld [hl], $3f
	inc l
	ld a, [$c213]
	ld [hl], a
	and $fc
	ld c, a
	ld a, [hDemoNumber]
	and a
	jr nz, jr_000_207f

	ld a, [hMultiplayer]
	and a
	jr z, jr_000_209c

jr_000_207f:
	ld h, $c3
	ld a, [$ff00+$b0]
	ld l, a
	ld e, [hl]
	inc hl
	ld a, h
	cp $c4
	jr nz, jr_000_208e

	ld hl, $c300

jr_000_208e:
	ld a, l
	ld [$ff00+$b0], a
	ld a, [$ff00+$d3]
	and a
	jr z, jr_000_20c0

	or $80
	ld [$ff00+$d3], a
	jr jr_000_20c0

jr_000_209c:
	ld h, $03

jr_000_209e:
	ld a, [rDIV]
	ld b, a

jr_000_20a1:
	xor a

jr_000_20a2:
	dec b
	jr z, jr_000_20af

	inc a
	inc a
	inc a
	inc a
	cp $1c
	jr z, jr_000_20a1

	jr jr_000_20a2

jr_000_20af:
	ld d, a
	ld a, [$ff00+$ae]
	ld e, a
	dec h
	jr z, jr_000_20bd

	or d
	or c
	and $fc
	cp c
	jr z, jr_000_209e

jr_000_20bd:
	ld a, d
	ld [$ff00+$ae], a

jr_000_20c0:
	ld a, e
	ld [$c213], a
	call UpdateSecondSprite
	ld a, [$ff00+$9a]
	ld [$ff00+$99], a
	ret


jr_000_20cc:
	ld a, [$c0c7]
	and a
	jr z, jr_000_20de

	ld a, [hKeysPressed]
	and $b0
	cp $80
	jr nz, jr_000_20ff

	xor a
	ld [$c0c7], a

jr_000_20de:
	ld a, [hDelayCounter2]
	and a
	jr nz, jr_000_210c

	ld a, [$ff00+$98]
	and a
	jr nz, jr_000_210c

	ld a, [$ff00+$e3]
	and a
	jr nz, jr_000_210c

	ld a, $03
	ld [hDelayCounter2], a
	ld hl, $ffe5
	inc [hl]
	jr jr_000_211d

Call_000_20f7:
	ld a, [hKeysHeld]
	and $b0
	cp $80
	jr z, jr_000_20cc

jr_000_20ff:
	ld hl, $ffe5
	ld [hl], $00
	ld a, [$ff00+$99]
	and a
	jr z, jr_000_2110

	dec a
	ld [$ff00+$99], a

jr_000_210c:
	call UpdateFirstSprite
	ret


jr_000_2110:
	ld a, [$ff00+$98]
	cp $03
	ret z

	ld a, [$ff00+$e3]
	and a
	ret nz

	ld a, [$ff00+$9a]
	ld [$ff00+$99], a

jr_000_211d:
	ld hl, $c201
	ld a, [hl]
	ld [$ff00+$a0], a
	add $08
	ld [hl], a
	call UpdateFirstSprite
	call Call_000_25c7
	and a
	ret z

	ld a, [$ff00+$a0]
	ld hl, $c201
	ld [hl], a
	call UpdateFirstSprite
	ld a, $01
	ld [$ff00+$98], a
	ld [$c0c7], a
	ld a, [$ff00+$e5]
	and a
	jr z, jr_000_215e

	ld c, a
	ld a, [$ff00+$c0]
	cp $37
	jr z, jr_000_2181

	ld de, $c0c0
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	ld b, $00
	dec c
	add hl, bc
	ld a, h
	ld [de], a
	ld a, l
	dec de
	ld [de], a

jr_000_215b:
	xor a
	ld [$ff00+$e5], a

jr_000_215e:
	ld a, [$c201]
	cp $18
	ret nz

	ld a, [$c202]
	cp $3f
	ret nz

	ld hl, $fffb
	ld a, [hl]
	cp $01
	jr nz, jr_000_217f

	call $7ff3
	ld a, $01
	ld [hGameState], a
	ld a, $02
	ld [$dff0], a
	ret


jr_000_217f:
	inc [hl]
	ret


jr_000_2181:
	xor a

jr_000_2182:
	dec c
	jr z, jr_000_2189

	inc a
	daa
	jr jr_000_2182

jr_000_2189:
	ld e, a
	ld d, $00
	ld hl, $c0a0
	call Call_000_0166
	ld a, $01
	ld [$c0ce], a
	jr jr_000_215b

Call_000_2199:
	ld a, [$ff00+$98]
	cp $02
	ret nz

	ld a, $02
	ld [$dff8], a
	xor a
	ld [$ff00+$a0], a
	ld de, $c0a3
	ld hl, $c842
	ld b, $10

jr_000_21ae:
	ld c, $0a
	push hl

jr_000_21b1:
	ld a, [hl+]
	cp $2f
	jp z, Jump_000_2238

	dec c
	jr nz, jr_000_21b1

	pop hl
	ld a, h
	ld [de], a
	inc de
	ld a, l
	ld [de], a
	inc de
	ld a, [$ff00+$a0]
	inc a
	ld [$ff00+$a0], a

jr_000_21c6:
	push de
	ld de, $0020
	add hl, de
	pop de
	dec b
	jr nz, jr_000_21ae

	ld a, $03
	ld [$ff00+$98], a
	dec a
	ld [hDelayCounter], a
	ld a, [$ff00+$a0]
	and a
	ret z

	ld b, a
	ld hl, $ff9e
	ld a, [$ff00+$c0]
	cp $77
	jr z, jr_000_21fb

IF !DEF(INTERNATIONAL)
	ld a, [$ff00+$e7]
	add b
	ld [$ff00+$e7], a
ENDC
	ld a, b
	add [hl]
	daa
	ld [hl+], a
	ld a, $00
	adc [hl]
	daa
	ld [hl], a
	jr nc, jr_000_220a

	ld [hl], $99
	dec hl
	ld [hl], $99
	jr jr_000_220a

jr_000_21fb:
	ld a, [hl]
	or a
	sub b
	jr z, jr_000_223b

	jr c, jr_000_223b

	daa
	ld [hl], a
	and $f0
	cp $90
	jr z, jr_000_223b

jr_000_220a:
	ld a, b
	ld c, $06
	ld hl, $c0ac
	ld b, $00
	cp $01
	jr z, jr_000_222f

	ld hl, $c0b1
	ld b, $01
	cp $02
	jr z, jr_000_222f

	ld hl, $c0b6
	ld b, $02
	cp $03
	jr z, jr_000_222f

	ld hl, $c0bb
	ld b, $04
	ld c, $07

jr_000_222f:
	inc [hl]
	ld a, b
	ld [$ff00+$dc], a
	ld a, c
	ld [wPlaySFX], a
	ret


Jump_000_2238:
	pop hl
	jr jr_000_21c6

jr_000_223b:
	xor a
	ld [$ff00+$9e], a
	jr jr_000_220a

Call_000_2240:
	ld a, [$ff00+$98]
	cp $03
	ret nz

	ld a, [hDelayCounter]
	and a
	ret nz

	ld de, $c0a3
	ld a, [$ff00+$9c]
	bit 0, a
	jr nz, .unk3

	ld a, [de]
	and a
	jr z, .unk5

.outer_loop:
	sub $30
	ld h, a
	inc de
	ld a, [de]
	ld l, a
	ld a, [$ff00+$9c]
	cp $06
	ld a, $8c
	jr nz, .skip

	ld a, $2f

.skip:
	ld c, $0a

.inner_loop:
	ld [hl+], a
	dec c
	jr nz, .inner_loop

	inc de
	ld a, [de]
	and a
	jr nz, .outer_loop

.loop2:
	ld a, [$ff00+$9c]
	inc a
	ld [$ff00+$9c], a
	cp $07
	jr z, .unk1

	ld a, $0a
	ld [hDelayCounter], a
	ret


.unk1:
	xor a
	ld [$ff00+$9c], a
	ld a, $0d
	ld [hDelayCounter], a
	ld a, $01
	ld [$ff00+$e3], a

.unk2:
	xor a
	ld [$ff00+$98], a
	ret


.unk3:
	ld a, [de]
	ld h, a
	sub $30
	ld c, a
	inc de
	ld a, [de]
	ld l, a
	ld b, $0a

.unk4:
	ld a, [hl]
	push hl
	ld h, c
	ld [hl], a
	pop hl
	inc hl
	dec b
	jr nz, .unk4

	inc de
	ld a, [de]
	and a
	jr nz, .unk3

	jr .loop2

.unk5:
	call Call_000_2062
	jr .unk2

Call_000_22ad:
	ld a, [hDelayCounter]
	and a
	ret nz

	ld a, [$ff00+$e3]
	cp $01
	ret nz

	ld de, $c0a3
	ld a, [de]

jr_000_22ba:
	ld h, a
	inc de
	ld a, [de]
	ld l, a
	push de
	push hl
	ld bc, $ffe0
	add hl, bc
	pop de

jr_000_22c5:
	push hl
	ld b, $0a

jr_000_22c8:
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_22c8

	pop hl
	push hl
	pop de
	ld bc, $ffe0
	add hl, bc
	ld a, h
	cp $c7
	jr nz, jr_000_22c5

	pop de
	inc de
	ld a, [de]
	and a
	jr nz, jr_000_22ba

	ld hl, $c802
	ld a, $2f
	ld b, $0a

jr_000_22e7:
	ld [hl+], a
	dec b
	jr nz, jr_000_22e7

	call Call_000_22f3
	ld a, $02
	ld [$ff00+$e3], a
	ret


Call_000_22f3: ; TODO
	ld hl, $c0a3
	xor a
	ld b, $09
.loop:
	ld [hl+], a
	dec b
	jr nz, .loop
	ret


Call_000_22fe:
	ld a, [$ff00+$e3]
	cp $02
	ret nz

	ld hl, $9a22
	ld de, $ca22
	call Call_000_2506
	ret


Call_000_230d:
	ld a, [$ff00+$e3]
	cp $03
	ret nz

	ld hl, $9a02
	ld de, $ca02
	call Call_000_2506
	ret


Call_000_231c:
	ld a, [$ff00+$e3]
	cp $04
	ret nz

	ld hl, $99e2
	ld de, $c9e2
	call Call_000_2506
	ret


Call_000_232b:
	ld a, [$ff00+$e3]
	cp $05
	ret nz

	ld hl, $99c2
	ld de, $c9c2
	call Call_000_2506
	ret


Call_000_233a:
	ld a, [$ff00+$e3]
	cp $06
	ret nz

	ld hl, $99a2
	ld de, $c9a2
	call Call_000_2506
	ret


Call_000_2349:
	ld a, [$ff00+$e3]
	cp $07
	ret nz

	ld hl, $9982
	ld de, $c982
	call Call_000_2506
	ret


Call_000_2358:
	ld a, [$ff00+$e3]
	cp $08
	ret nz

	ld hl, $9962
	ld de, $c962
	call Call_000_2506
	ld a, [hMultiplayer]
	and a
	ld a, [hGameState]
	jr nz, jr_000_2375

	and a
	ret nz

jr_000_236f:
	ld a, $01
	ld [$dff8], a
	ret


jr_000_2375:
	cp $1a
	ret nz

	ld a, [$ff00+$d4]
	and a
	jr z, jr_000_236f

	ld a, $05
	ld [wPlaySFX], a
	ret


Call_000_2383:
	ld a, [$ff00+$e3]
	cp $09
	ret nz

	ld hl, $9942
	ld de, $c942
	call Call_000_2506
	ret


Call_000_2392:
	ld a, [$ff00+$e3]
	cp $0a
	ret nz

	ld hl, $9922
	ld de, $c922
	call Call_000_2506
	ret


Call_000_23a1:
	ld a, [$ff00+$e3]
	cp $0b
	ret nz

	ld hl, $9902
	ld de, $c902
	call Call_000_2506
	ret


Call_000_23b0:
	ld a, [$ff00+$e3]
	cp $0c
	ret nz

	ld hl, $98e2
	ld de, $c8e2
	call Call_000_2506
	ret


Call_000_23bf:
	ld a, [$ff00+$e3]
	cp $0d
	ret nz

	ld hl, $98c2
	ld de, $c8c2
	call Call_000_2506
	ret


Call_000_23ce:
	ld a, [$ff00+$e3]
	cp $0e
	ret nz

	ld hl, $98a2
	ld de, $c8a2
	call Call_000_2506
	ret


Call_000_23dd:
	ld a, [$ff00+$e3]
	cp $0f
	ret nz

	ld hl, $9882
	ld de, $c882
	call Call_000_2506
	ret


Call_000_23ec:
	ld a, [$ff00+$e3]
	cp $10
	ret nz

	ld hl, $9862
	ld de, $c862
	call Call_000_2506
	call Call_000_24ab
	ret


Call_000_23fe:
	ld a, [$ff00+$e3]
	cp $11
	ret nz

	ld hl, $9842
	ld de, $c842
	call Call_000_2506
	ld hl, $9c6d
	call Call_000_249b
	ld a, $01
	ld [$ff00+$e0], a
	ret


Call_000_2417:
	ld a, [$ff00+$e3]
	cp $12
	ret nz

	ld hl, $9822
	ld de, $c822
	call Call_000_2506
	ld hl, $986d
	call Call_000_249b
	ret


Call_000_242c:
	ld a, [$ff00+$e3]
	cp $13
	ret nz

	ld [$c0c7], a
	ld hl, $9802
	ld de, $c802
	call Call_000_2506
	xor a
	ld [$ff00+$e3], a
	ld a, [hMultiplayer]
	and a
	ld a, [hGameState]
	jr nz, .multiplayer

	and a
	ret nz

.unk2449:
	ld hl, $994e
	ld de, $ff9f
	ld c, $02
	ld a, [$ff00+$c0]
	cp $37
	jr z, .unk245f

	ld hl, $9950
	ld de, $ff9e
	ld c, $01

.unk245f:
	call Call_000_2a84
	ld a, [$ff00+$c0]
	cp $37
	jr z, .unk248b

	ld a, [$ff00+$9e]
	and a
	jr nz, .unk248b

	ld a, 100
	ld [hDelayCounter], a
	ld a, SONG_B_END_JINGLE
	ld [wPlaySong], a
	ld a, [hMultiplayer]
	and a
	jr z, .unk247e

	ld [$ff00+$d5], a
	ret

.unk247e:
	ld a, [$ff00+$c3]
	cp $09
	ld a, STATE_05
	jr nz, .unk2488
	ld a, STATE_34
.unk2488:
	ld [hGameState], a
	ret


.unk248b:
	call Call_000_2062
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


Call_000_249b:
	ld a, [hGameState]
	and a
	ret nz

	ld a, [$ff00+$c0]
	cp $37
	ret nz

	ld de, $c0a2
	call Call_000_2a7e
	ret


Call_000_24ab:
	ld a, [hGameState]
	and a
	ret nz

	ld a, [$ff00+$c0]
	cp $37
	ret nz

	ld hl, $ffa9
	ld a, [hl]
	cp $09
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
	ld a, $02
	ld [wPlaySFX], a
	call Call_000_1b43
	ret

jr_000_24fd:
IF DEF(INTERNATIONAL)
	rept 6
	nop
	endr
ENDC
	ld a, [$ff00+$e7]
	cp $14
	ret c

	sub $14
	jr jr_000_24c3

Call_000_2506:
	ld b, $0a

jr_000_2508:
	ld a, [de]
	ld [hl], a
	inc l
	inc e
	dec b
	jr nz, jr_000_2508

	ld a, [$ff00+$e3]
	inc a
	ld [$ff00+$e3], a
	ret


Call_000_2515:
IF DEF(INTERNATIONAL)
	ld hl, $c200
	ld a, [hl]
	cp $80
	ret z
	ld l, $03
ELSE
	ld hl, $c203
ENDC
	ld a, [hl]
	ld [$ff00+$a0], a
	ld a, [hKeysPressed]
	ld b, a
	bit 1, b
	jr nz, jr_000_2534

	bit 0, b
	jr z, jr_000_255d

	ld a, [hl]
	and $03
	jr z, jr_000_252e

	dec [hl]
	jr jr_000_2542

jr_000_252e:
	ld a, [hl]
	or $03
	ld [hl], a
	jr jr_000_2542

jr_000_2534:
	ld a, [hl]
	and $03
	cp $03
	jr z, jr_000_253e

	inc [hl]
	jr jr_000_2542

jr_000_253e:
	ld a, [hl]
	and $fc
	ld [hl], a

jr_000_2542:
	ld a, $03
	ld [wPlaySFX], a
	call UpdateFirstSprite
	call Call_000_25c7
	and a
	jr z, jr_000_255d

	xor a
	ld [wPlaySFX], a
	ld hl, $c203
	ld a, [$ff00+$a0]
	ld [hl], a
	call UpdateFirstSprite

jr_000_255d:
	ld hl, $c202
	ld a, [hKeysPressed]
	ld b, a
	ld a, [hKeysHeld]
	ld c, a
	ld a, [hl]
	ld [$ff00+$a0], a
	bit 4, b
	ld a, $17
	jr nz, jr_000_257b

	bit 4, c
	jr z, jr_000_25a0

	ld a, [hMenuAutoFireCountdown]
	dec a
	ld [hMenuAutoFireCountdown], a
	ret nz

	ld a, $09

jr_000_257b:
	ld [hMenuAutoFireCountdown], a
	ld a, [hl]
	add $08
	ld [hl], a
	call UpdateFirstSprite
	ld a, $04
	ld [wPlaySFX], a
	call Call_000_25c7
	and a
	ret z

jr_000_258e:
	ld hl, $c202
	xor a
	ld [wPlaySFX], a
	ld a, [$ff00+$a0]
	ld [hl], a
	call UpdateFirstSprite
	ld a, $01

jr_000_259d:
	ld [hMenuAutoFireCountdown], a
	ret


jr_000_25a0:
	bit 5, b
	ld a, $17
	jr nz, jr_000_25b2

	bit 5, c
	jr z, jr_000_259d

	ld a, [hMenuAutoFireCountdown]
	dec a
	ld [hMenuAutoFireCountdown], a
	ret nz

	ld a, $09

jr_000_25b2:
	ld [hMenuAutoFireCountdown], a
	ld a, [hl]
	sub $08
	ld [hl], a
	ld a, $04
	ld [wPlaySFX], a
	call UpdateFirstSprite
	call Call_000_25c7
	and a
	ret z

	jr jr_000_258e

Call_000_25c7:
	ld hl, $c010
	ld b, $04

jr_000_25cc:
	ld a, [hl+]
	ld [$ff00+$b2], a
	ld a, [hl+]
	and a
	jr z, jr_000_25ea

	ld [$ff00+$b3], a
	push hl
	push bc
	call Call_000_2a2b
	ld a, h
	add $30
	ld h, a
	ld a, [hl]
	cp $2f
	jr nz, jr_000_25ee

	pop bc
	pop hl
	inc l
	inc l
	dec b
	jr nz, jr_000_25cc

jr_000_25ea:
	xor a
	ld [$ff00+$9b], a
	ret


jr_000_25ee:
	pop bc
	pop hl
	ld a, $01
	ld [$ff00+$9b], a
	ret


Call_000_25f5:
	ld a, [$ff00+$98]
	cp $01
	ret nz

	ld hl, $c010
	ld b, $04

jr_000_25ff:
	ld a, [hl+]
	ld [$ff00+$b2], a
	ld a, [hl+]
	and a
	jr z, jr_000_2623

	ld [$ff00+$b3], a
	push hl
	push bc
	call Call_000_2a2b
	push hl
	pop de
	pop bc
	pop hl

jr_000_2611:
	ld a, [rSTAT]
	and $03
	jr nz, jr_000_2611

	ld a, [hl]
	ld [de], a
	ld a, d
	add $30
	ld d, a
	ld a, [hl+]
	ld [de], a
	inc l
	dec b
	jr nz, jr_000_25ff

jr_000_2623:
	ld a, $02
	ld [$ff00+$98], a
	ld hl, $c200
	ld [hl], $80
	ret


Call_000_262d:
	ld a, [$c0c6]
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
	call Call_000_0166
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
	call Call_000_2a82
	pop de
	ld a, [$ff00+$c3]
	ld b, a
	inc b
	ld hl, $c0a0

jr_000_266c:
	push hl
	call Call_000_0166
	pop hl
	dec b
	jr nz, jr_000_266c

	ld a, $02
	ld [$c0c6], a
	ret


jr_000_267a:
	ld de, $c0a2
	ld hl, $9a25
	call Call_000_2a82
	ld a, $02
	ld [wPlaySFX], a
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

	ld a, $04
	ld [hGameState], a
	ret


ResetGameplayVariablesMaybe:: ; TODO
	ld hl, $c0ac
	ld b, $1b
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

UpdateFirstSprite::
	ld a, 1
	ld [hSpriteCount], a
	ld a, 4 * 4
	ld [hOAMBufferPtrLo], a
	ld a, HIGH(wOAMBuffer)
	ld [hOAMBufferPtrHi], a
	ld hl, wSpriteList sprite 0
	call UpdateSprites
	ret

UpdateSecondSprite::
	ld a, 1
	ld [hSpriteCount], a
	ld a, 8 * 4
	ld [hOAMBufferPtrLo], a
	ld a, HIGH(wOAMBuffer)
	ld [hOAMBufferPtrHi], a
	ld hl, wSpriteList sprite 1
	call UpdateSprites
	ret

unk26fd::
	ld b, $20
	ld a, $8e
	ld de, BG_MAP_WIDTH
.loop:
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loop
	ret


Call_000_270a:
jr_000_270a:
	ld a, [de]
	cp $ff
	ret z

	ld [hl+], a
	inc de
	jr jr_000_270a

EmptyInterrupt:
	reti

	nop
	jr jr_000_2755

	nop
	add b
	nop
	nop
	rst $38
	nop
	add b
	adc a
	nop
	add b
	nop
	nop
	rst $38

ModeSelectSpriteList::
	db SPRITE_VISIBLE, 112, 55, SPRITE_TYPE_A, 0, 0
	db SPRITE_VISIBLE, 56,  55, SPRITE_TYPE_A, 0, 0

TypeAMenuSpriteList::
	db SPRITE_VISIBLE, 64, 52, SPRITE_DIGIT_0, 0, 0

	nop
	ld b, b
	inc e
	jr nz, jr_000_273a

jr_000_273a:
	nop
	nop
	ld b, b
	ld [hl], h
	jr nz, jr_000_2740

jr_000_2740:
	nop
	nop
	ld b, b
	ld l, b
	ld hl, $0000
	nop
	ld a, b
	ld l, b
	ld hl, $0000
	nop
	ld h, b
	ld h, b
	ld a, [hl+]
	add b
	nop
	nop
	ld h, b

jr_000_2755:
	ld [hl], d
	ld a, [hl+]
	add b
	jr nz, jr_000_275a

jr_000_275a:
	ld l, b
	jr c, jr_000_279b

	add b
	nop
	nop
	ld h, b
	ld h, b
	ld [hl], $80
	nop
	nop
	ld h, b
	ld [hl], d
	ld [hl], $80
	jr nz, jr_000_276c

jr_000_276c:
	ld l, b
	jr c, jr_000_27a1

	add b
	nop
	nop
	ld h, b
	ld h, b
	ld l, $80
	nop
	nop
	ld l, b
	jr c, jr_000_27b7

	add b
	nop
	nop
	ld h, b
	ld h, b
	ld a, [hl-]
	add b
	nop
	nop
	ld l, b
	jr c, jr_000_27b7

	add b
	nop
	add b
	ccf
	ld b, b
	ld b, h
	nop
	nop
	add b
	ccf
	jr nz, jr_000_27dd

	nop
	nop
	add b
	ccf
	jr nc, jr_000_27df

	nop
	nop

jr_000_279b:
	add b
	ld [hl], a
	jr nz, jr_000_27e7

	nop
	nop

jr_000_27a1:
	add b
	add a
	ld c, b
	ld c, h
	nop
	nop
	add b
	add a
	ld e, b
	ld c, [hl]
	nop
	nop
	add b
	ld h, a
	ld c, l
	ld d, b
	nop
	nop
	add b
	ld h, a
	ld e, l
	ld d, d

jr_000_27b7:
	nop
	nop
	add b
	adc a
	adc b
	ld d, h
	nop
	nop
	add b
	adc a
	sbc b
	ld d, l
	nop
	nop
	nop
	ld e, a
	ld d, a
	inc l
	nop
	nop
	add b
	add b
	ld d, b
	inc [hl]
	nop
	nop
	add b
	add b
	ld h, b
	inc [hl]
	nop
	jr nz, jr_000_27d8

jr_000_27d8:
	ld l, a
	ld d, a
	ld e, b
	nop
	nop

jr_000_27dd:
	add b
	add b

jr_000_27df:
	ld d, l
	inc [hl]
	nop
	nop
	add b
	add b
	ld e, e
	inc [hl]

jr_000_27e7:
	db $00, $20

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
	length bc, GFX_Common
	call CopyBytes
	ld hl, GFX_Common2
	ld de, vBGTiles tile $30 ; redundant. You even make use of this three lines above.
	length bc, GFX_Common2
	call CopyBytes ; why no TCO?
	ret


LoadFont::
	ld hl, GFX_Font
	length bc, GFX_Font
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
	ld bc, $0da0
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
	ld [$ff00+$e3], a
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


	cpl
	cpl
	ld de, $1d12
	cpl
	cpl
	cpl
	cpl
	cpl
	add hl, hl
	add hl, hl
	add hl, hl
	cpl
	cpl
	cpl
	cpl
	inc e
	dec e
	ld a, [bc]
	dec de
	dec e
	cpl
	cpl
	cpl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	cpl
	cpl
	cpl
	cpl
	cpl
	dec e
	jr jr_000_28e2

	cpl
	cpl
	cpl
	cpl
	cpl
	add hl, hl
	add hl, hl
	cpl
	cpl
	cpl
	inc c
	jr jr_000_28d7

	dec e
	ld [de], a
	rla
	ld e, $0e
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	cpl
	cpl
	DB $10
	ld a, [bc]
	ld d, $0e
	cpl
	cpl
	cpl
	cpl

jr_000_28d7:
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	cpl
	cpl
	inc e
	ld [de], a
	rla
	DB $10
	dec d

jr_000_28e2:
	ld c, $2f
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	ld h, $2f
	inc b
	nop
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	dec c
	jr jr_000_291c

	dec bc
	dec d
	ld c, $2f
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	ld h, $2f
	ld bc, $0000
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	dec e
	dec de
	ld [de], a

jr_000_291c:
	add hl, de
	dec d
	ld c, $2f
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	ld h, $2f
	inc bc
	nop
	nop
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	dec e
	ld c, $1d
	dec de
	ld [de], a
	inc e
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	ld h, $2f
	ld bc, $0002
	nop
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	dec c
	dec de
	jr jr_000_2972

	inc e
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl

jr_000_2972:
	cpl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	dec e
	ld de, $1c12
	cpl
	inc e
	dec e
	ld a, [bc]
	DB $10
	ld c, $2f
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	nop
	cpl
	rst $38
	ld h, c
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, d
	ld h, e
	ld h, h
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld h, l
	ld h, h
	cpl
	DB $10
	ld a, [bc]
	ld d, $0e
	cpl
	ld h, l
	ld h, h
	cpl
	xor l
	xor l
	xor l
	xor l
	cpl
	ld h, l
	ld h, h
	cpl
	jr jr_000_29d5

	ld c, $1b
	cpl
	ld h, l
	ld h, h
	cpl
	xor l
	xor l
	xor l
	xor l
	cpl
	ld h, l
	ld h, [hl]
	ld l, c
	ld l, c
	ld l, c
	ld l, c
	ld l, c
	ld l, c
	ld l, d
	add hl, de
	dec d
	ld c, $0a
	inc e
	ld c, $2f
	cpl
	add hl, hl
	add hl, hl
	add hl, hl

jr_000_29d5:
	add hl, hl
	add hl, hl
	add hl, hl
	cpl
	cpl
	cpl
	dec e
	dec de
	ld [hl+], a
	cpl
	cpl
	cpl
	cpl
	cpl
	add hl, hl
	add hl, hl
	add hl, hl
	cpl
	cpl
	cpl
	cpl
	cpl
	cpl
	ld a, [bc]
	DB $10
	ld a, [bc]
	ld [de], a
	rla
	daa
	cpl
	cpl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	cpl

ReadJoypad::
	ld a, JOYP_DPAD
	ld [rJOYP], a
	ld a, [rJOYP]
	ld a, [rJOYP]
IF DEF(INTERNATIONAL)
	ld a, [rJOYP]
	ld a, [rJOYP]
ENDC
	cpl
	and $0f
	swap a
	ld b, a
	ld a, JOYP_BUTTONS
	ld [rJOYP], a
	ld a, [rJOYP]
	ld a, [rJOYP]
	ld a, [rJOYP]
	ld a, [rJOYP]
	ld a, [rJOYP]
	ld a, [rJOYP]
IF DEF(INTERNATIONAL)
	ld a, [rJOYP]
	ld a, [rJOYP]
	ld a, [rJOYP]
	ld a, [rJOYP]
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

Call_000_2a2b:
	ld a, [$ff00+$b2]
	sub $10
	srl a
	srl a
	srl a
	ld de, $0000
	ld e, a
	ld hl, $9800
	ld b, $20

jr_000_2a3e:
	add hl, de
	dec b
	jr nz, jr_000_2a3e

	ld a, [$ff00+$b3]
	sub $08
	srl a
	srl a
	srl a
	ld de, $0000
	ld e, a
	add hl, de
	ld a, h
	ld [$ff00+$b5], a
	ld a, l
	ld [$ff00+$b4], a
	ret


	ld a, [$ff00+$b5]
	ld d, a
	ld a, [$ff00+$b4]
	ld e, a
	ld b, $04

jr_000_2a60:
	rr d
	rr e
	dec b
	jr nz, jr_000_2a60

	ld a, e
	sub $84
	and $fe
	rlca
	rlca
	add $08
	ld [$ff00+$b2], a
	ld a, [$ff00+$b4]
	and $1f
	rla
	rla
	rla
	add $08
	ld [$ff00+$b3], a
	ret


Call_000_2a7e:
	ld a, [$ff00+$e0]
	and a
	ret z

Call_000_2a82:
	ld c, $03

Call_000_2a84:
	xor a
	ld [$ff00+$e0], a

jr_000_2a87:
	ld a, [de]
	ld b, a
	swap a
	and $0f
	jr nz, jr_000_2ab7

	ld a, [$ff00+$e0]
	and a
	ld a, $00
	jr nz, jr_000_2a98

	ld a, $2f

jr_000_2a98:
	ld [hl+], a
	ld a, b
	and $0f
	jr nz, jr_000_2abf

	ld a, [$ff00+$e0]
	and a
	ld a, $00
	jr nz, jr_000_2aae

	ld a, $01
	cp c
	ld a, $00
	jr z, jr_000_2aae

	ld a, $2f

jr_000_2aae:
	ld [hl+], a
	dec e
	dec c
	jr nz, jr_000_2a87

	xor a
	ld [$ff00+$e0], a
	ret


jr_000_2ab7:
	push af
	ld a, $01
	ld [$ff00+$e0], a
	pop af
	jr jr_000_2a98

jr_000_2abf:
	push af
	ld a, $01
	ld [$ff00+$e0], a
	pop af
	jr jr_000_2aae

INCLUDE "sprites.asm"

GFX_Common2::
INCBIN "gfx/common2.2bpp"
GFX_Common2_End::

IF DEF(INTERNATIONAL)
	INCBIN "baserom11.gb", $3f3f, $4000 - $3f3f
ELSE
	INCBIN "baserom.gb", $3f87, $4000 - $3f87
ENDC
