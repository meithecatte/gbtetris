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
	ld a, PULSESFX_CURSOR_BEEP
	ld [wPlayPulseSFX], a

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
	ld a, PULSESFX_CURSOR_BEEP
	ld [wPlayPulseSFX], a
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
	ld a, PULSESFX_CONFIRM_BEEP
	ld [wPlayPulseSFX], a
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
	ld de, TypeAMenuTilemap
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
	call VBlank_HighscoreTilemap
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	ld a, STATE_TYPE_A_MENU
	ld [hGameState], a
	ld a, [hHighscoreEnterName]
	and a
	jr nz, .go_highscore

	call PlaySelectedMusic
	ret

.go_highscore:
	ld a, STATE_HIGHSCORE_ENTER_NAME

.set_game_state:
	ld [hGameState], a
	ret

HandleTypeAMenu::
	ld de, wSpriteList sprite 0
	call HandleBlinkingCursor
	ld hl, hTypeALevel
	ld a, STATE_LOAD_PLAYFIELD
	bit START_BIT, b
	jr nz, LoadTypeAMenu.set_game_state

	bit A_BUTTON_BIT, b
	jr nz, LoadTypeAMenu.set_game_state

	ld a, STATE_LOAD_MODE_SELECT
	bit B_BUTTON_BIT, b
	jr nz, LoadTypeAMenu.set_game_state

	ld a, [hl]
	bit D_RIGHT_BIT, b
	jr nz, .pressed_right
	bit D_LEFT_BIT, b
	jr nz, .pressed_left
	bit D_UP_BIT, b
	jr nz, .pressed_up
	bit D_DOWN_BIT, b
	jr z, .end

	cp 5
	jr nc, .end
	add 5
	jr .write_back

.pressed_right:
	cp 9
	jr z, .end
	inc a
.write_back:
	ld [hl], a
	ld de, wSpriteList sprite 0 + SPRITE_OFFSET_Y
	ld hl, TypeAMenuCursorPositions
	call UpdateDigitCursor
	call RenderTypeAHighscores

.end:
	call UpdateTwoSprites ; why no TCO?
	ret

.pressed_left:
	and a
	jr z, .end
	dec a
	jr .write_back

.pressed_up:
	cp 5
	jr c, .end
	sub 5
	jr .write_back

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
	ld de, TypeBMenuTilemap
	call LoadTilemapA
	call ClearOAM
	ld hl, wSpriteList
	ld de, TypeBMenuSpriteList
	ld c, 2
	call LoadSprites
	ld de, wSpriteList sprite 0 + SPRITE_OFFSET_Y
	ld a, [hTypeBLevel]
	ld hl, TypeBMenuLevelCursorPositions
	call UpdateDigitCursor
	ld de, wSpriteList sprite 1 + SPRITE_OFFSET_Y
	ld a, [hTypeBHigh]
	ld hl, TypeBMenuHighCursorPositions
	call UpdateDigitCursor
	call UpdateTwoSprites
	call RenderTypeBHighscores
	call VBlank_HighscoreTilemap
	ld a, LCDCF_ON | LCDCF_WIN9C00 | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJON | LCDCF_BGON
	ld [rLCDC], a
	ld a, STATE_TYPE_B_LEVEL_SELECT
	ld [hGameState], a
	ld a, [hHighscoreEnterName]
	and a
	jr nz, .go_highscore

	call PlaySelectedMusic
	ret

.go_highscore:
	ld a, STATE_HIGHSCORE_ENTER_NAME
	ld [hGameState], a
	ret

HandleTypeBLevelSelect_SetState:
	ld [hGameState], a
	xor a
	ld [de], a
	ret

HandleTypeBLevelSelect::
	ld de, wSpriteList sprite 0
	call HandleBlinkingCursor
	ld hl, $ffc3
	ld a, STATE_LOAD_PLAYFIELD
	bit START_BIT, b
	jr nz, HandleTypeBLevelSelect_SetState

	ld a, STATE_TYPE_B_HIGH_SELECT
	bit A_BUTTON_BIT, b
	jr nz, HandleTypeBLevelSelect_SetState

	ld a, STATE_LOAD_MODE_SELECT
	bit B_BUTTON_BIT, b
	jr nz, HandleTypeBLevelSelect_SetState

	ld a, [hl]
	bit D_RIGHT_BIT, b
	jr nz, .pressed_right

	bit D_LEFT_BIT, b
	jr nz, .pressed_left

	bit D_UP_BIT, b
	jr nz, .pressed_up

	bit D_DOWN_BIT, b
	jr z, .end

	cp 5
	jr nc, .end
	add 5
	jr .write_back

.pressed_right:
	cp $09
	jr z, .end
	inc a
.write_back:
	ld [hl], a
	ld de, wSpriteList sprite 0 + SPRITE_OFFSET_Y
	ld hl, TypeBMenuLevelCursorPositions
	call UpdateDigitCursor
	call RenderTypeBHighscores
.end:
	call UpdateTwoSprites ; why no TCO?
	ret

.pressed_left:
	and a
	jr z, .end
	dec a
	jr .write_back

.pressed_up:
	cp 5
	jr c, .end
	sub 5
	jr .write_back

TypeBMenuLevelCursorPositions::
	db 64, 24
	db 64, 40
	db 64, 56
	db 64, 72
	db 64, 88
	db 80, 24
	db 80, 40
	db 80, 56
	db 80, 72
	db 80, 88

HantleTypeBHighSelect_SetState:
	ld [hGameState], a
	xor a
	ld [de], a
	ret

HandleTypeBHighSelect::
	ld de, wSpriteList sprite 1
	call HandleBlinkingCursor
	ld hl, hTypeBHigh

	ld a, STATE_LOAD_PLAYFIELD
	bit START_BIT, b
	jr nz, HantleTypeBHighSelect_SetState

	bit A_BUTTON_BIT, b
	jr nz, HantleTypeBHighSelect_SetState

	ld a, STATE_TYPE_B_LEVEL_SELECT
	bit B_BUTTON_BIT, b
	jr nz, HantleTypeBHighSelect_SetState

	ld a, [hl]
	bit D_RIGHT_BIT, b
	jr nz, .pressed_right
	bit D_LEFT_BIT, b
	jr nz, .pressed_left
	bit D_UP_BIT, b
	jr nz, .pressed_up
	bit D_DOWN_BIT, b
	jr z, .end

	cp 3
	jr nc, .end
	add 3
	jr .write_back

.pressed_right:
	cp 5
	jr z, .end
	inc a
.write_back:
	ld [hl], a
	ld de, wSpriteList sprite 1 + SPRITE_OFFSET_Y
	ld hl, TypeBMenuHighCursorPositions
	call UpdateDigitCursor
	call RenderTypeBHighscores
.end:
	call UpdateTwoSprites
	ret

.pressed_left:
	and a
	jr z, .end
	dec a
	jr .write_back

.pressed_up:
	cp 3
	jr c, .end
	sub 3
	jr .write_back

TypeBMenuHighCursorPositions::
	db 64, 112
	db 64, 128
	db 64, 144
	db 80, 112
	db 80, 128
	db 80, 144

	db 0 ; AFAIK, this serves no purpose

UpdateDigitCursor:
	push af
	ld a, PULSESFX_CURSOR_BEEP
	ld [wPlayPulseSFX], a
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
