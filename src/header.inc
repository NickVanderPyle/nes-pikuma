; iNES Header 16 bytes
.segment "HEADER"
.byte $4E, $45, $53, $1A            ; NES newline
.byte $02                           ; 2x 16Kb (32Kb) PRG-ROM
.byte $01                           ; 1x 8Kb CHR-ROM
.byte %00000000                     ; flags: horiz mirroring, no battery, mirror 0
.byte %00000000                     ; flags: mapper 0, playchoice, nes2.0
.byte $00                           ; No PRG-RAM
.byte %00000000                     ; NTSC=0, PAL=1
.byte $00                           ; No PRG-RAM
.byte $00, $00, $00, $00, $00       ; Padding to fill 16bytes of header.
