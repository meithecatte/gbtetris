RenderTypeAHighscores:
	call FillHighscoreTilemapWithDots

	; find the pointer to the highscores corresponding to the level that is selected
	ld a, [hTypeALevel]
	ld hl, wTypeAHighscores
	ld de, HIGHSCORE_ENTRY_SIZE * HIGHSCORE_ENTRY_COUNT
.level_loop:
	and a
	jr z, .got_level_pointer

	dec a
	add hl, de
	jr .level_loop
.got_level_pointer:
	inc hl
	inc hl
	push hl ; ld d, h / ld l, e is 12 T-cycles faster
	pop de

	call RenderHighscores ; why no TCO?
	ret

RenderTypeBHighscores:
	call FillHighscoreTilemapWithDots
	ld a, [hTypeBLevel]
	ld hl, wTypeBHighscores
	ld de, HIGHSCORE_ENTRY_SIZE * HIGHSCORE_ENTRY_COUNT * TYPE_B_HIGH_COUNT

	; find the pointer to the highscores corresponding to the level and "high" that is selected
.level_loop:
	and a
	jr z, .got_level_pointer

	dec a
	add hl, de
	jr .level_loop

.got_level_pointer:
	ld a, [hTypeBHigh]
	ld de, HIGHSCORE_ENTRY_SIZE * HIGHSCORE_ENTRY_COUNT

.high_loop:
	and a
	jr z, .got_final_pointer

	dec a
	add hl, de
	jr .high_loop

.got_final_pointer:
	inc hl
	inc hl
	push hl
	pop de
	call RenderHighscores ; why no TCO?
	ret

DisplayHighscore:
	assert "0" == 0
	ld b, SCORE_SIZE

.skip_leading_zeroes:
	ld a, [hl]
	and $f0
	jr nz, .display_bcd_byte

	inc e
	ld a, [hl-]
	and $0f
	jr nz, .start_from_the_middle_of_a_byte

	inc e
	dec b
	jr nz, .skip_leading_zeroes
	ret

.display_bcd_byte:
	ld a, [hl]
	and $f0
	swap a
	ld [de], a
	inc e
	ld a, [hl-]
	and $0f

.start_from_the_middle_of_a_byte:
	ld [de], a
	inc e
	dec b
	jr nz, .display_bcd_byte
	ret

CopyHighscore:
	ld b, SCORE_SIZE

.loop:
	ld a, [hl-]
	ld [de], a
	dec de
	dec b
	jr nz, .loop
	ret

RenderHighscores::
; DE = highscore block for level + 2 (points at the end of first highscore)
	ld a, d
	ld [hHighscorePtrHi], a
	ld a, e
	ld [hHighscorePtrLo], a
	ld c, HIGHSCORE_ENTRY_COUNT

	; find a place for the new score

.entry_loop:
	ld hl, wScore + SCORE_SIZE - 1
	push de
	ld b, SCORE_SIZE

.byte_loop:
	ld a, [de]
	sub [hl]
	; the new score is larger
	jr c, .found_position

	; the new score is smaller
	jr nz, .next_entry

	; this byte is equal, compare less significant byte
	dec l ; assumes wScore does not cross a 256-byte boundary ( assert LOW(wScore) < $fe )
	dec de
	dec b
	jr nz, .byte_loop

	; if there's no less significant byte (the scores are equal), fall through
	; this gives priority to the earlier score
.next_entry:
	pop de

REPT SCORE_SIZE
	inc de
ENDR

	dec c
	jr nz, .entry_loop

	jr .no_place_for_new_score

.found_position:
	; discard the address pushed by the loop
	pop de
	ld a, [hHighscorePtrHi]
	ld d, a
	ld a, [hHighscorePtrLo]
	ld e, a
	; de points at the end of the first highscore
	push de
	push bc
	ld hl, (HIGHSCORE_ENTRY_COUNT - 1) * SCORE_SIZE
	add hl, de
	push hl
	pop de

REPT SCORE_SIZE
	dec hl
ENDR

.shift_other_scores:
	dec c
	jr z, .finished_shifting_scores

	call CopyHighscore
	jr .shift_other_scores

.finished_shifting_scores:
	ld hl, wScore + SCORE_SIZE - 1
	ld b, SCORE_SIZE ; could just call CopyHighscore

.copy_new_score:
	ld a, [hl-]
	ld [de], a
	dec e ; for all h in [0, 7), l in [0, 10), s in [0, 3), h * 270 + l * 27 + s * 3 < 253 (mod 256)
	dec b
	jr nz, .copy_new_score

	pop bc
	pop de
	; de points at the end of first score
	ld a, c
	ld [hHighscorePosition], a
	ld hl, (HIGHSCORE_ENTRY_COUNT - 1) * SCORE_SIZE + (HIGHSCORE_ENTRY_COUNT - 1) * HIGHSCORE_NAME_LENGTH
	add hl, de
	push hl
	ld de, HIGHSCORE_NAME_LENGTH
	add hl, de
	push hl
	pop de
	pop hl
	; de points at the end of the last name
	; hl points at the end of the second to last name

.shift_other_names:
	dec c
	jr z, .finished_shifting_names

	ld b, HIGHSCORE_NAME_LENGTH
	call CopyHighscore.loop
	jr .shift_other_names

.finished_shifting_names:
	ld a, "..."
	ld b, HIGHSCORE_NAME_LENGTH - 1

.fill_name_with_dots:
	ld [de], a
	dec de
	dec b
	jr nz, .fill_name_with_dots

	ld a, "A"
	ld [de], a
	ld a, d
	ld [hHighscoreNamePointerHi], a
	ld a, e
	ld [hHighscoreNamePointerLo], a
	xor a
	ld [hHighscoreBlink], a
	ld [hHighscoreLettersEntered], a
	ld a, SONG_HIGHSCORE
	ld [wPlaySong], a
	assert SONG_HIGHSCORE != 0
	ld [hHighscoreEnterName], a

.no_place_for_new_score:
	ld de, wTileMap + 13 * BG_MAP_WIDTH + 12
	ld a, [hHighscorePtrHi]
	ld h, a
	ld a, [hHighscorePtrLo]
	ld l, a
	ld b, HIGHSCORE_ENTRY_COUNT

.display_scores:
	push hl
	push de
	push bc
	call DisplayHighscore
	pop bc
	pop de

	ld hl, BG_MAP_WIDTH
	add hl, de
	push hl
	pop de

	pop hl

	push de
	ld de, SCORE_SIZE
	add hl, de
	pop de

	dec b
	jr nz, .display_scores

	dec hl
	dec hl
	ld b, HIGHSCORE_ENTRY_COUNT
	ld de, wTileMap + 13 * BG_MAP_WIDTH + 4

.name_loop:
	push de
	ld c, HIGHSCORE_NAME_LENGTH

.name_byte_loop:
	ld a, [hl+]
	and a
	jr z, .name_end

	ld [de], a
	inc de
	dec c
	jr nz, .name_byte_loop

.name_end:
	pop de
	push hl

	ld hl, BG_MAP_WIDTH
	add hl, de
	push hl
	pop de

	pop hl
	dec b
	jr nz, .name_loop

	call ResetGameplayVariablesMaybe
	ld a, 1
	ld [hEnableHighscoreVBlank], a
	ret

CopyHighscoresFromTilemapBuffer::
	ld a, [hEnableHighscoreVBlank]
	and a
	ret z

	ld hl, vBGMapA  + 13 * BG_MAP_WIDTH + 4
	ld de, wTileMap + 13 * BG_MAP_WIDTH + 4
	ld c, 6

.row_loop:
	push hl

.area_loop:
	assert SCORE_SIZE * 2 == HIGHSCORE_NAME_LENGTH
	ld b, HIGHSCORE_NAME_LENGTH

.tile_loop:
	ld a, [de]
	ld [hl+], a
	inc e
	dec b
	jr nz, .tile_loop

	inc e ; skip the two tiles between the name and the score
	inc l
	inc e
	inc l

	dec c
	jr z, .end

	bit 0, c
	jr nz, .area_loop

	pop hl
	ld de, BG_MAP_WIDTH
	add hl, de

	push hl ; ld h, d / ld l, e takes 12 T-cycles less
	pop de

	ld a, HIGH(wTileMap - vBGMapA)
	add d
	ld d, a
	jr .row_loop

.end:
	pop hl
	xor a
	ld [hEnableHighscoreVBlank], a
	ret

FillHighscoreTilemapWithDots::
	ld hl, wTileMap + 13 * BG_MAP_WIDTH + 4
	ld de, BG_MAP_WIDTH
	ld a, "..."
	ld c, HIGHSCORE_ENTRY_COUNT

.row_loop:
	ld b, 14
	push hl

.tile_loop:
	ld [hl+], a
	dec b
	jr nz, .tile_loop

	pop hl
	add hl, de
	dec c
	jr nz, .row_loop
	ret

HandleHighscoreEnterName::
	ld a, [hHighscorePosition]
	ld hl, vBGMapA + 15 * BG_MAP_WIDTH + 4
	ld de, -BG_MAP_WIDTH

.tilemap_add_loop:
	dec a
	jr z, .got_tilemap_pointer

	add hl, de
	jr .tilemap_add_loop

.got_tilemap_pointer:
	ld a, [hHighscoreLettersEntered]
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hHighscoreNamePointerHi]
	ld d, a
	ld a, [hHighscoreNamePointerLo]
	ld e, a
	ld a, [hDelayCounter]
	and a
	jr nz, .skip_blink

	ld a, 7
	ld [hDelayCounter], a
	ld a, [hHighscoreBlink]
	xor 1
	ld [hHighscoreBlink], a
	ld a, [de]
	jr z, .blink

	ld a, " "

.blink:
	call WriteAInHBlank

.skip_blink:
	ld a, [hKeysPressed]
	ld b, a
	ld a, [hKeysHeld]
	ld c, a
	ld a, $17
	bit 6, b
	jr nz, jr_000_19eb

	bit 6, c
	jr nz, jr_000_19e3

	bit 7, b
	jr nz, jr_000_1a14

	bit 7, c
	jr nz, jr_000_1a0c

	bit 0, b
	jr nz, jr_000_1a30

	bit 1, b
	jp nz, Jump_000_1a52

	bit 3, b
	ret z

jr_000_19cc:
	ld a, [de]
	call WriteAInHBlank
	call PlaySelectedMusic

	xor a
	ld [hHighscoreEnterName], a

	ld a, [hGameType]
	cp GAME_TYPE_A
	ld a, STATE_TYPE_A_MENU
	jr z, .set_game_state
	ld a, STATE_TYPE_B_MENU
.set_game_state:
	ld [hGameState], a
	ret
jr_000_19e3:
	ld a, [$ff00+$aa]
	dec a
	ld [$ff00+$aa], a
	ret nz

	ld a, $09

jr_000_19eb:
	ld [$ff00+$aa], a
	ld b, $26
	ld a, [hStartAtLevel10]
	and a
	jr z, jr_000_19f6

	ld b, $27

jr_000_19f6:
	ld a, [de]
	cp b
	jr nz, jr_000_1a04

	ld a, $2e

jr_000_19fc:
	inc a

jr_000_19fd:
	ld [de], a
	ld a, $01
	ld [wPlaySFX], a
	ret


jr_000_1a04:
	cp $2f
	jr nz, jr_000_19fc

	ld a, $0a
	jr jr_000_19fd

jr_000_1a0c:
	ld a, [$ff00+$aa]
	dec a
	ld [$ff00+$aa], a
	ret nz

	ld a, $09

jr_000_1a14:
	ld [$ff00+$aa], a
	ld b, $26
	ld a, [hStartAtLevel10]
	and a
	jr z, jr_000_1a1f

	ld b, $27

jr_000_1a1f:
	ld a, [de]
	cp $0a
	jr nz, jr_000_1a29

	ld a, $30

jr_000_1a26:
	dec a
	jr jr_000_19fd

jr_000_1a29:
	cp $2f
	jr nz, jr_000_1a26

	ld a, b
	jr jr_000_19fd

jr_000_1a30:
	ld a, [de]
	call WriteAInHBlank
	ld a, $02
	ld [wPlaySFX], a
	ld a, [hHighscoreLettersEntered]
	inc a
	cp $06
	jr z, jr_000_19cc

	ld [hHighscoreLettersEntered], a
	inc de
	ld a, [de]
	cp $60
	jr nz, jr_000_1a4b

	ld a, $0a
	ld [de], a

jr_000_1a4b:
	ld a, d
	ld [hHighscoreNamePointerHi], a
	ld a, e
	ld [hHighscoreNamePointerLo], a
	ret

Jump_000_1a52:
	ld a, [hHighscoreLettersEntered]
	and a
	ret z

	ld a, [de]
	call WriteAInHBlank
	ld a, [hHighscoreLettersEntered]
	dec a
	ld [hHighscoreLettersEntered], a
	dec de
	jr jr_000_1a4b
