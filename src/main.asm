.include "../include/nes.inc"


.segment "HEADER"
  .byte $4E, $45, $53, $1A        ; iNES header identifier "NES", $1A
  .byte $02                       ; 2x 16KB PRG code
  .byte $01                       ; 1x  8KB CHR data
  .byte %00000001                 ; mapper 0, vertical mirroring
  .byte $00
  .byte $00
  .byte $00
  .byte $00
  .byte $00, $00, $00, $00, $00   ; filler


.segment "ZEROPAGE"


; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"
Reset:


.segment "VECTORS"
  ; When an NMI happens (once per frame if enabled) the label nmi:
  .addr NMI
  ; When the processor first turns on or is reset, it will jump to the label reset:
  .addr Reset


.segment "CHARS"


.segment "CODE"
