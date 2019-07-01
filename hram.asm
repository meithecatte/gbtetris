hKeysHeld       EQU $ff80
hKeysPressed    EQU $ff81
hVBlankOccured  EQU $ff85

; parameters for UpdateSprites
hOAMBufferPtrHi EQU $ff8d
hOAMBufferPtrLo EQU $ff8e
hSpriteCount    EQU $ff8f

; UpdateSprites temp
hCurSpriteBuffer EQU $ff86 ; ends $ff8c, SPRITE_INFO_SIZE bytes long
hCurSpriteVisibility EQU hCurSpriteBuffer
hCurSpriteY          EQU hCurSpriteBuffer + 1
hCurSpriteX          EQU hCurSpriteBuffer + 2
hCurSpriteID         EQU hCurSpriteBuffer + 3
hCurSpriteBelowBG    EQU hCurSpriteBuffer + 4
hCurSpriteFlip       EQU hCurSpriteBuffer + 5
hCurSpriteFlags      EQU hCurSpriteBuffer + 6
hSpriteAnchorY   EQU $ff90
hSpriteAnchorX   EQU $ff91
hObjectX         EQU $ff92
hObjectY         EQU $ff93
hObjectFlags     EQU $ff94
hSpriteHidden    EQU $ff95
hSpriteListPtrHi EQU $ff96
hSpriteListPtrLo EQU $ff97

hLockdownStage  EQU $ff98
hGravityCounter EQU $ff99
hFallingSpeed   EQU $ff9a

hCollisionOccured_NeverRead EQU $ff9b

hBlinkCounter  EQU $ff9c

hLineCount EQU $ff9e

hBuffer               EQU $ffa0
hSavedIE              EQU $ffa1
hDelayCounter         EQU $ffa6
hFastDropDelayCounter EQU $ffa7

hLevel EQU $ffa9

hAutoFireCountdown EQU $ffaa

hNextNextPiece             EQU $ffae
hRandomnessPtrHi_NeverRead EQU $ffaf
hRandomnessPtrLo           EQU $ffb0

hCoordConversionY  EQU $ffb2
hCoordConversionX  EQU $ffb3
hCoordConversionLo EQU $ffb4
hCoordConversionHi EQU $ffb5

hOAMDMA EQU $ffb6 ; ends $ffbf, 10 bytes long

hGameType      EQU $ffc0
hMusicType     EQU $ffc1
hTypeALevel    EQU $ffc2
hTypeBLevel    EQU $ffc3
hTypeBHigh     EQU $ffc4
hMultiplayer   EQU $ffc5
hDemoCountdown EQU $ffc6

hHighscoreLettersEntered EQU $ffc6
hHighscoreEnterName      EQU $ffc7
hHighscorePosition       EQU $ffc8
hHighscoreNamePtrHi      EQU $ffc9
hHighscoreNamePtrLo      EQU $ffca

hMasterSlave     EQU $ffcb
hSerialDone      EQU $ffcc
hSerialState     EQU $ffcd
hSendBufferValid EQU $ffce
hSendBuffer      EQU $ffcf
hRecvBuffer      EQU $ffd0

; Used by DisplayBCD. The values can overlap because the latter is always cleared at the end of the
; routine, and the former is local to the subroutine.
hSeenNonZero EQU $ffe0
hScoreDirty  EQU $ffe0

hGameState        EQU $ffe1
hRowToShift       EQU $ffe3
hDemoNumber       EQU $ffe4
hFastDropDistance EQU $ffe5

hEnableHighscoreVBlank EQU $ffe8

hRecordDemo                 EQU $ffe9
hCountdownTillNextDemoInput EQU $ffea
hDemoPtrHi                  EQU $ffeb
hDemoPtrLo                  EQU $ffec
hLastDemoInput              EQU $ffed
hTrueInputDuringDemo        EQU $ffee

hMultiplayerNewMusic EQU $fff0
hStartAtLevel10      EQU $fff4

hFailedTetrominoPlacements EQU $fffb

hHighscorePtrHi EQU $fffb
hHighscorePtrLo EQU $fffc
