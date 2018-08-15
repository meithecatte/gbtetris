SECTION "OAM Buffer", WRAM0[$c000]
wOAMBuffer:: ds 16
wOAMBuffer_CurrentPiece:: ds 16
wOAMBuffer_NextPiece:: ds 16
	ds 112
wOAMBuffer_End::

wScore:: ds 3
wUnk1:: ds 9
wUnk2:: ds 27
wUnk3::

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

wPlaySFX:: db
wCurSFX:: db

	ds 6

wPlaySong:: db
wCurSong:: db

	ds $16
wAudioEnd::
