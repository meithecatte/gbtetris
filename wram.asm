SECTION "OAM Buffer", WRAM0[$c000]
wOAMBuffer:: ds 16
wOAMBuffer_CurrentPiece:: ds 16
wOAMBuffer_NextPiece:: ds 16
	ds 112
wOAMBuffer_End::

wScore:: ds 3
wClearedLinesList:: ds 8

	db

wTypeBScoring::
wTypeBScoring_SingleCount:: db

	ds 4

wTypeBScoring_DoubleCount:: db

	ds 4

wTypeBScoring_TripleCount:: db

	ds 4

wTypeBScoring_TetrisCount:: db

	ds 4

wTypeBScoring_Drop:: dw

	ds 3

wTypeBScoring_DisplayStage:: db
wTypeBScoring_DoTick:: db

wTypeBScoring_End::
wDidntUseFastDropOnThisPiece:: db

	ds 6

wScoreDirty:: db

SECTION "Sprites", WRAM0[$c200]
; offset 0: SPRITE_HIDDEN/SPRITE_VISIBLE
; offset 1: Y
; offset 2: X
; offset 3: sprite ID
; offset 4: below BG
; offset 5: flip
; offset 6: flags
wSpriteList::
	ds SPRITE_SIZE * 2 ; haven't seen more than 2 sprites yet

SECTION "Randomness", WRAM0[$c300]
wRandomness::
	ds 256

SECTION "Tile Map Buffer", WRAM0[$c800]
; not used all the time
wTileMap::
	ds BG_MAP_WIDTH * BG_MAP_HEIGHT
SECTION "Stack", WRAM0[$cf00]
wStack::
	ds $100
wStackEnd::

SECTION "Highscores", WRAM0[$d000]
wTypeBHighscores::
	ds HIGHSCORE_ENTRY_SIZE * HIGHSCORE_ENTRY_COUNT * TYPE_B_HIGH_COUNT * TYPE_B_LEVEL_COUNT
wTypeAHighscores::
	ds HIGHSCORE_ENTRY_SIZE * HIGHSCORE_ENTRY_COUNT * TYPE_A_LEVEL_COUNT
SECTION "Audio RAM", WRAM0[$df00]
wAudio::
	ds $e0

wPlayPulseSFX:: db
wCurPulseSFX:: db

	ds 6

wPlaySong:: db
wCurSong:: db

	ds 6

wPlayWaveSFX:: db
wCurWaveSFX:: db

	ds 6

wPlayNoiseSFX:: db
wCurNoiseSFX:: db

	ds 6

wAudioEnd::
