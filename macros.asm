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

coord: MACRO
	ld \1, (\2) + (\4) * BG_MAP_WIDTH + (\3)
ENDM

coordh: MACRO
	ld \1, HIGH((\2) + (\4) * BG_MAP_WIDTH + (\3))
ENDM

tile EQUS "+ 16 *"
sprite EQUS "+ SPRITE_SIZE *"
tiles EQUS "* 16"
