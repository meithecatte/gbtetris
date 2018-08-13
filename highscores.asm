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
	jr z, .end

	dec a
	add hl, de
	jr .high_loop

.end:
	inc hl
	inc hl
	push hl
	pop de
	call RenderHighscores ; why no TCO?
	ret


HighscoreUnk1:
	ld b, $03

.loop1:
	ld a, [hl]
	and $f0
	jr nz, .loop2

	inc e
	ld a, [hl-]
	and $0f
	jr nz, .unk

	inc e
	dec b
	jr nz, .loop1

	ret


.loop2:
	ld a, [hl]
	and $f0
	swap a
	ld [de], a
	inc e
	ld a, [hl-]
	and $0f

.unk:
	ld [de], a
	inc e
	dec b
	jr nz, .loop2

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
	push de
	push bc
	ld hl, $0006
	add hl, de
	push hl
	pop de
	dec hl
	dec hl
	dec hl

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
	ld a, c
	ld [$ff00+$c8], a
	ld hl, $0012
	add hl, de
	push hl
	ld de, $0006
	add hl, de
	push hl
	pop de
	pop hl

.unk18bc:
	dec c
	jr z, .unk18c6

	ld b, $06
	call Highscore_CopyBackwards.loop
	jr .unk18bc

.unk18c6:
	ld a, $60
	ld b, $05

.unk18ca:
	ld [de], a
	dec de
	dec b
	jr nz, .unk18ca

	ld a, $0a
	ld [de], a
	ld a, d
	ld [$ff00+$c9], a
	ld a, e
	ld [$ff00+$ca], a
	xor a
	ld [$ff00+$9c], a
	ld [hDemoCountdown], a
	ld a, SONG_HIGHSCORE
	ld [wPlaySong], a
	ld [$ff00+$c7], a

.no_place_for_new_score:
	ld de, $c9ac
	ld a, [hHighscorePtrHi]
	ld h, a
	ld a, [hHighscorePtrLo]
	ld l, a
	ld b, $03

.unk18ef:
	push hl
	push de
	push bc
	call HighscoreUnk1
	pop bc
	pop de
	ld hl, $0020
	add hl, de
	push hl
	pop de
	pop hl
	push de
	ld de, $0003
	add hl, de
	pop de
	dec b
	jr nz, .unk18ef

	dec hl
	dec hl
	ld b, $03
	ld de, $c9a4

.unk190e:
	push de
	ld c, $06

.unk1911:
	ld a, [hl+]
	and a
	jr z, .unk191a

	ld [de], a
	inc de
	dec c
	jr nz, .unk1911

.unk191a:
	pop de
	push hl
	ld hl, $0020
	add hl, de
	push hl
	pop de
	pop hl
	dec b
	jr nz, .unk190e

	call Call_000_26a5
	ld a, $01
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
	ld b, 6

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
	ld a, $60
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

