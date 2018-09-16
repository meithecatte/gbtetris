LoadCopyrightScreen::
	call DisableLCD
	call LoadTitlescreenTileset
	ld de, CopyrightTilemap
	call LoadTilemapA
	call ClearOAM

	ld hl, wRandomness
	ld de, DemoRandomness
.loop:
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, h
	cp HIGH(wRandomness) + 1
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
	ld [hRecordDemo], a
	ld [hLockdownStage], a
	ld [hBlinkCounter], a
	ld [hCollisionOccured_NeverRead], a
	ld [hFailedTetrominoPlacements], a
	ld [$ff00+$9f], a
	ld [hRowToShift], a
IF !DEF(INTERNATIONAL)
	ld [$ff00+$e7], a
ENDC
	ld [hHighscoreEnterName], a
	call ClearedLinesListReset
	call ResetGameplayVariablesMaybe
	call LoadTitlescreenTileset

	ld hl, wTileMap
.clear_tilemap
	ld a, " "
	ld [hl+], a
	ld a, h
	cp HIGH(wTileMap + BG_MAP_WIDTH * BG_MAP_HEIGHT)
	jr nz, .clear_tilemap

	; essentially dead code
	ld hl, wTileMap + 0 * BG_MAP_WIDTH + 1
	call DrawBlackVerticalStrip
	ld hl, wTileMap + 0 * BG_MAP_WIDTH + 12
	call DrawBlackVerticalStrip

	ld hl, wTileMap + 18 * BG_MAP_WIDTH + 1 ; offscreen
	ld b, 12
	ld a, $8e ; this is already set by DrawBlackVerticalStrip

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

	ld a, SONG_TITLESCREEN
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
	ld a, GAME_TYPE_A
	ld [hGameType], a
	ld a, 9
	ld [hTypeALevel], a
	xor a
	ld [hMultiplayer], a
	ld [hRandomnessPtrLo], a
	ld [hLastDemoInput], a
	ld [hCountdownTillNextDemoInput], a
	ld a, HIGH(DemoDataTypeA)
	ld [hDemoPtrHi], a
	ld a, LOW(DemoDataTypeA)
	ld [hDemoPtrLo], a
	ld a, [hDemoNumber]
	cp DEMO_TYPE_A
	ld a, DEMO_TYPE_A
	jr nz, .got_params

	ld a, GAME_TYPE_B
	ld [hGameType], a
	ld a, 9
	ld [hTypeBLevel], a
	ld a, 2
	ld [hTypeBHigh], a
	ld a, HIGH(DemoDataTypeB)
	ld [hDemoPtrHi], a
	ld a, LOW(DemoDataTypeB)
	ld [hDemoPtrLo], a ; this is set to the same value above...
	ld a, DemoRandomnessTypeB - DemoRandomness
	ld [hRandomnessPtrLo], a
	ld a, DEMO_TYPE_B

.got_params:
	ld [hDemoNumber], a
	ld a, STATE_LOAD_PLAYFIELD
	ld [hGameState], a
	call DisableLCD
	call LoadTileset
	ld de, ModeSelectTilemap
	call LoadTilemapA
	call ClearOAM
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	ret

Unused_StartDemoRecording::
	ld a, DEMO_RECORD
	ld [hRecordDemo], a
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
