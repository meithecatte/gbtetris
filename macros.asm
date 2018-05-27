jumptable: MACRO
	rst $28
ENDM

assert: MACRO
	if !(\1)
		if _NARG > 1
			fail \2
		else
			fail "Assertion failed: \1"
		endc
	endc
ENDM

length: MACRO
	ld \1, \2_End - \2
ENDM

tile EQUS "+ 16 *"

coord: MACRO
	ld \1, wTileMap + \3 * BG_MAP_WIDTH + \2
ENDM
