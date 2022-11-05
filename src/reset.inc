.macro INIT_NES
    sei                 ; disable all IRQ
    cld                 ; clear decimal mode (unsupported by NES)
    ldx #$FF            ;
    txs                 ; init stack pointer to end of stack (stack pointer holds low byte of stack pointer $01FF)

    inx                 ; rollover from FF to 00
    stx PPU_CTRL        ; disable NMI
    stx PPU_MASK        ; disable rendering
    stx $4010           ; disable DMC IRQ

    lda #$40
    sta $4017           ; disable APU frame IRQ

Wait1stVBlank:          ; wait for first VBLank
    bit PPU_STATUS
    bpl Wait1stVBlank

    txa                 ; a=0
ClearRAM:
    sta $0000,x         ; clear 0000-00FF
    sta $0100,x         ; clear 0100-01FF

    lda #$FF
    sta $0200,x         ; clear 0200-02FF

    lda #0
    sta $0300,x         ; clear 0300-03FF
    sta $0400,x         ; clear 0400-04FF
    sta $0500,x         ; clear 0500-05FF
    sta $0600,x         ; clear 0600-06FF
    sta $0700,x         ; clear 0700-07FF
    inx
    bne ClearRAM

Wait2ndVBlank:          ; wait for second VBLank
    bit PPU_STATUS
    bpl Wait2ndVBlank
.endmacro