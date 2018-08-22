; If a demo is currently playing, and there are no more inputs, or the player pressed start, stop the demo
; Input: none
; Output: none
; Clobbers A, B, HL
CheckDemoEnd::
	ld a, [hDemoNumber]
	and a
	ret z

	call DelayLoop
	xor a
	ld [rSB], a
	ld a, SCF_RQ | SCF_SLAVE
	ld [rSC], a
	ld a, [hKeysPressed]
	bit START_BIT, a
	jr z, .continue_demo

	ld a, $33 ; TODO: why is this sent? Does the game react to receiving this byte differently?
	ld [rSB], a
	ld a, SCF_RQ | SCF_MASTER
	ld [rSC], a
	ld a, STATE_LOAD_TITLESCREEN
	ld [hGameState], a
	ret

.continue_demo:
	ld hl, hRandomnessPtrLo ; Could use the [$ff00+c] addressing mode to save a byte
	ld a, [hDemoNumber]
	cp DEMO_TYPE_A
	ld b, DemoRandomnessTypeAEnd - DemoRandomness
	jr z, .got_demo_length
	ld b, DemoRandomnessTypeBEnd - DemoRandomness
.got_demo_length:
	ld a, [hl]
	cp b
	ret nz

	ld a, STATE_LOAD_TITLESCREEN
	ld [hGameState], a
	ret

; If a demo is currently playing, read the next input and put it in the joypad variables
; Input: none
; Output: none
; Clobbers A, B, HL
HandleDemoPlayback::
	ld a, [hDemoNumber]
	and a
	ret z

	ld a, [hRecordDemo]
	cp $ff
	ret z

	ld a, [hCountdownTillNextDemoInput]
	and a
	jr z, .do_input
	dec a
	ld [hCountdownTillNextDemoInput], a
	jr .no_input
.do_input:
	ld a, [hDemoPtrHi]
	ld h, a
	ld a, [hDemoPtrLo]
	ld l, a
	ld a, [hl+]
	ld b, a
	ld a, [hLastDemoInput]
	xor b
	and b
	ld [hKeysPressed], a
	ld a, b
	ld [hLastDemoInput], a
	ld a, [hl+]
	ld [hCountdownTillNextDemoInput], a
	ld a, h
	ld [hDemoPtrHi], a
	ld a, l
	ld [hDemoPtrLo], a
	jr .end
.no_input:
	xor a
	ld [hKeysPressed], a
.end:
	ld a, [hKeysHeld]
	ld [hTrueInputDuringDemo], a
	ld a, [hLastDemoInput]
	ld [hKeysHeld], a
	ret

	xor a
	ld [hLastDemoInput], a
	jr .no_input

	ret

; If we're currently recording a demo (inaccessible without cheating devices or something),
; write the current input to the buffer pointed to by hDemoPtr.
; Input: none
; Output: none
; Clobbers A, B, HL
HandleDemoRecording::
	ld a, [hDemoNumber]
	and a
	ret z

	ld a, [hRecordDemo]
	cp DEMO_RECORD
	ret nz

	ld a, [hKeysHeld]
	ld b, a
	ld a, [hLastDemoInput]
	cp b
	jr z, .input_didnt_change

	ld a, [hDemoPtrHi]
	ld h, a
	ld a, [hDemoPtrLo]
	ld l, a

	ld a, [hLastDemoInput]
	ld [hl+], a
	ld a, [hCountdownTillNextDemoInput]
	ld [hl+], a

	ld a, h
	ld [hDemoPtrHi], a
	ld a, l
	ld [hDemoPtrLo], a

	ld a, b
	ld [hLastDemoInput], a
	xor a
	ld [hCountdownTillNextDemoInput], a
	ret

.input_didnt_change:
	ld a, [hCountdownTillNextDemoInput]
	inc a
	ld [hCountdownTillNextDemoInput], a
	ret

; If a demo is playing, restore hKeysHeld, presumably to make hKeysPressed work properly.
; Input: none
; Output: none
; Clobbers A
RestoreInputsAfterDemoFrame:
	ld a, [hDemoNumber]
	and a
	ret z

	ld a, [hRecordDemo]
	and a
	ret nz

	ld a, [hTrueInputDuringDemo]
	ld [hKeysHeld], a
	ret
