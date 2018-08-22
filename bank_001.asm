GenericEmptyRoutine3::
	ret

UpdateAudio::
	push af
	push bc
	push de
	push hl
	ld a, [$df7f]
	cp $01
	jr z, jr_001_65a4

	cp $02
	jr z, jr_001_65dd

	ld a, [$df7e]
	and a
	jr nz, jr_001_65e3

jr_001_6568:
	ld a, [hDemoNumber]
	and a
	jr z, jr_001_657a

	xor a
	ld [wPlayPulseSFX], a
	ld [wPlaySong], a
	ld [$dff0], a
	ld [$dff8], a

jr_001_657a:
	call GenericEmptyRoutine3
	call Call_001_6a0e
	call Call_001_6a2e
	call Call_001_6879
	call Call_001_6a52
	call Call_001_6c75
	call Call_001_6a96

jr_001_658f:
	xor a
	ld [wPlayPulseSFX], a
	ld [wPlaySong], a
	ld [$dff0], a
	ld [$dff8], a
	ld [$df7f], a
	pop hl
	pop de
	pop bc
	pop af
	ret

jr_001_65a4:
	call MuteSound
	xor a
	ld [wCurPulseSFX], a
	ld [$dff1], a
	ld [$dff9], a
	ld hl, $dfbf
	res 7, [hl]
	ld hl, $df9f
	res 7, [hl]
	ld hl, $dfaf
	res 7, [hl]
	ld hl, $dfcf
	res 7, [hl]
	ld hl, $6f1a
	call Call_001_69c9
	ld a, $30
	ld [$df7e], a

jr_001_65d0:
	ld hl, $65fb

jr_001_65d3:
	call Call_001_698e
	jr jr_001_658f

jr_001_65d8:
	ld hl, $65ff
	jr jr_001_65d3

jr_001_65dd:
	xor a
	ld [$df7e], a
	jr jr_001_6568

jr_001_65e3:
	ld hl, $df7e
	dec [hl]
	ld a, [hl]
	cp $28
	jr z, jr_001_65d8

	cp $20
	jr z, jr_001_65d0

	cp $18
	jr z, jr_001_65d8

	cp $10
	jr nz, jr_001_658f

	inc [hl]
	jr jr_001_658f

	or d
	DB $e3
	add e
	rst $00
	or d
	DB $e3
	pop bc
	rst $00

Call_001_6603:
	ld a, [$dff1]
	cp $01
	ret


Call_001_6609:
	ld a, [wCurPulseSFX]
	cp $05
	ret


Call_001_660f:
	ld a, [wCurPulseSFX]
	cp $07
	ret


	nop
	or l
	ret nc

	ld b, b
	rst $00
	nop
	or l
	jr nz, @+$42

	rst $00
	nop
	or [hl]
	and c
	add b
	rst $00
	ld a, $05
	ld hl, $6615
	jp Jump_001_6967


	call Call_001_69bc
	and a
	ret nz

	ld hl, $dfe4
	inc [hl]
	ld a, [hl]
	cp $02
	jp z, Jump_001_664e

	ld hl, $661a
	jp Jump_001_6987


	ld a, $03
	ld hl, $661f
	jp Jump_001_6967


	call Call_001_69bc
	and a
	ret nz

Jump_001_664e:
	xor a
	ld [wCurPulseSFX], a
	ld [rNR10], a
	ld a, $08
	ld [rNR12], a
	ld a, $80
	ld [rNR14], a
	ld hl, $df9f
	res 7, [hl]
	ret


	nop
	add b
	pop hl
	pop bc
	add a
	nop
	add b
	pop hl
	xor h
	add a
	ld hl, $6662
	jp Jump_001_6967


	ld hl, $dfe4
	inc [hl]
	ld a, [hl]
	cp $04
	jr z, jr_001_6692

	cp $0b
	jr z, jr_001_6698

	cp $0f
	jr z, jr_001_6692

	cp $18
	jp z, Jump_001_6689

	ret


Jump_001_6689:
	ld a, $01
	ld hl, $dff0
	ld [hl], a
	jp Jump_001_664e


jr_001_6692:
	ld hl, $6667
	jp Jump_001_6987


jr_001_6698:
	ld hl, $6662
	jp Jump_001_6987


	ld c, b
	cp h
	ld b, d
	ld h, [hl]
	add a
	call Call_001_6603
	ret z

	call Call_001_660f
	ret z

	call Call_001_6609
	ret z

	ld a, $02
	ld hl, $669e
	jp Jump_001_6967


	nop
	or b
	pop hl
	or b
	rst $00
	ld a, $07
	ld hl, $66b7
	jp Jump_001_6967


	call Call_001_69bc
	and a
	ret nz

	ld hl, $66b7
	call Call_001_6987
	ld hl, $dfe4
	inc [hl]
	ld a, [hl]
	cp $03
	jp z, Jump_001_664e

	ret


	ld a, $80
	DB $e3
	nop
	call nz, $8393
	add e
	ld [hl], e
	ld h, e
	ld d, e
	ld b, e
	inc sp
	inc hl
	inc de
	nop
	nop
	inc hl
	ld b, e
	ld h, e
	add e
	and e
	jp $e3d3


	rst $38
	call Call_001_6603
	ret z

	call Call_001_660f
	ret z

	ld a, $06
	ld hl, $66da
	jp Jump_001_6967


	call Call_001_69bc
	and a
	ret nz

	ld hl, $dfe4
	ld c, [hl]
	inc [hl]
	ld b, $00
	ld hl, $66df
	add hl, bc
	ld a, [hl]
	and a
	jp z, Jump_001_664e

	ld e, a
	ld hl, $66ea
	add hl, bc
	ld a, [hl]
	ld d, a
	ld b, $86

jr_001_6722:
	ld c, $12
	ld a, e
	ld [$ff00+c], a
	inc c
	ld a, d
	ld [$ff00+c], a
	inc c
	ld a, b
	ld [$ff00+c], a
	ret


	dec sp
	add b
	or d
	add a
	add a
	and d
	sub e
	ld h, d
	ld b, e
	inc hl
	nop
	add b
	ld b, b
	add b
	ld b, b
	add b
	call Call_001_6603
	ret z

	call Call_001_660f
	ret z

	call Call_001_6609
	ret z

	ld a, $03
	ld hl, $672d
	jp Jump_001_6967


	call Call_001_69bc
	and a
	ret nz

	ld hl, $dfe4
	ld c, [hl]
	inc [hl]
	ld b, $00
	ld hl, $6732
	add hl, bc
	ld a, [hl]
	and a
	jp z, Jump_001_664e

	ld e, a
	ld hl, $6738
	add hl, bc
	ld a, [hl]
	ld d, a
	ld b, $87
	jr jr_001_6722

	call Call_001_660f
	ret z

	ld a, $28
	ld hl, $677d
	jp Jump_001_6967


	or a
	add b
	sub b
	rst $38
	add e
	nop
	pop de
	ld b, l
	add b
	nop
	pop af
	ld d, h
	add b
	nop
	push de
	ld h, l
	add b
	nop
	ld [hl], b
	ld h, [hl]
	add b
	ld h, l
	ld h, l
	ld h, l
	ld h, h
	ld d, a
	ld d, [hl]
	ld d, l
	ld d, h
	ld d, h
	ld d, h
	ld d, h
	ld d, h
	ld b, a
	ld b, [hl]
	ld b, [hl]
	ld b, l
	ld b, l
	ld b, l
	ld b, h
	ld b, h
	ld b, h
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ld [hl], b
	ld h, b
	ld [hl], b
	ld [hl], b
	ld [hl], b
	add b
	sub b
	and b
	ret nc

	ld a, [$ff00+$e0]
	ret nc

	ret nz

	or b
	and b
	sub b
	add b
	ld [hl], b
	ld h, b
	ld d, b
	ld b, b
	jr nc, jr_001_67fd

	jr nz, jr_001_67ef

	jr nz, @+$22

	jr nz, jr_001_67f3

	jr nz, @+$22

	jr nz, @+$22

	jr nz, @+$12

	DB $10
	ld a, $30
	ld hl, $678a
	jp Jump_001_6967


	ld a, $30
	ld hl, $678e
	jp Jump_001_6967


	call Call_001_69bc
	and a
	ret nz

jr_001_67ef:
	ld hl, $dffc
	ld a, [hl]

jr_001_67f3:
	ld c, a
	cp $24
	jp z, Jump_001_6826

	inc [hl]
	ld b, $00
	push bc

jr_001_67fd:
	ld hl, $6792
	add hl, bc
	ld a, [hl]
	ld [rNR43], a
	pop bc
	ld hl, $67b6
	add hl, bc
	ld a, [hl]
	ld [rNR42], a
	ld a, $80
	ld [rNR44], a
	ret


	ld a, $20
	ld hl, $6786
	jp Jump_001_6967


	ld a, $12
	ld hl, $6782
	jp Jump_001_6967


	call Call_001_69bc
	and a
	ret nz

Jump_001_6826:
	xor a
	ld [$dff9], a
	ld a, $08
	ld [rNR42], a
	ld a, $80
	ld [rNR44], a
	ld hl, $dfcf

jr_001_6835:
	res 7, [hl]
	ret


jr_001_6838:
	add b
	ld a, [hl-]
	jr nz, jr_001_689c

	add $21
	ld a, [bc]
	ld l, a
	call Call_001_693e
	ld a, [rDIV]
	and $1f
	ld b, a
	ld a, $d0
	add b
	ld [$dff5], a
	ld hl, $6838
	jp Jump_001_6995


Jump_001_6854:
	ld a, [rDIV]
	and $0f
	ld b, a
	ld hl, $dff4
	inc [hl]
	ld a, [hl]
	ld hl, $dff5
	cp $0e
	jr nc, jr_001_686f

	inc [hl]
	inc [hl]

jr_001_6867:
	ld a, [hl]
	and $f0
	or b
	ld c, $1d
	ld [$ff00+c], a
	ret


jr_001_686f:
	cp $1e
	jp z, Jump_001_691f

	dec [hl]
	dec [hl]
	dec [hl]
	jr jr_001_6867

Call_001_6879:
	ld a, [$dff0]
	cp $01
	jp z, Jump_001_68a8

	cp $02
	jp z, $683d

	ld a, [$dff1]
	cp $01
	jp z, Jump_001_68f3

	cp $02
	jp z, Jump_001_6854

	ret


	add b
	add b
	jr nz, jr_001_6835

	add a
	add b
	ld hl, sp+$20

jr_001_689c:
	sbc b
	add a
	add b
	ei
	jr nz, jr_001_6838

	add a
	add b
	or $20
	sub l
	add a

Jump_001_68a8:
	ld hl, $6eda
	call Call_001_693e
	ld hl, $6897
	ld a, [hl]
	ld [$dff6], a
	ld a, $01
	ld [$dff5], a
	ld hl, $6894

jr_001_68bd:
	jp Jump_001_6995


jr_001_68c0:
	ld a, $00
	ld [$dff5], a
	ld hl, $689c
	ld a, [hl]
	ld [$dff6], a
	ld hl, $6899
	jr jr_001_68bd

jr_001_68d1:
	ld a, $01
	ld [$dff5], a
	ld hl, $68a1
	ld a, [hl]
	ld [$dff6], a
	ld hl, $689e
	jr jr_001_68bd

jr_001_68e2:
	ld a, $02
	ld [$dff5], a
	ld hl, $68a6
	ld a, [hl]
	ld [$dff6], a
	ld hl, $68a3
	jr jr_001_68bd

Jump_001_68f3:
	ld hl, $dff4
	inc [hl]
	ld a, [hl+]
	cp $09
	jr z, jr_001_68c0

	cp $13
	jr z, jr_001_68d1

	cp $17
	jr z, jr_001_68e2

	cp $20
	jr z, jr_001_691f

	ld a, [hl+]
	cp $00
	ret z

	cp $01
	jr z, jr_001_6915

	cp $02
	jr z, jr_001_6919

	ret


jr_001_6915:
	inc [hl]
	inc [hl]
	jr jr_001_691b

jr_001_6919:
	dec [hl]
	dec [hl]

jr_001_691b:
	ld a, [hl]
	ld [rNR33], a
	ret


Jump_001_691f:
jr_001_691f:
	xor a
	ld [$dff1], a
	ld [rNR30], a
	ld hl, $dfbf
	res 7, [hl]
	ld hl, $df9f
	res 7, [hl]
	ld hl, $dfaf
	res 7, [hl]
	ld hl, $dfcf
	res 7, [hl]
	ld hl, $6f1a
	jr jr_001_6963

Call_001_693e:
	push hl
	ld [$dff1], a
	ld hl, $dfbf
	set 7, [hl]
	xor a
	ld [$dff4], a
	ld [$dff5], a
	ld [$dff6], a
	ld [rNR30], a
	ld hl, $df9f
	set 7, [hl]
	ld hl, $dfaf
	set 7, [hl]
	ld hl, $dfcf
	set 7, [hl]
	pop hl

jr_001_6963:
	call Call_001_69c9
	ret


Jump_001_6967:
	push af
	dec e
	ld a, [$df71]
	ld [de], a
	inc e
	pop af
	inc e
	ld [de], a
	dec e
	xor a
	ld [de], a
	inc e
	inc e
	ld [de], a
	inc e
	ld [de], a
	ld a, e
	cp $e5
	jr z, jr_001_6987

	cp $f5
	jr z, jr_001_6995

	cp $fd
	jr z, jr_001_699c

	ret


Call_001_6987:
Jump_001_6987:
jr_001_6987:
	push bc
	ld c, $10
	ld b, $05
	jr jr_001_69a1

Call_001_698e:
	push bc
	ld c, $16
	ld b, $04
	jr jr_001_69a1

Jump_001_6995:
jr_001_6995:
	push bc
	ld c, $1a
	ld b, $05
	jr jr_001_69a1

jr_001_699c:
	push bc
	ld c, $20
	ld b, $04

jr_001_69a1:
	ld a, [hl+]
	ld [$ff00+c], a
	inc c
	dec b
	jr nz, jr_001_69a1

	pop bc
	ret


Call_001_69a9:
	inc e
	ld [$df71], a

Call_001_69ad:
	inc e
	dec a
	sla a
	ld c, a
	ld b, $00
	add hl, bc
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld l, c
	ld h, b
	ld a, h
	ret


Call_001_69bc:
	push de
	ld l, e
	ld h, d
	inc [hl]
	ld a, [hl+]
	cp [hl]
	jr nz, jr_001_69c7

	dec l
	xor a
	ld [hl], a

jr_001_69c7:
	pop de
	ret


Call_001_69c9:
	push bc
	ld c, $30

jr_001_69cc:
	ld a, [hl+]
	ld [$ff00+c], a
	inc c
	ld a, c
	cp $40
	jr nz, jr_001_69cc

	pop bc
	ret

ResetAudio::
	xor a
	ld [wCurPulseSFX], a
	ld [wCurSong], a
	ld [$dff1], a
	ld [$dff9], a
	ld [$df9f], a
	ld [$dfaf], a
	ld [$dfbf], a
	ld [$dfcf], a
	ld a, AUDTERM_ALL
	ld [rAUDTERM], a
	ld a, $03
	ld [$df78], a
	; fallthrough
MuteSound::
	ld a, ENV_UP + 0 << ENV_VOLUME_SHIFT + 0 << ENV_SWEEP_SHIFT
	ld [rAUD1ENV], a
	ld [rAUD2ENV], a
	ld [rAUD4ENV], a
	ld a, GO_START
	ld [rAUD1HIGH], a
	ld [rAUD2HIGH], a
	ld [rAUD4GO], a
	xor a
	ld [rAUD1SWEEP], a
	ld [rAUD3ENA], a
	ret

Call_001_6a0e:
	ld de, wPlayPulseSFX
	ld a, [de]
	and a
	jr z, jr_001_6a21

	ld hl, $df9f
	set 7, [hl]
	ld hl, $6500
	call Call_001_69a9
	jp hl


jr_001_6a21:
	inc e
	ld a, [de]
	and a
	jr z, jr_001_6a2d

	ld hl, $6510
	call Call_001_69ad
	jp hl


jr_001_6a2d:
	ret


Call_001_6a2e:
	ld de, $dff8
	ld a, [de]
	and a
	jr z, jr_001_6a41

	ld hl, $dfcf
	set 7, [hl]
	ld hl, $6520
	call Call_001_69a9
	jp hl


jr_001_6a41:
	inc e
	ld a, [de]
	and a
	jr z, jr_001_6a4d

	ld hl, $6528
	call Call_001_69ad
	jp hl


jr_001_6a4d:
	ret


jr_001_6a4e:
	call ResetAudio
	ret


Call_001_6a52:
	ld hl, wPlaySong
	ld a, [hl+]
	and a
	ret z

	cp $ff
	jr z, jr_001_6a4e

	ld [hl], a
	ld b, a
	ld hl, $6530
	and $1f
	call Call_001_69ad
	call Call_001_6b44
	call Call_001_6a6d
	ret


Call_001_6a6d:
	ld a, [wCurSong]
	and a
	ret z

	ld hl, $6aef

jr_001_6a75:
	dec a
	jr z, jr_001_6a7e

	inc hl
	inc hl
	inc hl
	inc hl
	jr jr_001_6a75

jr_001_6a7e:
	ld a, [hl+]
	ld [$df78], a
	ld a, [hl+]
	ld [$df76], a
	ld a, [hl+]
	ld [$df79], a
	ld a, [hl+]
	ld [$df7a], a
	xor a
	ld [$df75], a
	ld [$df77], a
	ret


Call_001_6a96:
	ld a, [wCurSong]
	and a
	jr z, jr_001_6ad9

	ld hl, $df75
	ld a, [$df78]
	cp $01
	jr z, jr_001_6add

	cp $03
	jr z, jr_001_6ad9

	inc [hl]
	ld a, [hl+]
	cp [hl]
	jr nz, jr_001_6ae2

	dec l
	ld [hl], $00
	inc l
	inc l
	inc [hl]
	ld a, [$df79]
	bit 0, [hl]
	jp z, Jump_001_6ac0

	ld a, [$df7a]

Jump_001_6ac0:
jr_001_6ac0:
	ld b, a
	ld a, [$dff1]
	and a
	jr z, jr_001_6acb

	set 2, b
	set 6, b

jr_001_6acb:
	ld a, [$dff9]
	and a
	jr z, jr_001_6ad5

	set 3, b
	set 7, b

jr_001_6ad5:
	ld a, b

jr_001_6ad6:
	ld [rNR51], a
	ret


jr_001_6ad9:
	ld a, $ff
	jr jr_001_6ad6

jr_001_6add:
	ld a, [$df79]
	jr jr_001_6ac0

jr_001_6ae2:
	ld a, [$dff9]
	and a
	jr nz, jr_001_6ad9

	ld a, [$dff1]
	and a
	jr nz, jr_001_6ad9

	ret


	ld bc, $ef24
	ld d, [hl]
	ld bc, $e500
	nop
	ld bc, $fd20
	nop
	ld bc, $de20
	rst $30
	ld [bc], a
	jr @+$81

	rst $30
	inc bc
	jr @-$07

	ld a, a
	inc bc
	ld c, b
	rst $18
	ld e, e
	ld bc, $db18
	rst $20
	ld bc, $fd00
	rst $30
	inc bc
	jr nz, jr_001_6b95

	rst $30
	ld bc, $ed20
	rst $30
	ld bc, $ed20
	rst $30
	ld bc, $ed20
	rst $30
	ld bc, $ed20
	rst $30
	ld bc, $ed20
	rst $30
	ld bc, $ef20
	rst $30
	ld bc, $ef20
	rst $30

Call_001_6b33:
	ld a, [hl+]
	ld c, a
	ld a, [hl]
	ld b, a
	ld a, [bc]
	ld [de], a
	inc e
	inc bc
	ld a, [bc]
	ld [de], a
	ret


Call_001_6b3e:
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	ret


Call_001_6b44:
	call MuteSound
	xor a
	ld [$df75], a
	ld [$df77], a
	ld de, $df80
	ld b, $00
	ld a, [hl+]
	ld [de], a
	inc e
	call Call_001_6b3e
	ld de, $df90
	call Call_001_6b3e
	ld de, $dfa0
	call Call_001_6b3e
	ld de, $dfb0
	call Call_001_6b3e
	ld de, $dfc0
	call Call_001_6b3e
	ld hl, $df90
	ld de, $df94
	call Call_001_6b33
	ld hl, $dfa0
	ld de, $dfa4
	call Call_001_6b33
	ld hl, $dfb0
	ld de, $dfb4
	call Call_001_6b33
	ld hl, $dfc0
	ld de, $dfc4
	call Call_001_6b33

jr_001_6b95:
	ld bc, $0410
	ld hl, $df92

jr_001_6b9b:
	ld [hl], $01
	ld a, c
	add l
	ld l, a
	dec b
	jr nz, jr_001_6b9b

	xor a
	ld [$df9e], a
	ld [$dfae], a
	ld [$dfbe], a
	ret


jr_001_6bae:
	push hl
	xor a
	ld [rNR30], a
	ld l, e
	ld h, d
	call Call_001_69c9
	pop hl
	jr jr_001_6be4

Jump_001_6bba:
	call Call_001_6bea
	call Call_001_6bff
	ld e, a
	call Call_001_6bea
	call Call_001_6bff
	ld d, a
	call Call_001_6bea
	call Call_001_6bff
	ld c, a
	inc l
	inc l
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], c
	dec l
	dec l
	dec l
	dec l
	push hl
	ld hl, $df70
	ld a, [hl]
	pop hl
	cp $03
	jr z, jr_001_6bae

jr_001_6be4:
	call Call_001_6bea
	jp Jump_001_6c8f


Call_001_6bea:
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl-]
	ld d, a
	inc de

jr_001_6bf0:
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl-], a
	pop de
	ret


Call_001_6bf6:
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl-]
	ld d, a
	inc de
	inc de
	jr jr_001_6bf0

Call_001_6bff:
	ld a, [hl+]
	ld c, a
	ld a, [hl-]
	ld b, a
	ld a, [bc]
	ld b, a
	ret


jr_001_6c06:
	pop hl
	jr jr_001_6c35

Jump_001_6c09:
	ld a, [$df70]
	cp $03
	jr nz, jr_001_6c20

	ld a, [$dfb8]
	bit 7, a
	jr z, jr_001_6c20

	ld a, [hl]
	cp $06
	jr nz, jr_001_6c20

	ld a, $40
	ld [rNR32], a

jr_001_6c20:
	push hl
	ld a, l
	add $09
	ld l, a
	ld a, [hl]
	and a
	jr nz, jr_001_6c06

	ld a, l
	add $04
	ld l, a
	bit 7, [hl]
	jr nz, jr_001_6c06

	pop hl
	call Call_001_6d98

Jump_001_6c35:
jr_001_6c35:
	dec l
	dec l
	jp Jump_001_6d6a


Jump_001_6c3a:
	dec l
	dec l
	dec l
	dec l
	call Call_001_6bf6

jr_001_6c41:
	ld a, l
	add $04
	ld e, a
	ld d, h
	call Call_001_6b33
	cp $00
	jr z, jr_001_6c6c

	cp $ff
	jr z, jr_001_6c55

	inc l
	jp Jump_001_6c8d


jr_001_6c55:
	dec l
	push hl
	call Call_001_6bf6
	call Call_001_6bff
	ld e, a
	call Call_001_6bea
	call Call_001_6bff
	ld d, a
	pop hl
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl-], a
	jr jr_001_6c41

jr_001_6c6c:
	ld hl, wCurSong
	ld [hl], $00
	call ResetAudio ; why no TCO?
	ret


Call_001_6c75:
	ld hl, wCurSong
	ld a, [hl]
	and a
	ret z

	ld a, $01
	ld [$df70], a
	ld hl, $df90

Jump_001_6c83:
	inc l
	ld a, [hl+]
	and a
	jp z, Jump_001_6c35

	dec [hl]
	jp nz, Jump_001_6c09

Jump_001_6c8d:
	inc l
	inc l

Jump_001_6c8f:
	call Call_001_6bff
	cp $00
	jp z, Jump_001_6c3a

	cp $9d
	jp z, Jump_001_6bba

	and $f0
	cp $a0
	jr nz, jr_001_6cbc

	ld a, b
	and $0f
	ld c, a
	ld b, $00
	push hl
	ld de, $df81
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	add hl, bc
	ld a, [hl]
	pop hl
	dec l
	ld [hl+], a
	call Call_001_6bea
	call Call_001_6bff

jr_001_6cbc:
	ld a, b
	ld c, a
	ld b, $00
	call Call_001_6bea
	ld a, [$df70]
	cp $04
	jp z, Jump_001_6ced

	push hl
	ld a, l
	add $05
	ld l, a
	ld e, l
	ld d, h
	inc l
	inc l
	ld a, c
	cp $01
	jr z, jr_001_6ce8

	ld [hl], $00
	ld hl, $6e33
	add hl, bc
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl]
	ld [de], a
	pop hl
	jp Jump_001_6d04


jr_001_6ce8:
	ld [hl], $01
	pop hl
	jr jr_001_6d04

Jump_001_6ced:
	push hl
	ld de, $dfc6
	ld hl, $6ec5
	add hl, bc

jr_001_6cf5:
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, e
	cp $cb
	jr nz, jr_001_6cf5

	ld c, $20
	ld hl, $dfc4
	jr jr_001_6d32

Jump_001_6d04:
jr_001_6d04:
	push hl
	ld a, [$df70]
	cp $01
	jr z, jr_001_6d2d

	cp $02
	jr z, jr_001_6d29

	ld c, $1a
	ld a, [$dfbf]
	bit 7, a
	jr nz, jr_001_6d1e

	xor a
	ld [$ff00+c], a
	ld a, $80
	ld [$ff00+c], a

jr_001_6d1e:
	inc c
	inc l
	inc l
	inc l
	inc l
	ld a, [hl+]
	ld e, a
	ld d, $00
	jr jr_001_6d3e

jr_001_6d29:
	ld c, $16
	jr jr_001_6d32

jr_001_6d2d:
	ld c, $10
	ld a, $00
	inc c

jr_001_6d32:
	inc l
	inc l
	inc l
	ld a, [hl-]
	and a
	jr nz, jr_001_6d88

	ld a, [hl+]
	ld e, a

jr_001_6d3b:
	inc l
	ld a, [hl+]
	ld d, a

jr_001_6d3e:
	push hl
	inc l
	inc l
	ld a, [hl+]
	and a
	jr z, jr_001_6d47

	ld e, $01

jr_001_6d47:
	inc l
	inc l
	ld [hl], $00
	inc l
	ld a, [hl]
	pop hl
	bit 7, a
	jr nz, jr_001_6d65

	ld a, d
	ld [$ff00+c], a
	inc c
	ld a, e
	ld [$ff00+c], a
	inc c
	ld a, [hl+]
	ld [$ff00+c], a
	inc c
	ld a, [hl]
	or $80
	ld [$ff00+c], a
	ld a, l
	or $05
	ld l, a
	res 0, [hl]

jr_001_6d65:
	pop hl
	dec l
	ld a, [hl-]
	ld [hl-], a
	dec l

Jump_001_6d6a:
	ld de, $df70
	ld a, [de]
	cp $04
	jr z, jr_001_6d7b

	inc a
	ld [de], a
	ld de, $0010
	add hl, de
	jp Jump_001_6c83


jr_001_6d7b:
	ld hl, $df9e
	inc [hl]
	ld hl, $dfae
	inc [hl]
	ld hl, $dfbe
	inc [hl]
	ret


jr_001_6d88:
	ld b, $00
	push hl
	pop hl
	inc l
	jr jr_001_6d3b

Call_001_6d8f:
	ld a, b
	srl a
	ld l, a
	ld h, $00
	add hl, de
	ld e, [hl]
	ret


Call_001_6d98:
	push hl
	ld a, l
	add $06
	ld l, a
	ld a, [hl]
	and $0f
	jr z, jr_001_6dba

	ld [$df71], a
	ld a, [$df70]
	ld c, $13
	cp $01
	jr z, jr_001_6dbc

	ld c, $18
	cp $02
	jr z, jr_001_6dbc

	ld c, $1d
	cp $03
	jr z, jr_001_6dbc

jr_001_6dba:
	pop hl
	ret


jr_001_6dbc:
	inc l
	ld a, [hl+]
	ld e, a
	ld a, [hl]
	ld d, a
	push de
	ld a, l
	add $04
	ld l, a
	ld b, [hl]
	ld a, [$df71]
	cp $01
	jr jr_001_6dd7

	cp $03
	jr jr_001_6dd2

jr_001_6dd2:
	ld hl, $ffff
	jr jr_001_6df3

jr_001_6dd7:
	ld de, $6dfc
	call Call_001_6d8f
	bit 0, b
	jr nz, jr_001_6de3

	swap e

jr_001_6de3:
	ld a, e
	and $0f
	bit 3, a
	jr z, jr_001_6df0

	ld h, $ff
	or $f0
	jr jr_001_6df2

jr_001_6df0:
	ld h, $00

jr_001_6df2:
	ld l, a

jr_001_6df3:
	pop de
	add hl, de
	ld a, l
	ld [$ff00+c], a
	inc c
	ld a, h
	ld [$ff00+c], a
	jr jr_001_6dba

	nop
	nop
	nop
	nop
	nop
	nop
	stop
	rrca
	nop
	nop
	ld de, $0f00
	ld a, [rSB]
	ld [de], a
	DB $10
	rst $38
	rst $28
	ld bc, $1012
	rst $38
	rst $28
	ld bc, $1012
	rst $38
	rst $28
	ld bc, $1012
	rst $38
	rst $28
	ld bc, $1012
	rst $38
	rst $28
	ld bc, $1012
	rst $38
	rst $28
	ld bc, $1012
	rst $38
	rst $28
	ld bc, $1012
	rst $38
	rst $28
	nop
	rrca
	inc l
	nop
	sbc h
	nop
	ld b, $01
	ld l, e
	ld bc, $01c9
	inc hl
	ld [bc], a
	ld [hl], a
	ld [bc], a
	add $02
	ld [de], a
	inc bc
	ld d, [hl]
	inc bc
	sbc e
	inc bc
	jp c, $1603

	inc b
	ld c, [hl]
	inc b
	add e
	inc b
	or l
	inc b
	push hl
	inc b
	ld de, $3b05
	dec b
	ld h, e
	dec b
	adc c
	dec b
	xor h
	dec b
	adc $05
	DB $ed
	dec b
	ld a, [bc]
	ld b, $27
	ld b, $42
	ld b, $5b
	ld b, $72
	ld b, $89
	ld b, $9e
	ld b, $b2
	ld b, $c4
	ld b, $d6
	ld b, $e7
	ld b, $f7
	ld b, $06
	rlca
	inc d
	rlca
	ld hl, $2d07
	rlca
	add hl, sp
	rlca
	ld b, h
	rlca
	ld c, a
	rlca
	ld e, c
	rlca
	ld h, d
	rlca
	ld l, e
	rlca
	ld [hl], e
	rlca
	ld a, e
	rlca
	add e
	rlca
	adc d
	rlca
	sub b
	rlca
	sub a
	rlca
	sbc l
	rlca
	and d
	rlca
	and a
	rlca
	xor h
	rlca
	or c
	rlca
	or [hl]
	rlca
	cp d
	rlca
	cp [hl]
	rlca
	pop bc
	rlca
	call nz, $c807
	rlca
	rlc a
	adc $07
	pop de
	rlca
	call nc, $d607
	rlca
	reti


	rlca
	DB $db
	rlca
	DB $dd
	rlca
	rst $18
	rlca
	nop
	nop
	nop
	nop
	nop
	ret nz

	and c
	nop

Call_001_6ecd:
	ld a, [hl-]
	nop
	ret nz

	or c
	nop
	add hl, hl
	ld bc, $61c0
	nop
	ld a, [hl-]
	nop
	ret nz

	ld [de], a
	inc [hl]
	ld b, l
	ld h, a
	sbc d
	cp h
	sbc $fe
	sbc b
	ld a, d
	or a
	cp [hl]
	xor b
	DB $76
	ld d, h
	ld sp, $2301
	ld b, h
	ld d, l
	ld h, a
	adc b
	sbc d
	cp e
	xor c
	adc b
	DB $76
	ld d, l
	ld b, h
	inc sp
	ld [hl+], a
	ld de, $2301
	ld b, l
	ld h, a
	adc c
	xor e
	call $feef
	call c, $98ba
	DB $76
	ld d, h
	ld [hl-], a
	DB $10
	and c
	add d
	inc hl
	inc [hl]
	ld b, l
	ld d, [hl]
	ld h, a
	ld a, b
	adc c
	sbc d
	xor e
	cp h
	call $3264
	DB $10
	ld de, $5623
	ld a, b
	sbc c
	sbc b
	DB $76
	ld h, a
	sbc d
	rst $18
	cp $c9
	add l
	ld b, d
	ld de, $0231
	inc b
	ld [$2010], sp
	ld b, b
	inc c
	jr jr_001_6f63

	dec b
	nop
	ld bc, $0503
	ld a, [bc]
	inc d
	jr z, @+$52

	rrca
	ld e, $3c
	inc bc
	ld b, $0c
	jr jr_001_6f74

	ld h, b
	ld [de], a
	inc h
	ld c, b
	ld [$0010], sp
	rlca
	ld c, $1c
	jr c, jr_001_6fc0

	dec d
	ld a, [hl+]
	ld d, h
	inc b
	ld [$2010], sp
	ld b, b
	add b
	jr jr_001_6f8b

	ld h, b
	inc b
	add hl, bc
	ld [de], a
	inc h
	ld c, b
	sub b
	dec de

jr_001_6f63:
	ld [hl], $6c
	inc c
	jr jr_001_6f6c

	ld a, [bc]
	inc d
	jr z, jr_001_6fbc

jr_001_6f6c:
	and b
	ld e, $3c
	ld a, b
	nop
	ccf
	ld l, a
	DB $f4

jr_001_6f74:
	ld a, h
	ld a, [$0c7c]
	ld a, l
	inc e
	ld a, l
	nop
	ld [hl], $6f
	ld b, e
	ld a, [hl]
	ccf
	ld a, [hl]
	ld b, l
	ld a, [hl]
	ld b, a
	ld a, [hl]
	nop
	ccf
	ld l, a
	ld [hl], $76

jr_001_6f8b:
	ld l, $76
	inc a
	DB $76
	ld e, [hl]
	halt
	ld a, [hl+]
	ld l, a
	ei
	ld [hl], l
	rst $30
	ld [hl], l
	DB $fd
	ld [hl], l
	nop
	nop
	nop
	ccf
	ld l, a
	adc l
	ld [hl], c
	ld [hl], e
	ld [hl], c
	and a
	ld [hl], c
	pop bc
	ld [hl], c
	nop
	ccf
	ld l, a
	pop bc
	ld [hl], d
	or e
	ld [hl], d
	rst $08
	ld [hl], d
	DB $fd
	ld [hl], d
	nop
	ccf
	ld l, a
	add hl, sp
	ld [hl], b
	dec hl
	ld [hl], b
	nop
	nop
	nop

jr_001_6fbc:
	nop
	nop
	ld [hl], $6f

jr_001_6fc0:
	sbc b
	ld a, [hl]
	adc h
	ld a, [hl]
	and h
	ld a, [hl]
	or b
	ld a, [hl]
	nop
	ccf
	ld l, a
	inc hl
	ld a, h
	rra
	ld a, h
	dec h
	ld a, h
	daa
	ld a, h
	nop
	ccf
	ld l, a
	nop
	nop
	ei
	ld a, c
	nop
	nop
	nop
	nop
	nop
	ccf
	ld l, a
	nop
	nop
	ld hl, $257a
	ld a, d
	nop
	nop
	nop
	ccf
	ld l, a
	ld l, [hl]
	ld a, d
	ld l, d
	ld a, d
	ld [hl], b
	ld a, d
	nop
	nop
	nop
	ccf
	ld l, a
	jp c, $de7a

	ld a, d
	ld [$ff00+$7a], a
	ld [$ff00+c], a
	ld a, d
	nop
	ccf
	ld l, a
	ld h, b
	ld a, e
	ld h, [hl]
	ld a, e
	ld l, d
	ld a, e
	ld l, [hl]
	ld a, e
	nop
	ccf
	ld l, a
	ld h, a
	ld a, b
	ld [hl], c
	ld a, b
	ld a, c
	ld a, b
	add c
	ld a, b
	nop
	ld e, h
	ld l, a
	ld a, $75
	ld b, [hl]
	ld [hl], l
	ld c, h
	ld [hl], l
	nop
	nop
	nop
	ccf
	ld l, a
	adc b
	ld [hl], l
	sub b
	ld [hl], l
	sub [hl]
	ld [hl], l
	nop
	nop
	ld b, a
	ld [hl], b
	ld h, l
	ld [hl], b
	ld b, a
	ld [hl], b
	ld a, [hl]
	ld [hl], b
	call nz, $ff70
	rst $38
	dec hl
	ld [hl], b
	sub e
	ld [hl], b
	and l
	ld [hl], b
	sub e
	ld [hl], b
	or [hl]
	ld [hl], b
	dec h
	ld [hl], c
	rst $38
	rst $38
	add hl, sp
	ld [hl], b
	sbc l
	ld [hl], h
	nop
	ld b, c
	and d
	ld b, h
	ld c, h
	ld d, [hl]
	ld c, h
	ld b, d

jr_001_7051:
	ld c, h
	ld b, h
	ld c, h
	ld a, $4c
	inc a
	ld c, h
	ld b, h
	ld c, h
	ld d, [hl]
	ld c, h
	ld b, d
	ld c, h
	ld b, h
	ld c, h
	ld a, $4c
	inc a
	ld c, h
	nop
	ld b, h
	ld c, h
	ld b, h
	ld a, $4e
	ld c, b
	ld b, d
	ld c, b
	ld b, d
	ld a, [hl-]
	ld c, h
	ld b, h
	ld a, $4c
	ld c, b
	ld b, h
	ld b, d
	ld a, $3c
	inc [hl]
	inc a
	ld b, d
	ld c, h
	ld c, b
	nop
	ld b, h
	ld c, h
	ld b, h
	ld a, $4e
	ld c, b
	ld b, d
	ld c, b
	ld b, d
	ld a, [hl-]
	ld d, d
	ld c, b
	ld c, h
	ld d, d
	ld c, h
	ld b, h
	ld a, [hl-]
	ld b, d
	xor b
	ld b, h
	nop
	sbc l
	ld h, h
	nop
	ld b, c
	and e
	ld h, $3e
	inc a
	ld h, $2c
	inc [hl]
	ld a, $36
	inc [hl]
	ld a, $2c
	inc [hl]
	nop
	ld h, $3e
	jr nc, jr_001_70cb

	ld a, [hl-]
	inc l
	ld e, $36
	jr nc, jr_001_7051

	inc [hl]
	ld [hl], $34
	jr nc, jr_001_70e0

	ld a, [hl+]
	nop
	and e
	ld h, $3e
	jr nc, jr_001_70dd

	ld a, [hl-]
	ld a, [hl+]
	inc l
	inc [hl]
	inc [hl]
	inc l
	ld [hl+], a
	inc d
	nop
	and d
	ld d, d
	ld c, [hl]
	ld c, h
	ld c, b
	ld b, h
	ld b, d

jr_001_70cb:
	ld b, h
	ld c, b
	ld c, h
	ld b, h
	ld c, b
	ld c, [hl]
	ld c, h
	ld c, [hl]
	and e
	ld d, d
	ld b, d
	and d
	ld b, h
	ld c, b
	and e
	ld c, h
	ld c, b
	ld c, h

jr_001_70dd:
	ld d, [hl]
	ld d, b
	and d

jr_001_70e0:
	ld d, [hl]
	ld e, d
	and e
	ld e, h
	ld e, d
	and d
	ld d, [hl]
	ld d, d
	ld d, b
	ld c, h
	ld d, b
	ld c, d
	xor b
	ld c, h

jr_001_70ee:
	and a
	ld d, d
	and c
	ld d, [hl]
	ld e, b
	and e
	ld d, [hl]
	and d
	ld d, d
	ld c, [hl]
	ld d, d
	ld c, h
	ld c, [hl]
	ld c, b
	and a
	ld d, [hl]
	and c
	ld e, d

jr_001_7100:
	ld e, h
	and e
	ld e, d
	and d
	ld d, [hl]
	ld d, h
	ld d, [hl]
	ld d, b
	ld d, h
	ld c, h
	ld e, d
	ld d, h
	ld c, h

jr_001_710d:
	ld d, h
	ld e, d
	ld h, b
	ld h, [hl]
	ld d, h
	ld h, h
	ld d, h
	ld h, b
	ld d, h
	and e
	ld e, h
	and d
	ld h, b
	ld e, h
	ld e, d
	ld e, h
	and c
	ld d, [hl]
	ld e, d
	and h
	ld d, [hl]
	and d
	ld bc, $a200
	inc [hl]
	ld a, [hl-]
	ld b, h
	ld a, [hl-]
	jr nc, jr_001_7166

	inc [hl]
	ld a, [hl-]
	inc l
	ld a, [hl-]
	ld a, [hl+]
	ld a, [hl-]
	inc l
	ld a, [hl-]
	ld b, h
	ld a, [hl-]
	jr nc, @+$3c

	inc [hl]
	ld a, [hl-]
	inc l
	ld a, [hl-]
	ld a, [hl+]
	ld a, [hl-]
	inc l
	inc [hl]
	inc l
	ld h, $3e
	jr c, jr_001_7177

	jr c, jr_001_7171

	jr c, jr_001_717b

	jr c, jr_001_70ee

	inc [hl]
	ld b, d
	ld a, [hl+]
	and d
	inc [hl]
	ld a, [hl-]
	ld b, d
	ld a, [hl-]
	jr nc, @+$3c

	ld l, $34
	ld h, $34
	ld l, $34
	xor b
	jr nc, jr_001_7100

	ld [hl-], a
	jr c, jr_001_718b

	jr c, jr_001_7195

	jr c, jr_001_710d

	inc [hl]

jr_001_7166:
	and e
	inc [hl]
	ld a, [hl+]
	inc h
	inc e
	jr nz, jr_001_7191

	inc l
	jr nc, jr_001_71a4

	xor b

jr_001_7171:
	ld h, $00
	rst $00
	ld [hl], c
	sub $71

jr_001_7177:
	rrca
	ld [hl], d
	sub $71

jr_001_717b:
	ld b, c
	ld [hl], d
	and h
	ld [hl], d
	sub $71
	rrca
	ld [hl], d
	rst $00
	ld [hl], c
	sub $71
	DB $76
	ld [hl], d
	rst $38
	rst $38

jr_001_718b:
	ld [hl], e
	ld [hl], c
	call z, $ee71
	ld [hl], c

jr_001_7191:
	daa
	ld [hl], d
	xor $71

jr_001_7195:
	ld d, l
	ld [hl], d
	xor c
	ld [hl], d
	xor $71
	daa
	ld [hl], d
	call z, $ee71
	ld [hl], c
	adc d
	ld [hl], d
	rst $38

jr_001_71a4:
	rst $38
	adc l
	ld [hl], c
	pop de
	ld [hl], c
	DB $fc
	ld [hl], c
	inc [hl]
	ld [hl], d
	DB $fc
	ld [hl], c
	ld h, h
	ld [hl], d
	xor [hl]
	ld [hl], d
	DB $fc
	ld [hl], c
	inc [hl]
	ld [hl], d
	pop de
	ld [hl], c
	DB $fc
	ld [hl], c
	sub a
	ld [hl], d
	rst $38
	rst $38
	and a
	ld [hl], c
	ld a, [bc]
	ld [hl], d
	rst $38
	rst $38
	pop bc
	ld [hl], c
	sbc l
	add h
	nop
	add b
	nop
	sbc l
	ld d, h
	nop
	add b
	nop
	sbc l
	ld a, [de]
	ld l, a
	and b
	nop
	and d
	ld b, h
	ld c, b
	ld b, h
	ld b, d
	ld b, h
	ld c, b
	ld c, h
	ld c, [hl]
	and e
	ld d, d
	and d
	ld bc, $a356
	ld e, h
	ld bc, $58a9
	ld e, h
	ld e, b
	xor b
	ld c, b
	nop
	and e
	ld bc, $3e3e
	ld bc, $4444
	ld bc, $4848
	ld bc, $4040
	nop
	and e
	ld c, [hl]
	ld c, [hl]
	ld c, [hl]
	ld b, h
	ld d, [hl]
	ld d, [hl]
	ld d, d
	ld e, b
	ld e, b
	ld b, b
	ld d, d
	ld d, d
	nop
	and e
	ld b, $0b
	dec bc
	nop
	and d
	ld b, b
	ld b, h
	ld b, b
	ld a, $40
	ld b, h
	ld c, b
	ld c, h
	and e
	ld c, [hl]
	and d
	ld bc, $a352
	ld e, b
	ld bc, $56a9
	ld e, b
	ld d, [hl]
	xor b
	ld b, h
	nop
	ld bc, $3a3a
	ld bc, $4040
	ld bc, $4444
	ld bc, $4040
	nop
	ld b, h
	ld c, h
	ld c, h
	ld b, h
	ld d, d
	ld d, d
	ld c, [hl]
	ld d, [hl]
	ld d, [hl]
	ld b, h
	ld c, h
	ld c, h
	nop
	and e
	ld e, b
	and a
	ld d, [hl]
	and d
	ld d, d
	and e
	ld d, [hl]
	and a
	ld c, [hl]
	and d
	ld c, b
	ld c, h
	ld c, h
	and e
	ld c, h
	ld c, [hl]
	xor b
	ld d, d
	nop
	ld bc, $4646
	ld bc, $4444
	and d
	ld b, b
	ld b, b
	and e
	ld b, b
	ld b, b
	xor b
	ld b, b
	nop
	ld b, [hl]
	ld c, [hl]
	ld c, [hl]
	ld b, h
	ld d, [hl]
	ld d, [hl]
	and d
	ld d, d
	ld d, d
	and e
	ld d, d
	ld c, b
	ld c, h
	and a
	ld c, b
	and d
	ld b, [hl]
	nop
	and e
	ld d, d
	and a
	ld e, b
	and d
	ld d, [hl]
	and e
	ld d, [hl]
	and a
	ld e, h
	and d
	ld h, [hl]
	ld h, b
	ld h, b
	and e
	ld h, b
	ld h, h
	xor b
	ld h, [hl]
	nop
	ld bc, $4646
	ld bc, $4444
	ld bc, $3a40
	ld bc, $4446
	nop
	ld b, [hl]
	ld c, [hl]
	ld c, [hl]
	ld b, h
	ld d, [hl]
	ld d, [hl]
	ld b, b
	ld d, d
	ld b, h
	ld c, [hl]
	ld e, b
	ld d, [hl]
	nop
	sbc l
	ld h, e
	nop
	add b
	nop
	sbc l
	ld b, h
	nop
	add b
	nop
	sbc l
	ld a, [de]
	ld l, a
	and b
	nop
	ld b, $73
	ld a, [hl-]
	ld [hl], e
	ld h, d
	ld [hl], e
	ld h, d
	ld [hl], e
	call nz, $ff73
	rst $38
	or e
	ld [hl], d
	inc bc
	ld [hl], e
	scf
	ld [hl], e
	adc c
	ld [hl], e
	adc c
	ld [hl], e
	ld b, [hl]
	ld [hl], h
	rst $38
	rst $38
	pop bc
	ld [hl], d
	ld a, [de]
	ld [hl], e
	ld c, [hl]
	ld [hl], e
	or b
	ld [hl], e
	or b
	ld [hl], e
	or b
	ld [hl], e
	or b
	ld [hl], e
	or b
	ld [hl], e
	or b
	ld [hl], e
	cp e
	ld [hl], h
	reti


	ld [hl], h
	reti


	ld [hl], h
	reti


	ld [hl], h
	jp hl


	ld [hl], h
	ld sp, hl
	ld [hl], h
	ld sp, hl
	ld [hl], h
	add hl, bc
	ld [hl], l
	add hl, bc
	ld [hl], l
	add hl, de
	ld [hl], l
	add hl, de
	ld [hl], l
	add hl, bc
	ld [hl], l
	add hl, hl
	ld [hl], l
	rst $38
	rst $38
	rst $08
	ld [hl], d
	ld l, $73
	rst $38
	rst $38
	DB $fd
	ld [hl], d
	and l
	ld bc, $9d00
	ld h, d
	nop
	add b
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	jr nc, jr_001_7342

	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	jr nc, jr_001_7349

	nop
	sbc l
	ld a, [de]
	ld l, a
	and b
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	jr nc, jr_001_7356

	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	jr nc, jr_001_735d

	nop
	and d
	ld b, $a1
	ld b, $06
	and d
	ld b, $06
	nop
	and l
	ld bc, $9d00
	ld [hl-], a
	nop
	add b
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]

jr_001_7342:
	ld a, [hl-]
	and d
	jr nc, jr_001_7376

	ld a, [hl-]
	and c
	ld a, [hl-]

jr_001_7349:
	ld a, [hl-]
	and d
	jr nc, jr_001_737d

	nop
	sbc l
	ld a, [de]
	ld l, a
	and b
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]

jr_001_7356:
	ld a, [hl-]
	and d
	jr nc, jr_001_738a

	ld a, [hl-]
	and c
	ld a, [hl-]

jr_001_735d:
	ld a, [hl-]
	and d
	jr nc, jr_001_7391

	nop
	sbc l
	add d
	nop
	add b
	and d
	ld a, [hl-]
	ld c, b
	ld d, d
	ld d, b
	ld d, d
	and c
	ld c, b
	ld c, b
	and d
	ld c, d
	ld b, h
	ld c, b
	and c
	ld b, b
	ld b, b

jr_001_7376:
	and d
	ld b, h
	ld a, $40
	and c
	ld a, [hl-]
	ld a, [hl-]

jr_001_737d:
	and d
	ld a, $38
	ld a, [hl-]
	jr nc, jr_001_73b5

	jr c, jr_001_73bf

	jr nc, jr_001_73b9

	ld a, $00
	sbc l

jr_001_738a:
	ld d, e
	nop
	ld b, b
	and d
	jr nc, jr_001_73d0

	ld b, b

jr_001_7391:
	ld b, h
	ld b, b
	and c
	ld a, $40
	and d
	ld b, h
	ld a, $40
	and c
	jr c, jr_001_73d7

	and d
	ld a, $38
	ld a, [hl-]
	and c
	ld l, $30
	and d
	jr c, jr_001_73d7

	jr nc, jr_001_73d1

	inc l
	inc l
	jr nc, @+$2a

	inc l
	jr c, jr_001_73b0

jr_001_73b0:
	sbc l
	ld a, [de]
	ld l, a
	and b
	and d

jr_001_73b5:
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]

jr_001_73b9:
	and d
	jr nc, jr_001_73ec

	ld a, [hl-]
	and c
	ld a, [hl-]

jr_001_73bf:
	ld a, [hl-]
	and d
	jr nc, jr_001_73f3

	nop
	xor b
	ld a, [hl-]
	and d
	ld a, $38
	xor b
	ld a, [hl-]
	and e
	ld a, $a2
	ld b, b
	and c

jr_001_73d0:
	ld b, b

jr_001_73d1:
	ld b, b
	and d
	ld b, h
	ld a, $40
	and c

jr_001_73d7:
	ld b, b
	ld b, b
	and d
	ld b, h
	ld a, $a8
	ld b, b
	and e
	ld b, h
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, d
	ld b, h
	ld c, b
	and c
	ld c, b

jr_001_73eb:
	ld c, b

jr_001_73ec:
	and d
	ld c, d
	ld b, h
	xor b
	ld c, b

jr_001_73f1:
	and e
	ld c, h

jr_001_73f3:
	and d
	ld c, [hl]
	and c
	ld c, [hl]
	ld c, [hl]
	and d
	ld c, [hl]
	ld c, [hl]
	ld d, d
	ld c, [hl]
	ld c, [hl]
	ld c, h
	ld c, [hl]
	and c
	ld c, [hl]
	ld c, [hl]
	and d
	ld c, [hl]
	ld c, [hl]
	ld d, d
	ld c, [hl]
	ld c, [hl]
	ld c, h
	ld c, [hl]
	and c
	ld c, [hl]
	ld c, [hl]
	and d
	ld c, [hl]
	ld c, [hl]
	ld c, h
	and c
	ld c, h
	ld c, h
	and d
	ld c, h
	ld c, h
	ld c, d
	and c
	ld c, d
	ld c, d
	and d
	ld c, d
	ld b, h
	ld a, $40
	ld b, h
	ld [hl], $44
	and c
	ld b, b
	ld b, b
	and d
	ld [hl], $a3
	ld b, b
	and c
	ld [hl], $3a
	and d
	ld [hl], $30
	ld b, h
	and c
	ld b, b
	ld b, b
	and d
	ld [hl], $a3
	ld b, b
	and c
	ld [hl], $3a
	and d
	ld [hl], $2e
	and l
	ld [hl], $a8

jr_001_7442:
	ld bc, $38a3
	nop
	xor b
	jr nc, jr_001_73eb

	jr nc, jr_001_747b

	xor b
	jr nc, jr_001_73f1

	ld [hl], $a5
	ld bc, $01a8
	and e
	ld a, $a2
	ld b, b
	and c
	ld b, b
	ld b, b
	and d
	ld b, h
	ld a, $40
	and c
	ld b, b
	ld b, b
	and d
	ld b, h
	ld a, $a8
	ld [hl], $a3
	ld a, [hl-]
	and d
	ld a, $a1
	ld b, b
	ld b, h
	and d
	ld a, $44
	ld c, b
	ld c, b
	ld c, b
	ld a, [hl-]
	ld a, $a1
	ld b, b
	ld b, h
	and d
	ld a, $44

jr_001_747b:
	ld b, [hl]
	ld b, [hl]

jr_001_747d:
	ld b, [hl]
	ld a, [hl-]
	ld a, $a1

jr_001_7481:
	ld b, b
	ld b, h
	and d

jr_001_7484:
	ld a, $44
	ld a, [hl-]
	and c

jr_001_7488:
	ld a, $40
	and d
	ld a, [hl-]
	ld b, b

jr_001_748d:
	ld a, [hl-]
	and c
	ld a, $40

jr_001_7491:
	and d
	ld a, $3e

jr_001_7494:
	inc l
	ld a, [hl-]
	ld a, $26

jr_001_7498:
	jr nc, @-$5d

	jr nc, jr_001_74cc

	and d
	jr nc, jr_001_7442

	jr nc, jr_001_7442

	jr nc, jr_001_74d7

	and d

jr_001_74a4:
	jr nc, jr_001_74ce

	ld l, $a1

jr_001_74a8:
	ld l, $2e
	and d
	ld l, $a3
	ld l, $a1
	ld l, $32
	and d
	ld l, $28
	and l
	ld h, $a8
	ld bc, $2ca3
	nop
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld [hl-], a
	inc l
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	jr c, jr_001_74fa

	ld a, [hl-]
	and c

jr_001_74cc:
	ld a, [hl-]
	ld a, [hl-]

jr_001_74ce:
	and d
	ld [hl-], a
	inc l
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	inc l

jr_001_74d7:
	ld e, $00
	and d
	jr z, jr_001_747d

	ld b, b
	jr z, jr_001_7481

	ld e, $36
	jr z, jr_001_7484

	ld b, b
	jr z, jr_001_7488

	ld e, $36
	nop
	and d
	jr z, jr_001_748d

	ld b, b
	jr z, jr_001_7491

	ld e, $36
	jr z, jr_001_7494

	ld b, b
	jr z, jr_001_7498

	inc l
	ld b, h
	nop
	and d

jr_001_74fa:
	ld e, $a1
	ld [hl], $1e
	and d
	ld e, $36
	jr z, jr_001_74a4

	ld b, b
	jr z, jr_001_74a8

	jr z, jr_001_7548

	nop
	and d
	ld e, $a1
	ld [hl], $1e
	and d
	ld e, $36
	ld e, $a1
	ld [hl], $1e
	and d
	ld e, $36
	nop
	and d
	ld [hl+], a
	and c
	ld a, [hl-]
	ld [hl+], a
	and d
	ld [hl+], a
	ld a, [hl-]
	ld [hl+], a
	and c
	ld a, [hl-]
	ld [hl+], a
	and d
	ld [hl+], a
	ld a, [hl-]
	nop
	and d
	ld e, $a1
	ld [hl], $1e
	and d
	ld e, $36
	ld e, $a1
	ld [hl], $1e
	and d
	and h
	ld a, $00
	ld [hl], $3e
	ld b, h
	and h
	ld b, h
	ld d, d
	ld [hl], l
	ld e, l
	ld [hl], l
	rst $38
	rst $38
	ld b, b
	ld [hl], l
	ld e, c
	ld [hl], l

jr_001_7548:
	rst $38
	rst $38
	ld b, [hl]
	ld [hl], l
	ld [hl], a
	ld [hl], l
	rst $38
	rst $38
	ld c, h
	ld [hl], l
	sbc l
	jr nz, jr_001_7555

jr_001_7555:
	add c
	xor d
	ld bc, $9d00
	ld [hl], b
	nop
	add c
	and d
	ld b, d
	ld [hl-], a
	jr c, jr_001_75a4

	ld b, [hl]
	inc [hl]
	inc a
	ld b, [hl]
	ld c, d
	jr c, jr_001_75ab

	ld c, d
	ld c, h
	inc a
	ld b, d
	ld c, h
	ld b, [hl]
	inc [hl]
	inc a
	ld b, [hl]
	ld b, b
	ld l, $34
	ld b, b
	nop
	sbc l
	ld a, [de]
	ld l, a
	ld hl, $42a8
	and e
	ld a, [hl+]
	xor b
	ld b, d
	and e
	ld a, [hl+]
	xor b
	ld b, d
	and e
	ld a, [hl+]
	nop
	sbc h
	ld [hl], l
	and a
	ld [hl], l
	rst $38
	rst $38
	adc d
	ld [hl], l
	and e
	ld [hl], l
	rst $38
	rst $38
	sub b
	ld [hl], l
	jp hl


	ld [hl], l
	rst $38
	rst $38
	sub [hl]
	ld [hl], l
	sbc l
	jr nz, jr_001_759f

jr_001_759f:
	add c
	xor d
	ld bc, $9d00

jr_001_75a4:
	ld [hl], b
	nop
	add c
	and d
	ld c, h
	ld b, d
	ld d, b

jr_001_75ab:
	ld b, d
	ld d, h
	ld b, d
	ld d, b
	ld b, d
	ld d, [hl]
	ld b, d
	ld d, h
	ld b, d
	ld d, b
	ld b, d
	ld d, h
	ld b, d
	ld c, h
	ld b, d
	ld d, b
	ld b, d
	ld d, h
	ld b, d
	ld d, b
	ld b, d
	ld d, [hl]
	ld b, d
	ld d, h
	ld b, d
	ld d, b

jr_001_75c5:
	ld b, d
	ld d, h
	ld b, d
	ld e, d
	ld b, [hl]
	ld d, [hl]
	ld b, [hl]
	ld d, h
	ld b, [hl]
	ld d, b
	ld b, [hl]
	ld c, [hl]
	ld b, [hl]
	ld d, b
	ld b, [hl]
	ld d, h
	ld b, [hl]
	ld d, b
	ld b, [hl]
	ld d, b
	ld a, $4c
	ld a, $4c
	ld a, $4a
	ld a, $4a
	ld a, $46
	ld a, $4a
	ld a, $50
	ld a, $00
	sbc l
	ld a, [de]
	ld l, a
	ld hl, $4ca5
	ld c, d
	ld b, [hl]
	ld b, d
	jr c, jr_001_7632

	ld b, d
	ld b, d
	nop
	rst $38
	ld [hl], l
	nop
	nop
	rrca
	DB $76
	ld e, $76
	sbc l
	or d
	nop
	add b
	and d
	ld h, b
	ld e, h
	ld h, b
	ld e, h
	ld h, b
	ld h, d
	ld h, b
	ld e, h
	and h
	ld h, b
	nop
	sbc l
	sub d
	nop
	add b
	and d
	ld d, d
	ld c, [hl]
	ld d, d
	ld c, [hl]
	ld d, d
	ld d, h
	ld d, d
	ld c, [hl]
	and h
	ld d, d
	sbc l
	ld a, [de]
	ld l, a
	jr nz, jr_001_75c5

	ld h, d
	ld h, b
	ld h, d
	ld h, b
	ld h, d
	ld h, [hl]
	ld h, d
	ld h, b
	and e
	ld h, d
	ld bc, $766a
	ld h, h
	ld [hl], a

jr_001_7632:
	ld h, h
	ld [hl], a

jr_001_7634:
	nop
	nop
	cp d
	DB $76
	and l
	ld [hl], a
	scf
	ld a, b
	rlca
	ld [hl], a
	and $77
	and $77
	ld a, [$ff00+$77]
	and $77
	and $77
	ld sp, hl
	ld [hl], a
	ld a, [$ff00+$77]
	and $77
	and $77
	ld sp, hl
	ld [hl], a
	ld a, [$ff00+$77]
	ld [bc], a
	ld a, b
	inc c
	ld a, b
	ld sp, hl
	ld [hl], a
	ld a, [$ff00+$77]
	and $77
	ld d, [hl]
	ld [hl], a
	ld d, [hl]
	ld [hl], a
	dec d
	ld a, b
	dec d
	ld a, b
	dec d
	ld a, b
	dec d
	ld a, b
	sbc l
	jp $8000


	and d
	inc a
	ld a, $3c
	ld a, $38
	ld d, b
	and e
	ld bc, $3ca2
	ld a, $3c
	ld a, $38
	ld d, b
	and e
	ld bc, $01a2
	ld c, b
	db $01, $46, $01
	ld b, d
	ld bc, $a146
	ld b, d
	ld b, [hl]
	and d
	ld b, d
	ld b, d
	jr c, jr_001_7634

	inc a
	ld bc, $3ea2
	ld b, d
	ld a, $42
	inc a
	ld d, h
	and e
	ld bc, $3ea2
	ld b, d
	ld a, $42
	inc a
	ld d, h
	and e
	ld bc, $01a2
	ld d, [hl]
	ld bc, $0154
	ld d, h
	ld bc, $a250
	ld bc, $50a1
	ld d, h
	and d
	ld d, b
	ld c, [hl]
	and e
	ld d, b
	ld bc, $9d00
	ld [hl], h
	nop
	add b
	and d
	ld [hl], $38
	ld [hl], $38
	ld l, $3e
	and e
	ld bc, $36a2
	jr c, jr_001_7701

	jr c, @+$30

	ld a, $a3
	ld bc, $01a2
	ld [hl], $01
	ld [hl], $01
	ld [hl-], a
	ld bc, $3636
	ld [hl-], a
	ld [hl-], a
	jr nc, @-$5b

	ld [hl], $01
	and d
	jr c, jr_001_771f

	jr c, @+$3e

	ld [hl], $4e
	and e
	ld bc, $38a2
	inc a
	jr c, @+$3e

	ld [hl], $4e
	and e
	ld bc, $01a2
	ld d, b

jr_001_76f5:
	db $01, $4e, $01
	ld b, [hl]
	ld bc, $a246
	ld bc, $48a1
	ld c, [hl]
	and d

jr_001_7701:
	ld c, b
	ld b, [hl]
	and e
	ld b, b
	ld bc, $9d00
	ld a, [de]
	ld l, a
	jr nz, @-$5c

	ld c, b
	ld b, [hl]
	ld c, b
	ld b, [hl]
	ld a, $20
	and e
	ld bc, $48a2
	ld b, [hl]
	ld c, b
	ld b, [hl]
	ld a, $20
	and e
	ld bc, $2ea2

jr_001_771f:
	inc a
	ld l, $24
	inc h
	inc h
	inc h
	inc a
	ld a, [hl+]
	ld a, $2a
	ld a, $a6
	ld l, $a3
	ld bc, $01a1
	and d
	ld c, b
	ld b, [hl]
	ld c, b
	ld b, [hl]
	ld l, $2e
	and e
	ld bc, $48a2
	ld b, [hl]
	ld c, b

jr_001_773d:
	ld b, [hl]
	ld l, $2e
	and e
	ld bc, $2aa2
	inc a
	ld a, [hl+]
	inc a
	ld l, $3e
	ld l, $3e
	ld l, $42
	ld l, $42
	and [hl]
	jr c, jr_001_76f5

	ld bc, $01a1
	nop
	xor b
	ld bc, $06a2
	dec bc
	xor b
	ld bc, $06a2
	dec bc
	and l
	ld bc, $0001
	sbc l
	push bc
	nop
	add b
	and c
	ld b, [hl]
	ld c, d
	and h
	ld b, [hl]
	and d
	ld bc, $50a3
	xor b
	ld c, d
	and e
	ld bc, $42a1
	ld b, [hl]
	and h
	ld b, d
	and d
	ld bc, $4ea3
	and c
	ld c, [hl]
	ld d, b
	and h
	ld b, [hl]
	and a
	ld bc, $40a1
	ld b, [hl]
	and h
	ld b, b
	and d
	ld bc, $46a3
	and c
	ld b, [hl]
	ld c, d
	and h
	ld b, d
	and a
	ld bc, $36a1
	jr c, jr_001_773d

	ld [hl], $a2
	ld bc, $3ca3
	and a
	ld b, d
	and h
	ld b, b
	and d
	ld bc, $9d00
	add h
	nop
	ld b, c
	and c
	ld b, b
	ld b, d
	and h
	ld b, b
	and d
	ld bc, $40a3
	xor b
	ld b, d
	and e
	ld bc, $3ca1
	ld b, b
	and h
	inc a
	and d
	ld bc, $3ca3
	and c
	inc a
	ld b, b
	and h
	ld b, b
	and a
	ld bc, $36a1
	ld [hl-], a
	and h
	ld l, $a2
	ld bc, $40a3
	and c
	ld [hl], $38
	and h
	ld [hl-], a
	and a
	ld bc, $2ea1
	ld [hl-], a
	and h
	ld l, $a2
	ld bc, $2aa3
	and a
	jr nc, @-$5a

	ld l, $a2
	ld bc, $a200
	jr c, @+$3a

	ld bc, $3838
	jr c, @+$03

	jr c, jr_001_77f0

jr_001_77f0:
	ld l, $2e
	ld bc, $2e2e
	ld l, $01
	ld l, $00
	ld a, [hl+]
	ld a, [hl+]
	ld bc, $2a2a
	ld a, [hl+]
	ld bc, $002a
	and d
	jr c, jr_001_783d

	ld bc, $3638
	ld [hl], $01
	ld [hl], $00
	ld [hl-], a
	ld [hl-], a
	ld bc, $2e32
	ld l, $01
	ld l, $00
	and d
	ld b, $0b
	ld bc, $0606
	dec bc
	ld bc, $0606
	dec bc
	ld bc, $0606
	dec bc
	ld bc, $0606
	dec bc
	ld bc, $0606
	dec bc
	ld bc, $0606
	dec bc
	ld bc, $0106
	dec bc
	ld bc, $000b
	sbc l
	ld h, [hl]
	nop
	add c
	and a
	ld e, b

jr_001_783d:
	ld e, d
	and e
	ld e, b
	and a
	ld e, [hl]
	and h
	ld e, d
	and d
	ld bc, $50a7
	ld d, h
	and e
	ld e, b
	and a
	ld e, d
	and h
	ld e, b
	and d
	ld bc, $50a7
	and e
	ld c, [hl]
	and a
	ld c, [hl]
	ld e, b
	ld d, h
	and e
	ld c, d
	and a
	ld e, d
	ld e, [hl]
	and e
	ld e, d
	and a
	ld d, h
	and h
	ld d, b
	and d
	ld bc, $8900
	ld a, b
	inc c
	ld a, c
	adc c
	ld a, b
	sub c
	ld a, c
	nop
	nop
	xor b
	ld a, b
	inc sp
	ld a, c
	xor b
	ld a, b

jr_001_7877:
	or l
	ld a, c
	ret nc

	ld a, b
	ld e, c
	ld a, c
	ret nc

	ld a, b
	ret c

	ld a, c
	ld sp, hl
	ld a, b
	ld a, a
	ld a, c
	ld sp, hl
	ld a, b
	ld a, a
	ld a, c
	sbc l
	pop de
	nop
	add b
	and d
	ld e, h
	and c
	ld e, h
	ld e, d
	and d
	ld e, h
	ld e, h
	ld d, [hl]
	ld d, d
	ld c, [hl]
	ld d, [hl]
	and d
	ld d, d
	and c
	ld d, d
	ld d, b
	and d
	ld d, d
	ld d, d
	ld c, h
	ld c, b
	ld b, h
	and c
	ld c, h
	ld d, d
	nop
	sbc l
	or d
	nop
	add b
	and d
	ld d, d
	and c
	ld d, d
	ld d, d
	and d
	ld d, d
	and c
	ld d, d
	ld d, d
	and d
	ld b, h
	and c
	ld b, h
	ld b, h
	and d
	ld b, h
	ld bc, $a14c
	ld c, h
	ld c, h
	and d
	ld c, h
	and c
	ld c, h
	ld c, h
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld a, [hl-]
	ld bc, $9d00
	ld a, [de]
	ld l, a
	jr nz, jr_001_7877

	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld c, [hl]
	and c
	ld d, d
	ld d, d
	and d
	ld d, [hl]
	ld bc, $5ca2
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld b, h
	and c
	ld c, b
	ld c, b
	and d
	ld c, h
	ld bc, $a200
	ld b, $a7
	ld bc, $0ba2
	dec bc
	dec bc
	ld bc, $06a2
	and a
	ld bc, $0ba2
	dec bc
	dec bc
	ld bc, $a200
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld b, h
	and c
	ld b, h
	ld d, d
	and d
	ld b, d
	and c
	ld b, d
	ld d, d
	and d
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld c, h
	and c
	ld c, h
	ld d, d
	and d
	ld b, h
	and c
	ld b, h
	ld d, d
	and d
	ld c, b
	ld b, h
	and c
	ld c, b
	ld d, d
	ld d, [hl]
	ld e, d
	nop
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld [hl], $a1
	ld [hl], $36
	and d
	ld [hl], $01
	nop
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld b, h
	and c
	ld b, h
	ld b, h
	and d
	ld b, h
	and c
	ld b, h
	ld b, h
	and d
	ld b, d
	and c
	ld b, d
	ld b, d
	and d
	ld b, d
	ld bc, $a200
	ld bc, $010b
	dec bc
	ld bc, $010b
	dec bc
	ld bc, $010b
	dec bc
	ld bc, $0b0b
	ld bc, $a200
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld b, h
	and c
	ld b, h
	ld d, d
	and d
	ld b, d
	and c
	ld b, d
	ld d, d
	and d
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld c, h
	and c
	ld c, h
	ld d, d
	and d
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld b, h
	ld d, d
	and e
	ld e, h
	nop
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld a, [hl-]
	and c
	ld a, [hl-]
	ld a, [hl-]
	and d
	ld bc, $a33a
	ld c, h
	nop
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld c, b
	and c
	ld c, b
	ld c, b
	and d
	ld b, h

jr_001_79ed:
	and c
	ld b, h
	ld b, h
	and d
	ld b, h
	and c
	ld b, h
	ld b, h
	and d
	ld bc, $a34c
	ld b, h
	nop
	rst $38
	ld a, c
	nop
	nop
	sbc l
	jp nz, $4000

	and d
	ld e, h
	and c
	ld e, h
	ld e, d
	and d
	ld e, h
	ld e, h
	ld d, [hl]
	ld d, d
	ld c, [hl]
	ld d, [hl]
	and d
	ld d, d
	and c
	ld d, d
	ld d, b
	and d
	ld d, d
	ld d, d
	ld c, h
	ld c, b
	and c
	ld b, h
	ld b, d
	and d
	ld b, h
	and h
	ld bc, $2700
	ld a, d
	nop
	nop
	ld b, [hl]
	ld a, d
	sbc l
	jp nz, $8000

	and d
	ld e, h
	and c
	ld e, h
	ld e, d
	and d
	ld e, h
	ld e, h
	ld d, [hl]
	ld d, d
	ld c, [hl]
	ld d, [hl]
	and d
	ld d, d
	and c
	ld d, d
	ld d, b
	and d
	ld d, d
	ld c, h
	ld b, h
	ld d, d
	and e
	ld e, h
	and h
	ld bc, $9d00
	ld a, [de]
	ld l, a
	jr nz, jr_001_79ed

	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld c, [hl]

jr_001_7a56:
	ld d, d
	ld d, [hl]
	ld bc, $5ca2
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld d, d
	ld c, h
	ld b, h
	ld bc, $01a5
	ld [hl], d
	ld a, d
	nop
	nop
	sub c
	ld a, d
	xor a
	ld a, d
	sbc l
	jp nz, $8000

	and d
	ld e, h
	and c
	ld e, h
	ld e, d
	and d
	ld e, h
	ld e, h
	ld d, [hl]
	ld d, d
	ld c, [hl]
	ld d, [hl]
	and d
	ld d, d
	and c
	ld d, d
	ld d, b
	and d
	ld d, d
	ld c, h
	ld b, h
	ld d, d
	and e
	ld e, h
	and h
	ld bc, $9d00
	jp nz, $4000

	and d
	ld c, [hl]
	and c
	ld c, [hl]
	ld d, d
	and d
	ld d, [hl]
	ld c, [hl]
	and e
	ld c, b
	ld c, b
	and d
	ld c, h
	and c
	ld c, h
	ld c, d
	and d
	ld c, h
	ld b, h
	inc [hl]
	ld c, h
	and e
	ld c, h
	and l
	ld bc, $9d00
	ld a, [de]
	ld l, a
	jr nz, jr_001_7a56

	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld c, [hl]
	ld d, d
	and c
	ld d, [hl]
	ld d, [hl]
	and d
	ld d, [hl]
	and d
	ld e, h

jr_001_7ac7:
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld d, d
	ld c, h
	and c
	ld b, h
	ld b, h
	and d
	ld bc, $01a5
	nop
	DB $e4
	ld a, d
	nop
	nop
	inc bc
	ld a, e
	jr nz, jr_001_7b5d

	ld c, d
	ld a, e
	sbc l
	jp nz, $8000

	and d
	ld e, h
	and c
	ld e, h
	ld e, d
	and d
	ld e, h
	ld e, h
	ld d, [hl]
	ld d, d
	ld c, [hl]
	ld d, [hl]
	and d
	ld d, d
	and c
	ld d, d
	ld d, b
	and d
	ld d, d
	ld c, h
	ld b, h
	ld d, d
	and e
	ld e, h
	and h
	ld bc, $9d00
	or d
	nop
	add b
	and d
	ld c, [hl]
	and c
	ld c, [hl]
	ld d, d
	and d
	ld d, [hl]
	ld c, [hl]
	and e
	ld c, b
	ld c, b
	and d
	ld c, h
	and c
	ld c, h
	ld c, d
	and d
	ld c, h
	ld b, h
	inc [hl]
	ld c, h
	and e
	ld c, h
	and l
	ld bc, $1a9d
	ld l, a
	jr nz, jr_001_7ac7

	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	ld c, [hl]
	ld d, [hl]
	ld e, h
	ld d, [hl]
	ld c, [hl]
	ld b, h
	ld a, $44
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	and d
	ld e, h
	and c
	ld e, h
	ld e, h
	ld d, d
	ld c, h
	ld b, h
	ld c, h
	ld e, h
	ld bc, $01a2
	and l
	ld bc, $0ba2
	dec bc
	dec bc
	dec bc
	and d
	dec bc
	dec bc
	dec bc
	ld bc, $0ba2
	dec bc
	dec bc
	dec bc
	and d
	dec bc
	dec bc
	dec bc

jr_001_7b5d:
	ld bc, $01a5
	ld [hl], d
	ld a, e
	ret


	ld a, e
	nop
	nop
	sub c
	ld a, e
	DB $ed
	ld a, e
	and e
	ld a, e
	DB $fd
	ld a, e
	or [hl]
	ld a, e
	dec c
	ld a, h
	sbc l
	pop de
	nop
	add b
	and d
	ld e, h
	and c
	ld e, h
	ld e, d
	and d
	ld e, h
	ld e, h
	ld d, [hl]
	ld d, d
	ld c, [hl]
	ld d, [hl]
	and d
	ld d, d
	and c
	ld d, d
	ld d, b
	and d
	ld d, d
	ld d, d
	ld c, h
	ld c, b
	ld b, h
	and c
	ld c, h
	ld d, d
	nop
	and d
	ld d, d
	and a
	ld bc, $44a2
	ld b, h
	ld b, h
	ld bc, $a74c
	ld bc, $3aa2
	ld a, [hl-]
	ld a, [hl-]
	ld bc, $a200
	ld e, h
	and a
	ld bc, $4ea2
	ld d, d
	ld d, [hl]
	ld bc, $5ca2
	and a
	ld bc, $44a2
	ld c, b
	ld c, h
	ld bc, $a200
	ld b, $a7
	ld bc, $0ba2
	dec bc
	dec bc
	ld bc, $06a2
	and a
	ld bc, $0ba2
	dec bc
	dec bc
	ld bc, $a200
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld b, h
	and c
	ld b, h
	ld d, d
	and d
	ld b, d
	and c
	ld b, d
	ld d, d
	and d
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld c, h
	and c
	ld c, h
	ld d, d
	and d
	ld c, b
	and c
	ld c, b
	ld d, d
	and d
	ld e, h
	ld d, d
	and e
	ld e, h
	nop
	ld bc, $013a
	ld a, [hl-]
	ld bc, $013a
	ld a, [hl-]
	ld bc, $013a
	ld a, [hl-]
	ld bc, $a33a
	inc [hl]
	db $01, $48, $01
	ld c, b
	db $01, $48, $01
	ld c, b
	db $01, $44, $01
	ld b, h
	ld bc, $a34c
	ld b, h
	and d
	ld bc, $010b
	dec bc
	ld bc, $010b
	dec bc
	ld bc, $010b
	dec bc
	and d

jr_001_7c1b:
	ld bc, $0b0b
	ld bc, $7c29
	nop
	nop
	ld e, [hl]
	ld a, h
	sub d
	ld a, h
	add $7c

jr_001_7c29:
	sbc l
	or e
	nop
	add b
	and [hl]
	ld d, d
	and c
	ld d, b
	and [hl]
	ld d, d
	and c
	ld d, b
	and [hl]
	ld d, d
	and c
	ld c, b
	and e
	ld bc, $4ca6
	and c
	ld c, d
	and [hl]
	ld c, h
	and c
	ld c, d
	and [hl]
	ld c, h
	and c
	ld b, d
	and e
	ld bc, $3ea6
	and c
	ld b, d
	and [hl]
	ld b, h
	and c
	ld c, b
	and [hl]
	ld c, h
	and c
	ld d, b
	and [hl]
	ld d, d
	and c
	ld d, [hl]
	and [hl]
	ld d, d
	and c
	ld l, d
	nop
	sbc l
	sub e
	nop
	ret nz

	and [hl]
	ld b, d
	and c
	ld b, b
	and [hl]
	ld b, d
	and c
	ld b, b
	and [hl]
	ld b, d
	and c
	ld b, d
	and e
	ld bc, $3aa6
	and c
	jr c, jr_001_7c1b

	ld a, [hl-]
	and c
	jr c, @-$58

	ld a, [hl-]
	and c
	ld a, [hl-]

Call_001_7c7c:
	and e
	ld bc, $38a6
	and c
	jr c, jr_001_7c29

	ld a, [hl-]
	and c
	ld a, $a6
	ld b, d
	and c
	ld b, h
	and [hl]
	ld c, b
	and c
	ld c, h
	and [hl]
	ld b, d
	and c
	ld b, d
	sbc l
	ld a, [de]
	ld l, a
	and b
	and [hl]
	ld c, b
	and c
	ld b, [hl]
	and [hl]
	ld c, b
	and c
	ld b, [hl]
	and [hl]
	ld c, b
	and c
	ld d, d
	and e
	ld bc, $44a6
	and c
	ld b, d
	and [hl]
	ld b, h
	and c
	ld b, d
	and [hl]
	ld b, h
	and c
	ld c, h
	and e
	ld bc, $48a6
	and c
	ld a, [hl-]
	and [hl]
	ld a, $a1
	ld b, d
	and [hl]
	ld b, h
	and c
	ld c, b
	and [hl]
	ld c, h
	and c
	ld d, b
	and [hl]
	ld d, d
	and c
	ld a, [hl-]
	and [hl]
	dec bc
	and c
	ld b, $a6
	dec bc
	and c
	ld b, $a6
	dec bc
	and c
	ld b, $a3
	ld bc, $0ba6
	and c
	ld b, $a6
	dec bc
	and c
	ld b, $a6
	dec bc
	and c
	ld b, $a3
	ld bc, $0ba6
	and c
	ld b, $a6
	dec bc
	and c
	ld b, $a6
	dec bc
	and c
	ld b, $a3
	ld bc, $0ba6
	and c
	ld b, $29
	ld a, l
	rst $38
	rst $38
	DB $fc
	ld a, h
	inc h
	ld a, l
	jr nc, jr_001_7d7b

	ld d, [hl]
	ld a, l
	ld a, l
	ld a, l
	ld d, [hl]
	ld a, l
	sbc a
	ld a, l
	pop bc
	ld a, l
	rst $38
	rst $38
	cp $7c
	ld [hl], $7d
	ld h, a
	ld a, l
	adc [hl]
	ld a, l
	ld h, a
	ld a, l
	or b
	ld a, l
	ld [bc], a
	ld a, [hl]
	rst $38
	rst $38
	ld c, $7d
	add hl, sp
	ld a, l
	inc a
	ld a, l
	rst $38
	rst $38
	ld e, $7d
	sbc l
	ld h, b
	nop
	add c
	nop
	sbc l
	jr nz, jr_001_7d2c

jr_001_7d2c:
	add c
	xor d
	ld bc, $a300
	ld bc, $5450
	ld e, b
	nop
	and l
	ld bc, $a500
	ld bc, $a300
	ld bc, $0106
	ld b, $01
	and d
	ld b, $06
	and e
	ld bc, $a306
	ld bc, $0106
	ld b, $01
	and d
	ld b, $06
	ld bc, $0601
	ld b, $00
	and a
	ld e, d
	and d
	ld e, [hl]
	and a
	ld e, d
	and d
	ld e, b
	and a
	ld e, b
	and d
	ld d, h
	and a
	ld e, b
	and d
	ld d, h
	nop
	sbc l
	ld a, [$206e]
	and d
	ld e, d
	ld h, d
	ld l, b
	ld [hl], b
	ld e, d
	ld h, d
	ld l, b
	ld [hl], b
	ld e, d
	ld h, h
	ld h, [hl]
	ld l, h
	ld e, d
	ld h, h
	ld h, [hl]

jr_001_7d7b:
	ld l, h
	nop
	and a
	ld d, h
	and d
	ld d, b
	and a
	ld d, h
	and d
	ld d, b
	and a
	ld d, b
	and d
	ld c, h
	and a
	ld c, d
	and d
	ld d, b
	nop
	ld e, b
	ld e, [hl]
	ld h, h
	ld l, h
	ld e, b
	ld e, [hl]
	ld h, h
	ld l, h
	ld d, b
	ld d, h
	ld e, b
	ld e, [hl]
	ld d, b
	ld e, b
	ld e, [hl]
	ld h, h
	nop
	and a
	ld d, h
	and d
	ld d, b
	and a
	ld d, h
	and d
	ld d, b
	and a
	ld d, b
	and d
	ld c, h
	and a
	ld c, d
	and d
	ld b, [hl]
	nop
	ld e, b
	ld e, [hl]
	ld h, h
	ld l, h
	ld e, b
	ld e, [hl]
	ld h, h
	ld l, h
	ld d, b
	ld d, h
	ld e, b
	ld e, [hl]
	ld d, b
	ld e, b
	ld e, [hl]
	ld h, h
	nop
	and a
	ld c, d
	and d
	ld c, h
	and a
	ld c, d
	and d
	ld b, [hl]
	and a
	ld b, [hl]
	and d
	ld b, h
	and a
	ld b, [hl]
	and d
	ld c, d
	and a
	ld c, h
	and d
	ld d, b
	and a
	ld c, h
	and d
	ld c, d
	and a
	ld c, d
	and d
	ld b, [hl]
	and a
	ld c, d
	and d
	ld c, h
	and a
	ld d, b
	and d
	ld c, [hl]
	and a
	ld d, b
	and d
	ld d, d
	and a
	ld e, b
	and d
	ld d, h
	and a
	ld e, d
	and d
	ld d, h
	and a
	ld d, d
	and d
	ld d, b
	and a
	ld c, h
	and d
	ld c, d
	and d
	ld b, d
	jr c, jr_001_7e39

	ld c, d
	and e
	ld b, d
	ld bc, $4a00
	ld d, d
	ld e, b
	ld e, [hl]
	ld c, d
	ld e, b
	ld e, [hl]
	ld h, d
	ld d, h
	ld h, d
	ld l, b
	ld l, h
	ld d, h
	ld h, d
	ld l, b
	ld l, h
	ld b, [hl]
	ld c, h

jr_001_7e14:
	ld d, h
	ld e, [hl]
	ld b, [hl]
	ld c, h
	ld d, h
	ld e, d
	ld d, b
	ld e, b
	ld e, [hl]
	ld h, h
	ld d, b
	ld e, [hl]
	ld h, h
	ld l, h
	ld c, d
	ld d, b
	ld e, b
	ld e, [hl]
	ld c, d
	ld e, b
	ld e, [hl]
	ld h, d
	ld c, [hl]
	ld d, h
	ld e, d
	ld h, d
	ld c, [hl]
	ld d, h
	ld e, d
	ld h, [hl]
	ld d, b
	ld e, b
	ld e, [hl]
	ld h, h
	ld d, b
	ld e, [hl]
	ld h, h

jr_001_7e39:
	ld l, b
	xor b
	ld e, d
	and e
	ld bc, $4900
	ld a, [hl]
	nop
	nop
	ld e, c
	ld a, [hl]
	ld l, b
	ld a, [hl]
	ld a, b
	ld a, [hl]
	sbc l
	or c
	nop
	add b
	and a
	ld bc, $5ea1
	ld e, [hl]
	and [hl]
	ld l, b
	and c
	ld e, [hl]
	and h
	ld l, b
	nop
	sbc l
	sub c
	nop
	add b
	and a
	ld bc, $54a1
	ld d, h
	and [hl]
	ld e, [hl]
	and c
	ld e, b
	and h
	ld e, [hl]
	sbc l
	ld a, [de]
	ld l, a
	jr nz, jr_001_7e14

	ld bc, $4ea1
	ld c, [hl]
	and [hl]
	ld e, b
	and c
	ld d, b
	and e
	ld e, b
	ld bc, $01a7
	and c
	ld b, $06
	and [hl]
	dec bc
	and c
	ld b, $a0
	ld b, $06
	ld b, $06
	ld b, $06
	ld b, $06
	and e
	ld bc, $7eb6
	inc hl
	ld a, a
	or [hl]
	ld a, [hl]
	ld l, [hl]
	ld a, a
	rst $38
	rst $38
	adc h
	ld a, [hl]
	ld [$ff00+$7e], a
	ld c, d
	ld a, a
	ld [$ff00+$7e], a
	sub c
	ld a, a
	rst $38
	rst $38
	sbc b
	ld a, [hl]
	or $7e
	ld e, h
	ld a, a
	or $7e
	xor c
	ld a, a
	rst $38
	rst $38
	and h
	ld a, [hl]
	inc c
	ld a, a
	rst $38
	rst $38
	or b
	ld a, [hl]
	sbc l
	add d
	nop
	add b
	and d
	ld d, h
	and c
	ld d, h
	ld d, h
	ld d, h
	ld c, d
	ld b, [hl]
	ld c, d
	and d
	ld d, h
	and c
	ld d, h
	ld d, h
	ld d, h
	ld e, b
	ld e, h
	ld e, b
	and d
	ld d, h
	and c
	ld d, h
	ld d, h
	ld e, b
	ld d, h
	ld d, d
	ld d, h
	and c
	ld e, b
	ld e, h
	ld e, b
	ld e, h
	and d
	ld e, b
	and c
	ld d, [hl]
	ld e, b
	nop
	sbc l
	ld h, d
	nop
	add b
	and d
	db $01, $44, $01
	ld b, b
	db $01, $44, $01
	ld b, [hl]
	db $01, $44, $01
	ld b, h
	ld bc, $0140
	ld b, b
	nop
	sbc l
	ld a, [de]
	ld l, a
	jr nz, @-$5c

	ld d, h
	ld d, h
	ld c, d
	ld d, d
	ld d, h
	ld d, h
	ld c, d
	ld e, b
	ld d, h
	ld d, h
	ld d, d
	ld d, h
	ld c, [hl]
	ld d, h
	ld c, d
	ld d, d
	nop
	and d
	ld b, $0b
	ld b, $0b
	ld b, $0b
	ld b, $0b
	ld b, $0b
	ld b, $0b
	ld b, $a1
	dec bc
	dec bc
	ld b, $a2
	dec bc
	and c
	ld b, $00
	and d
	ld e, [hl]
	and c
	ld e, [hl]
	ld e, [hl]
	ld e, [hl]
	ld d, h
	ld d, b
	ld d, h
	and d
	ld e, [hl]
	and c
	ld e, [hl]
	ld e, [hl]
	ld e, [hl]
	ld h, d
	ld h, [hl]
	ld h, d
	and d
	ld e, [hl]
	and c
	ld e, [hl]
	ld e, h
	and d
	ld e, b
	and c
	ld e, b
	ld d, h
	and c
	ld d, d
	ld d, h
	ld d, d
	ld d, h
	and d
	ld d, d
	and c
	ld c, [hl]
	ld d, d
	nop
	and d
	db $01, $46, $01
	ld c, d
	db $01, $46, $01
	ld c, d
	db $01, $46, $01
	ld b, [hl]
	db $01, $46, $01
	ld b, [hl]
	nop
	and d
	ld b, [hl]
	ld d, h
	ld d, h
	ld d, h
	ld b, [hl]
	ld d, h
	ld d, h
	ld d, h
	ld b, [hl]
	ld d, h
	ld d, d
	ld e, b
	ld b, h
	ld d, d
	ld c, d
	ld e, b
	nop
	and d
	ld h, d
	and c
	ld h, d
	ld h, d
	ld h, d
	ld e, [hl]
	ld e, d
	ld e, [hl]
	and d
	ld h, d
	and c
	ld h, d
	ld h, d
	ld h, d
	ld e, [hl]
	ld e, d
	ld e, [hl]
	and d
	ld h, d
	and c
	ld c, d
	ld c, [hl]
	and d
	ld d, d
	and c
	ld c, d
	ld e, h
	and e
	ld e, b
	and c
	ld d, h
	and [hl]
	ld l, h
	nop
	and d
	db $01, $4a, $01
	ld c, d
	db $01, $4a, $01
	ld c, d
	ld bc, $46a1
	ld b, [hl]
	and d
	ld b, [hl]
	and c
	ld b, [hl]
	ld b, [hl]
	and e
	ld b, [hl]
	and d
	ld b, h
	ld bc, $a200
	ld b, d
	ld e, d
	ld d, b
	ld e, d
	ld b, d
	ld e, d
	ld d, b
	ld e, d
	ld c, d
	and c
	ld d, d
	ld d, d
	and d
	ld d, d
	and c
	ld d, d
	ld d, d
	and e
	ld d, d
	and d
	ld d, h
	db 1

	rept 48
	nop
	endr

IF DEF(INTERNATIONAL)
	rept 72
	nop
	endr
ENDC

JumpUpdateAudio::
	jp UpdateAudio

JumpResetAudio::
	jp ResetAudio

	rept 10
	nop
	endr
