INCLUDE "hardware.inc"

SECTION "STAT Interrupt", ROM0[$0048]
	call StatInt
	;call CheckInput
	ret

SECTION "Header", ROM0[$0100]
	jp Boot

/*
Header:
	db 0
	db NINTENDO_LOGO
	db "GDMA GUY       ", 0
	db CART_COMPATIBLE_GBC
	db 0, 0
	db CART_INDICATOR_GB
	db CART_ROM
	db CART_ROM_32KB
	db CART_SRAM_NONE
	db CART_DEST_JAPANESE
	db 0
	db 0
	db 0
	db 0, 0
*/

SECTION "Main", ROM0[$0150]
Boot:
	;Disable audio
	ld a, 0
	ldh [rNR52], a

WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank

	;Turn the LCD off
	ld a, 0
	ldh [rLCDC], a
	ld [wAnimIndex], a
	
DoubleSpeed:
	ld a, $30
	ldh [rP1], a
	ld a, 1
	ldh [rSPD], a
	stop
	
LoadPalettes:
	ld a, $C0
	ldh [rBCPS], a
	ld hl, BGPals
REPT 64
	ldi a, [hl]
	ldh [rBCPD], a
ENDR

LoadFont:
	ld de, Font
	ld hl, $9000
	ld c, 128
.load_pixels
REPT 16
	ld a, [de]
	ldi [hl], a
	inc de
ENDR
	dec c
	jr nz, .load_pixels
	

LoadTilemap:
	ld de, Tilemap
	ld hl, $9800
	ld bc, $1214
.load_tile
	ld a, [de]
	ldi [hl], a
	inc de
	dec c
	jr nz, .load_tile
	ld c, $14
	dec b
	push de
	ld de, $000C
	add hl, de
	pop de
	jr nz, .load_tile

Init:
	;Default setting does transfers during VBlank
	ei
	;STAT Interrupt will occur at VBlank start
	;ld a, 144
	ld a, 0
	ldh [rLYC], a
	;Turn the LCD back on
	ld a, LCDCF_ON
	ldh [rLCDC], a
	;Allow STAT interrupt to be a thing
	ld a, STATF_LYC
	ldh [rSTAT], a
	ld a, 2
	ld [rIE], a
	;Set joypad to use action buttons
	ld a, $10
	ldh [rP1], a
	
MainLoop:
	jp MainLoop
	
StatInt:
	push af
	push bc
	push de
	push hl
	ld a, [wAnimIndex]
	sla a
	sla a
	sla a
	set 6, a
	ldh [rHDMA1], a
	ld a, $00
	ldh [rHDMA2], a
	ld a, $88
	ldh [rHDMA3], a
	ld a, $00
	ldh [rHDMA4], a
	ld a, $7F
	ldh [rHDMA5], a
	;Increment animation index, check if need to reset it
	ld hl, wAnimIndex
	inc [hl]
	ld a, [hl]
	cp 8
	jr c, .return
	ld a, 0
	ld [hl], a
.return
	pop hl
	pop de
	pop bc
	pop af
	reti

/*
CheckInput:
	;Check if Select is pressed
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	bit 2, a
	ret nz
	ldh a, [rLYC]
	cp a, 144
	jr nz, .lyc_to_vblank
	ld a, 0
	ldh [rLYC], a
	ret
.lyc_to_vblank
	ld a, 144
	ldh [rLYC], a
	ret
*/

BGPals:
	dw $FFFF, $0000, $001F, $5B7F
	dw $FFFF, $4F9B, $001F, $0000
	dw $FFFF, $1F62, $1F0C, $0000
	dw $FFFF, $1F62, $1F0C, $0000
	dw $FFFF, $1F62, $1F0C, $0000
	dw $FFFF, $1F62, $1F0C, $0000
	dw $FFFF, $1F62, $1F0C, $0000
	dw $FFFF, $1F62, $1F0C, $0000

Tilemap:
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $10, $11, $12, $13, $14, $15, $16, $17
	db "      GDMA GUY      "
	db $20, $20, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F, $20, $20
	db $20, $20, $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E, $9F, $20, $20
	db $20, $20, $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF, $20, $20
	db $20, $20, $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF, $20, $20
	db $20, $20, $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF, $20, $20
	db $20, $20, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF, $20, $20
	db $20, $20, $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF, $20, $20
	db $20, $20, $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $20, $20
	db "  A hardware demo   "
	db "     by kkzero.     "
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	db "   The Guy should   "
	db " appear glitched on "
	db " hardware predating "
	db "    the GBA SP.     "
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20

Font:
INCBIN "font.2bpp"

SECTION "Guy Graphics", ROMX[$4000],BANK[1]
;INCBIN "testguy.2bpp"
INCBIN "./guy-anim/000.2bpp"
INCBIN "./guy-anim/001.2bpp"
INCBIN "./guy-anim/002.2bpp"
INCBIN "./guy-anim/003.2bpp"
INCBIN "./guy-anim/004.2bpp"
INCBIN "./guy-anim/005.2bpp"
INCBIN "./guy-anim/006.2bpp"
INCBIN "./guy-anim/007.2bpp"

SECTION "RAM", WRAM0[$C000]

wAnimIndex:
	ds 1