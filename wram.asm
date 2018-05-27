SECTION "OAM Buffer", WRAM0[$c000]
wOAMBuffer:: ds 160
wOAMBuffer_End::

	ds $760

wTileMap:: ds BG_MAP_WIDTH * BG_MAP_HEIGHT
wTileMap_End:

SECTION "Stack", WRAM0[$cf00]
wStack::
	ds $100
wStackEnd::

SECTION "Audio RAM", WRAM0[$df00]
wAudio::
	ds $100
wAudioEnd::
