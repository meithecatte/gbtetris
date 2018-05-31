SerialInterrupt::
        push af
        push hl
        push de
        push bc
        call HandleSerialState
        ld a, $01
        ld [hSerialDone], a
        pop bc
        pop de
        pop hl
        pop af
        reti

HandleSerialState::
        ld a, [hSerialState]
        jumptable
	dw SerialTitleScreen ; SERIAL_STATE_TITLESCREEN
	dw SerialState1
	dw SerialState2
	dw SerialState3
	dw GenericEmptyRoutine

SerialTitleScreen::
        ld a, [hGameState]
        cp STATE_TITLESCREEN
        jr z, .on_titlescreen

        cp STATE_LOAD_TITLESCREEN ; pointless
        ret z

        ld a, STATE_LOAD_TITLESCREEN
        ld [hGameState], a
        ret

.on_titlescreen:
        ld a, [rSB]
        cp SERIAL_SLAVE
        jr nz, .not_master

        ld a, SERIAL_MASTER
        ld [hMasterSlave], a
        ld a, SCF_MASTER
        jr .done

.not_master:
        cp SERIAL_MASTER
        ret nz

        ld a, SERIAL_SLAVE
        ld [hMasterSlave], a
        xor a

.done:
        ld [rSC], a
        ret

SerialState1::
        ld a, [rSB]
        ld [hRecvBuffer], a
        ret

SerialState2::
        ld a, [rSB]
        ld [hRecvBuffer], a
        ld a, [hMasterSlave]
        cp SERIAL_MASTER
        ret z

        ld a, [hSendBuffer]
        ld [rSB], a
        ld a, $ff
        ld [hSendBuffer], a
        ld a, SCF_RQ
        ld [rSC], a
        ret

SerialState3::
        ld a, [rSB]
        ld [hRecvBuffer], a
        ld a, [hMasterSlave]
        cp SERIAL_MASTER
        ret z

        ld a, [hSendBuffer]
        ld [rSB], a
        ei
        call DelayLoop
        ld a, SCF_RQ
        ld [rSC], a
        ret

        ld a, [hSerialState]
        cp SERIAL_STATE_2
        ret nz

        xor a
        ld [rIF], a
        ei
        ret
