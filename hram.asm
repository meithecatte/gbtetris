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
hSpriteX         EQU $ff92
hSpriteY         EQU $ff93
hSpriteFlags     EQU $ff94
hSpriteHidden    EQU $ff95
hSpriteListPtrHi EQU $ff96
hSpriteListPtrLo EQU $ff97

hSavedIE        EQU $ffa1
hDelayCounter   EQU $ffa6
hDelayCounter2  EQU $ffa7

hOAMDMA EQU $ffb6 ; ends $ffbf, 10 bytes long

hGameType      EQU $ffc0
hMusicType     EQU $ffc1
hTypeALevel    EQU $ffc2
hTypeBLevel    EQU $ffc3
hTypeBHigh     EQU $ffc4
hMultiplayer   EQU $ffc5
hDemoCountdown EQU $ffc6

hMasterSlave     EQU $ffcb
hSerialDone      EQU $ffcc
hSerialState     EQU $ffcd
hSendBufferValid EQU $ffce
hSendBuffer      EQU $ffcf
hRecvBuffer      EQU $ffd0

hGameState     EQU $ffe1
hDemoNumber    EQU $ffe4

hMultiplayerNewMusic EQU $fff0
hStartAtLevel10      EQU $fff4
