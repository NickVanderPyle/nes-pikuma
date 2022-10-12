; iNES Header 16 bytes
.segment "HEADER"
.org $7FF0                          ; 16bytes prior to CODE
.byte $4E, $45, $53, $1A            ; NES newline
.byte $02                           ; 2x 16Kb (32Kb) PRG-ROM
.byte $01                           ; 1x 8Kb CHR-ROM
.byte %00000000                     ; flags: horiz mirroring, no battery, mirror 0
.byte %00000000                     ; flags: mapper 0, playchoice, nes2.0
.byte $00                           ; No PRG-RAM
.byte %00000000                     ; NTSC=0, PAL=1
.byte $00                           ; No PRG-RAM
.byte $00, $00, $00, $00, $00       ; Padding to fill 16bytes of header.


.segment "CODE"
.org $8000

RESET:
    sei                 ; disable all IRQ
    cld                 ; clear decimal mode (unsupported by NES)
    ldx #$FF            ;
    txs                 ; init stack pointer to end of stack (stack pointer holds low byte of stack pointer $01FF)

    ; loop all memory to zero out.
    lda #0              ; a=0
    ldx #0              ; x=0
MemLoop:
    sta $0,x            ; store a into $00+x
    dex
    bne MemLoop         ; if x != 0, then loop

NMI:
    rti

IRQ:
    rti


.segment "VECTORS"
.org $FFFA
.word NMI
.word RESET
.word IRQ