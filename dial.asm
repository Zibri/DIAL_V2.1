; ---------------------------------------------------------------------------
; Dial V2.1 by Zibri of RAMJAM (partially recovered source)
; ---------------------------------------------------------------------------
aDos:           dc.b 'DOS',0
                dc.l $B62801FA          ; bootloader checksum
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
; ---------------------------------------------------------------------------

boot_start:
                movem.l d0-a6,(dword_62000).l
                btst    #$A,(POTINP).l  ; if right mouse button pressed then normal boot
                beq.s   loc_1FC56
                btst    #6,(CIAA_PRA).l ; if left mouse button pressed then normal boot
                beq.s   loc_1FC56
                move.w  #2,$1C(a1)
                move.l  #$20000,$28(a1) ; load AT $20000
                move.l  #$1600,$24(a1)  ; read 4 sectors
                move.l  #$400,$2C(a1)   ; starting at sector 1
                movea.l (4).l,a6
                jsr     -$1C8(a6)
                jmp     prog_start
; ---------------------------------------------------------------------------

loc_1FC56:                              ; CODE XREF: ROM:0001FC1C↑j
                                        ; ROM:0001FC26↑j
                lea     aDosLibrary,a1  ; "dos.library"
                jsr     -$60(a6)
                tst.l   d0
                beq.s   loc_1FC6C
                movea.l d0,a0
                movea.l $16(a0),a0
                moveq   #0,d0

locret_1FC6A:                           ; CODE XREF: ROM:0001FC6E↓j
                rts                     ; normal boot
; ---------------------------------------------------------------------------

loc_1FC6C:                              ; CODE XREF: ROM:0001FC60↑j
                moveq   #$FFFFFFFF,d0
                bra.s   locret_1FC6A    ; normal boot
; ---------------------------------------------------------------------------
aDosLibrary:    dc.b 'dos.library',0    ; DATA XREF: ROM:loc_1FC56↑o
                dcb.b $384,0
; ---------------------------------------------------------------------------

prog_start:                             ; CODE XREF: ROM:0001FC50↑j
                movem.l d0-a6,-(sp)
                move.w  #9,$1C(a1)      ; motor off
                clr.l   $24(a1)
                jsr     -$1C8(a6)       ; DoIO
                movea.l (a6),a6
                movea.l (a6),a6
                move.l  a6,(Amiga_Base).l
                move.l  $32(a6),-(sp)
                move.w  #$A0,(DMACON).l
                lea     screen_init,a1  ; this is also screen related but I really don't remember
                move.l  a1,$32(a6)
                lea     ($70000).l,a1   ; clear memory from $70000

loc_20036:                              ; CODE XREF: ROM:0002003E↓j
                clr.l   (a1)+
                cmpa.l  #$7E000,a1      ; to $7E000
                bne.s   loc_20036
                movea.l (Amiga_Base).l,a6
                lea     (unk_41000).l,a0
                move.l  #1,d0
                move.l  #$300,d1
                move.l  #$C0,d2
                jsr     -$186(a6)       ; FindPort()
                move.l  #unk_70000,(dword_41008).l
                lea     (maybe_screen_buffer).l,a1
                jsr     -$C6(a6)        ; AllocMem
                move.l  #unk_41000,(dword_41104).l
                lea     (maybe_screen_buffer).l,a1
                move.w  #1,d0
                jsr     -$156(a6)
                movem.l d0-a6,(dword_60000).l ; until here is to initialize screen but I don't remember, really.
                bsr.w   PRINT_BANNER
                move.w  #$8380,(DMACON).l
                movea.l (4).l,a6

main_loop:                              ; CODE XREF: ROM:000200C2↓j
                bsr.w   INPUT_NUM
                movem.l d0-a6,-(sp)
                lea     TEL,a0
                adda.l  #(aTel+$B-$202AA),a0 ; "                    "
                bsr.w   parse_and_play_string
                movem.l (sp)+,d0-a6
                bra.s   main_loop

; =============== S U B R O U T I N E =======================================


print_at:                               ; CODE XREF: print+12↓p
                                        ; print+1C↓p
                lea     (maybe_screen_buffer).l,a1
                move.l  d3,d0
                move.l  d4,d1
                jsr     -$F0(a6)
                lea     (maybe_screen_buffer).l,a1
                movea.l a5,a0
                move.l  #$1F,d0
                jsr     -$3C(a6)
                rts
; End of function print_at

; ---------------------------------------------------------------------------
screen_init:    dc.b 1, 0, $22, 0, 1, 2, 0 ; DATA XREF: ROM:00020028↑o
                dcb.b 2,1               ; this is also screen related but I really don't remember
                dc.b 8
                dcb.b 2,0
                dc.b 1, $A
                dcb.b 3,0
                dc.b $92, 0, $20, 0, $94, 0, $D8, 0, $8E, $30
                dcb.b 2,0
                dc.b $90, $30, $FF, 0, $E0, 0, 7, 0, $E2, 8, $70, 0, $E4
                dc.b 0, 7, 0, $E6, 8, $A0, 1, $86, $A, $AA, 1, $84, $E
                dc.b $EE, 1, $82, 7, $77, 1, $80, 0, 6
                dcb.b 3,$FF
                dc.b $FE
aZibriOfRamjamP:dc.b '                                (   ZIBRI OF RAMJAM PRESENTS   '
                                        ; DATA XREF: PRINT_BANNER+10↓o
                dc.b ' 0   ========================    8                             '
                dc.b '  @          DIAL V2.1+           H                            '
                dc.b '   P      Type Gn, Sn or L0n       X                           '
                dc.b '    `  SPACE = REDIAL LAST NUMBER   h                          '
                dc.b '     p HELP = SHOW KEYS  DEL = SAVE  x                         '
                dc.b '      '
TEL:            dc.b $80                ; DATA XREF: ROM:000200B0↑o
                                        ; INPUT_NUM+4↓o ...
aTel:           dc.b '      TEL.:                    '
                                        ; DATA XREF: ROM:000200B4↑o
                dc.b $8A
                dc.b '                               ',0
                dc.b   0
aFunctionKeys:  dc.b '         FUNCTION KEYS          (                              '
                                        ; DATA XREF: PRINT_FUNKEY+10↓o
                dc.b ' 0     F1:                       8     F2:                     '
                dc.b '  @     F3:                       H     F4:                    '
                dc.b '   P     F5:                       X     F6:                   '
                dc.b '    `     F7:                       h     F8:                  '
                dc.b '     p     F9:                       x     FA:                 '
                dc.b '      '
                dc.b $80
                dc.b '                               '
                dc.b $8A
aLastNumber:    dc.b '  Last number:                 ',0
                                        ; DATA XREF: INPUT_NUM+236↓o
                                        ; INPUT_NUM+28A↓o
                dc.b   0
SAVED:          dc.b $8A                ; DATA XREF: PRINT_SAVED+10↓o
aSaved:         dc.b '            SAVED              ',0
                dc.b   0
NOT_SAVED:      dc.b $8A                ; DATA XREF: PRINT_NOT_SAVED+10↓o
aNotSaved:      dc.b '          NOT SAVED            ',0
                dc.b   0
input_buffer:   dcb.b 3,0               ; DATA XREF: INPUT_NUM+262↓o
                                        ; INPUT_NUM+29E↓o
                dc.b $C
                dcb.b 3,0
                dc.b $C
                dcb.b 3,0
                dc.b $C
                dcb.b 3,0
                dc.b $C
                dcb.b 3,0
                dc.b $C
                dcb.b 3,0
                dc.b $C
                dcb.b 3,0
                dc.b $C
                dcb.b 3,0
                dc.b $C
                dcb.b 3,0
                dc.b $C
                dcb.b 3,0
                dc.b $C
                dcb.b 3,0
                dc.b $C
                dcb.b 4,0

; =============== S U B R O U T I N E =======================================


INPUT_NUM:                              ; CODE XREF: ROM:main_loop↑p
                movem.l d0-a6,-(sp)
                lea     TEL,a1
                move.w  #$C,d1
                move.l  #$5F202020,(a1,d1.w) ; clear input and print cursor
                move.l  #$20202020,4(a1,d1.w)
                move.l  #$20202020,8(a1,d1.w)
                move.l  #$20202020,$C(a1,d1.w)
                move.l  #$20202020,$10(a1,d1.w)
                bsr.w   PRINT_TEL

input_loop:                             ; CODE XREF: INPUT_NUM+64↓j
                                        ; INPUT_NUM+CC↓j ...
                bsr.w   irq_clr
                cmpi.b  #$40,d0 ; '@'
                beq.w   loc_207A8
                cmpi.b  #$41,d0 ; 'A'
                bne.s   loc_20588
                cmpi.b  #$C,d1
                beq.s   loc_20588
                subi.b  #1,d1
                move.b  #$5F,(a1,d1.w) ; '_' ; add cursor
                move.b  #$20,1(a1,d1.w) ; ' ' ; add a space after cursor
                bsr.w   PRINT_TEL
                bra.s   input_loop
; ---------------------------------------------------------------------------

loc_20588:                              ; CODE XREF: INPUT_NUM+48↑j
                                        ; INPUT_NUM+4E↑j
                cmpi.b  #$46,d0 ; 'F'
                bne.s   loc_205FA

save_to_disk:
                movem.l d0-a6,(dword_63000).l
                movem.l (dword_62000).l,d0-a6
                move.w  #3,$1C(a1)
                move.l  #$20000,$28(a1)
                move.l  #$1600,$24(a1)  ; 4 sectors
                move.l  #$400,$2C(a1)   ; starting from first sector after the bootloader
                movea.l (4).l,a6
                jsr     -$1C8(a6)       ; write itself to first sector and 4 sectors starting at $20000
                move.l  d0,(write_status).l
                move.w  #9,$1C(a1)
                clr.l   $24(a1)
                jsr     -$1C8(a6)       ; motor stop
                movem.l (dword_63000).l,d0-a6
                tst.l   (write_status).l
                bne.s   loc_205F2
                bsr.w   PRINT_SAVED
                bra.w   input_loop
; ---------------------------------------------------------------------------

loc_205F2:                              ; CODE XREF: INPUT_NUM+C6↑j
                bsr.w   PRINT_NOT_SAVED
                bra.w   input_loop
; ---------------------------------------------------------------------------

loc_205FA:                              ; CODE XREF: INPUT_NUM+6A↑j
                cmpi.b  #$50,d0 ; 'P'
                blt.s   loc_20626
                cmpi.b  #$59,d0 ; 'Y'
                bgt.s   loc_20626
                subi.b  #$50,d0 ; 'P'
                move.l  d0,d4
                mulu.w  #$20,d0 ; ' '
                addi.b  #$A,d0
                lea     (aFunctionKeys+$40),a2 ; "0     F1:                       8     F"...
                adda.l  d0,a2
                cmpi.b  #$C,d1
                beq.w   loc_207B8
                bra.w   loc_20764
; ---------------------------------------------------------------------------

loc_20626:                              ; CODE XREF: INPUT_NUM+DC↑j
                                        ; INPUT_NUM+E2↑j
                cmpi.b  #$5F,d0 ; '_'
                bne.s   loc_20634
                bsr.w   PRINT_FUNKEY
                bra.w   input_loop
; ---------------------------------------------------------------------------

loc_20634:                              ; CODE XREF: INPUT_NUM+108↑j
                cmpi.b  #$44,d0 ; 'D'
                bne.s   loc_20646
                cmpi.b  #$C,d1
                beq.w   input_loop
                bra.w   loc_20754
; ---------------------------------------------------------------------------

loc_20646:                              ; CODE XREF: INPUT_NUM+116↑j
                cmpi.b  #$43,d0 ; 'C'
                bne.s   loc_20658
                cmpi.b  #$C,d1
                beq.w   input_loop
                bra.w   loc_20754
; ---------------------------------------------------------------------------

loc_20658:                              ; CODE XREF: INPUT_NUM+128↑j
                cmpi.b  #$1D,d1
                beq.w   input_loop
                cmpi.b  #$24,d0 ; '$'
                bne.s   loc_2066E
                move.b  #$47,d0 ; 'G'
                bra.w   loc_2073E
; ---------------------------------------------------------------------------

loc_2066E:                              ; CODE XREF: INPUT_NUM+142↑j
                cmpi.b  #$28,d0 ; '('
                bne.s   loc_2067C
                move.b  #$4C,d0 ; 'L'
                bra.w   loc_2073E
; ---------------------------------------------------------------------------

loc_2067C:                              ; CODE XREF: INPUT_NUM+150↑j
                cmpi.b  #$21,d0 ; '!'
                bne.s   loc_2068A
                move.b  #$53,d0 ; 'S'
                bra.w   loc_2073E
; ---------------------------------------------------------------------------

loc_2068A:                              ; CODE XREF: INPUT_NUM+15E↑j
                cmpi.b  #$31,d0 ; '1'
                bne.s   loc_20698
                move.b  #$5A,d0 ; 'Z'
                bra.w   loc_2073E
; ---------------------------------------------------------------------------

loc_20698:                              ; CODE XREF: INPUT_NUM+16C↑j
                cmpi.b  #$32,d0 ; '2'
                bne.s   loc_206A6
                move.b  #$58,d0 ; 'X'
                bra.w   loc_2073E
; ---------------------------------------------------------------------------

loc_206A6:                              ; CODE XREF: INPUT_NUM+17A↑j
                cmpi.b  #$A,d0
                bne.s   loc_206B4
                move.b  #$30,d0 ; '0'
                bra.w   loc_2073E
; ---------------------------------------------------------------------------

loc_206B4:                              ; CODE XREF: INPUT_NUM+188↑j
                cmpi.b  #$F,d0
                bne.s   loc_206C0
                move.b  #$30,d0 ; '0'
                bra.s   loc_2073E
; ---------------------------------------------------------------------------

loc_206C0:                              ; CODE XREF: INPUT_NUM+196↑j
                cmpi.b  #1,d0
                blt.s   loc_206D2
                cmpi.b  #9,d0
                bgt.s   loc_206D2
                addi.b  #$30,d0 ; '0'
                bra.s   loc_2073E
; ---------------------------------------------------------------------------

loc_206D2:                              ; CODE XREF: INPUT_NUM+1A2↑j
                                        ; INPUT_NUM+1A8↑j
                cmpi.b  #$3D,d0 ; '='
                bne.s   loc_206DE
                move.b  #$37,d0 ; '7'
                bra.s   loc_2073E
; ---------------------------------------------------------------------------

loc_206DE:                              ; CODE XREF: INPUT_NUM+1B4↑j
                cmpi.b  #$3E,d0 ; '>'
                bne.s   loc_206EA
                move.b  #$38,d0 ; '8'
                bra.s   loc_2073E
; ---------------------------------------------------------------------------

loc_206EA:                              ; CODE XREF: INPUT_NUM+1C0↑j
                cmpi.b  #$3F,d0 ; '?'
                bne.s   loc_206F6
                move.b  #$39,d0 ; '9'
                bra.s   loc_2073E
; ---------------------------------------------------------------------------

loc_206F6:                              ; CODE XREF: INPUT_NUM+1CC↑j
                cmpi.b  #$2D,d0 ; '-'
                bne.s   loc_20702
                move.b  #$34,d0 ; '4'
                bra.s   loc_2073E
; ---------------------------------------------------------------------------

loc_20702:                              ; CODE XREF: INPUT_NUM+1D8↑j
                cmpi.b  #$2E,d0 ; '.'
                bne.s   loc_2070E
                move.b  #$35,d0 ; '5'
                bra.s   loc_2073E
; ---------------------------------------------------------------------------

loc_2070E:                              ; CODE XREF: INPUT_NUM+1E4↑j
                cmpi.b  #$2F,d0 ; '/'
                bne.s   loc_2071A
                move.b  #$36,d0 ; '6'
                bra.s   loc_2073E
; ---------------------------------------------------------------------------

loc_2071A:                              ; CODE XREF: INPUT_NUM+1F0↑j
                cmpi.b  #$1D,d0
                bne.s   loc_20726
                move.b  #$31,d0 ; '1'
                bra.s   loc_2073E
; ---------------------------------------------------------------------------

loc_20726:                              ; CODE XREF: INPUT_NUM+1FC↑j
                cmpi.b  #$1E,d0
                bne.s   loc_20732
                move.b  #$32,d0 ; '2'
                bra.s   loc_2073E
; ---------------------------------------------------------------------------

loc_20732:                              ; CODE XREF: INPUT_NUM+208↑j
                cmpi.b  #$1F,d0
                bne.w   input_loop
                move.b  #$33,d0 ; '3'

loc_2073E:                              ; CODE XREF: INPUT_NUM+148↑j
                                        ; INPUT_NUM+156↑j ...
                move.b  d0,(a1,d1.w)
                move.b  #$5F,1(a1,d1.w) ; '_'
                bsr.w   PRINT_TEL
                addi.w  #1,d1
                bra.w   input_loop
; ---------------------------------------------------------------------------

loc_20754:                              ; CODE XREF: INPUT_NUM+120↑j
                                        ; INPUT_NUM+132↑j
                lea     $2048C,a2
                adda.l  #(aLastNumber+$F-$2048C),a2 ; "                "
                move.l  #$A,d4

loc_20764:                              ; CODE XREF: INPUT_NUM+100↑j
                mulu.w  #4,d4
                move.l  #$C,d3
                move.l  (a1,d3.w),(a2)
                move.l  4(a1,d3.w),4(a2)
                move.l  8(a1,d3.w),8(a2)
                move.l  $C(a1,d3.w),$C(a2)
                lea     input_buffer,a4
                move.l  d1,(a4,d4.w)

loc_2078C:                              ; CODE XREF: INPUT_NUM+2CE↓j
                move.b  #$20,(a1,d1.w) ; ' '
                move.b  #$20,-$C(a2,d1.w) ; ' '
                bsr.w   PRINT_TEL
                move.b  #$A,(a1,d1.w)
                movem.l (sp)+,d0-a6
                rts
; ---------------------------------------------------------------------------

loc_207A8:                              ; CODE XREF: INPUT_NUM+40↑j
                lea     $2048C,a2
                adda.l  #(aLastNumber+$F-$2048C),a2 ; "                "
                move.l  #$A,d4

loc_207B8:                              ; CODE XREF: INPUT_NUM+FC↑j
                mulu.w  #4,d4
                lea     TEL,a1
                lea     input_buffer,a4
                cmpi.l  #$C,(a4,d4.w)
                beq.w   input_loop
                move.l  #$C,d1
                move.l  (a2),(a1,d1.w)
                move.l  4(a2),4(a1,d1.w)
                move.l  8(a2),8(a1,d1.w)
                move.l  $C(a2),$C(a1,d1.w)
                move.l  (a4,d4.w),d1
                bra.s   loc_2078C
; End of function INPUT_NUM


; =============== S U B R O U T I N E =======================================


irq_clr:                                ; CODE XREF: INPUT_NUM:input_loop↑p
                                        ; irq_clr+14↓j ...
                clr.b   (unk_BFEC01).l
                clr.l   d0

wait_for_key:                           ; CODE XREF: irq_clr+E↓j
                move.b  (unk_BFEC01).l,d0
                beq.s   wait_for_key
                not.b   d0
                lsr.b   #1,d0
                bcs.s   irq_clr
                rts
; End of function irq_clr


; =============== S U B R O U T I N E =======================================


PRINT_BANNER:                           ; CODE XREF: ROM:00020096↑p
                                        ; PRINT_FUNKEY+22↓p
                movem.l d0-a6,(dword_61000).l
                movem.l (dword_60000).l,d0-a6
                lea     aZibriOfRamjamP,a5 ; "                                (   ZIB"...
                bsr.w   print
                movem.l (dword_61000).l,d0-a6
                rts
; End of function PRINT_BANNER


; =============== S U B R O U T I N E =======================================


PRINT_TEL:                              ; CODE XREF: INPUT_NUM+34↑p
                                        ; INPUT_NUM+60↑p ...
                movem.l d0-a6,(dword_61000).l
                movem.l (dword_60000).l,d0-a6
                lea     TEL,a5
                bsr.s   print
                movem.l (dword_61000).l,d0-a6
                rts
; End of function PRINT_TEL


; =============== S U B R O U T I N E =======================================


PRINT_SAVED:                            ; CODE XREF: INPUT_NUM+C8↑p
                movem.l d0-a6,(dword_61000).l
                movem.l (dword_60000).l,d0-a6
                lea     SAVED,a5
                bsr.s   print
                movem.l (dword_61000).l,d0-a6
                rts
; End of function PRINT_SAVED


; =============== S U B R O U T I N E =======================================


PRINT_NOT_SAVED:                        ; CODE XREF: INPUT_NUM:loc_205F2↑p
                movem.l d0-a6,(dword_61000).l
                movem.l (dword_60000).l,d0-a6
                lea     NOT_SAVED,a5
                bsr.s   print
                movem.l (dword_61000).l,d0-a6
                rts
; End of function PRINT_NOT_SAVED


; =============== S U B R O U T I N E =======================================


PRINT_FUNKEY:                           ; CODE XREF: INPUT_NUM+10A↑p
                movem.l d0-a6,(dword_61000).l
                movem.l (dword_60000).l,d0-a6
                lea     aFunctionKeys,a5 ; "         FUNCTION KEYS          (      "...
                bsr.s   print
                movem.l (dword_61000).l,d0-a6
                bsr.w   irq_clr
                bsr.w   PRINT_BANNER
                rts
; End of function PRINT_FUNKEY


; =============== S U B R O U T I N E =======================================


print:                                  ; CODE XREF: PRINT_BANNER+14↑p
                                        ; PRINT_TEL+14↑p ...
                lea     (maybe_screen_buffer).l,a1
                clr.l   d4
                move.l  #$32,d3 ; '2'
                move.b  (a5)+,d4
                beq.s   locret_208DC
                bsr.w   print_at
                addi.l  #$180,d3
                bsr.w   print_at
                adda.l  #$1F,a5
                bra.s   print
; ---------------------------------------------------------------------------

locret_208DC:                           ; CODE XREF: print+10↑j
                rts
; End of function print

; ---------------------------------------------------------------------------
aDosLibrary_0:  dc.b 'dos.library',0
                dc.b   0
                dc.b   0

; =============== S U B R O U T I N E =======================================


wait_d6_div_23:                         ; CODE XREF: j_wait_d6_div_23↓j
                divu.w  #$17,d6
; End of function wait_d6_div_23

; START OF FUNCTION CHUNK FOR wait_d6_frames

loc_208F0:                              ; CODE XREF: wait_d6_frames+A↓j
                move.b  (VHPOSR).l,d0
                addi.b  #1,d0
; END OF FUNCTION CHUNK FOR wait_d6_frames

; =============== S U B R O U T I N E =======================================


wait_d6_frames:                         ; CODE XREF: wait_d6_frames+6↓j
                                        ; play_2600_2400_and_2400+18↓p ...

; FUNCTION CHUNK AT 000208F0 SIZE 0000000A BYTES

                cmp.b   (VHPOSR).l,d0
                bne.s   wait_d6_frames  ; wait for next frame
                subq.w  #1,d6
                bne.s   loc_208F0
                rts
; End of function wait_d6_frames


; =============== S U B R O U T I N E =======================================


parse_and_play_string:                  ; CODE XREF: ROM:000200BA↑p
                cmpi.b  #$73,(a0) ; 's'
                beq.s   loc_2095A
                cmpi.b  #$53,(a0) ; 'S'
                beq.s   loc_2095A
                cmpi.b  #$67,(a0) ; 'g'
                beq.s   loc_20948
                cmpi.b  #$47,(a0) ; 'G'
                beq.s   loc_20948
                cmpi.b  #$6C,(a0) ; 'l'
                beq.s   loc_20948
                cmpi.b  #$4C,(a0) ; 'L'
                beq.s   loc_20948
                cmpi.b  #$7A,(a0) ; 'z'
                beq.s   loc_20948
                cmpi.b  #$5A,(a0) ; 'Z'
                beq.s   loc_20948
                cmpi.b  #$78,(a0) ; 'x'
                beq.s   loc_20948
                cmpi.b  #$58,(a0) ; 'X'
                beq.s   loc_20948

loc_20944:                              ; CODE XREF: parse_and_play_string+50↓j
                                        ; parse_and_play_string+DA↓j
                moveq   #0,d0
                rts
; ---------------------------------------------------------------------------

loc_20948:                              ; CODE XREF: parse_and_play_string+10↑j
                                        ; parse_and_play_string+16↑j ...
                lea     unk_20D50,a1
                moveq   #$1D,d0

loc_2094E:                              ; CODE XREF: parse_and_play_string+48↓j
                move.b  (a0)+,(a1)+
                dbf     d0,loc_2094E
                bsr.w   break_play_and_stop
                bra.s   loc_20944
; ---------------------------------------------------------------------------

loc_2095A:                              ; CODE XREF: parse_and_play_string+4↑j
                                        ; parse_and_play_string+A↑j
                lea     unk_20D50,a1
                moveq   #$1D,d0

loc_20960:                              ; CODE XREF: parse_and_play_string+5A↓j
                move.b  (a0)+,(a1)+
                dbf     d0,loc_20960
                tst.l   d6
                move.w  #$4000,(INTENA).l
                bset    #1,(CIAA_PRA).l
                lea     square_wave,a1
                move.l  a1,(AUD0LCH).l
                move.l  a1,(AUD1LCH).l
                move.l  a1,(AUD2LCH).l
                move.l  a1,(AUD3LCH).l
                move.w  #2,(AUD0LEN).l
                move.w  #2,(AUD1LEN).l
                move.w  #2,(AUD2LEN).l
                move.w  #2,(AUD3LEN).l
                lea     unk_20D51,a0
                cmpi.b  #$A,(a0)
                beq.s   loc_209D2
                moveq   #$29,d0 ; ')'

loc_209C0:                              ; CODE XREF: parse_and_play_string+C6↓j
                moveq   #0,d1
                move.b  (a0)+,d1
                cmpi.b  #$A,d1
                beq.s   loc_209D2
                bsr.w   PLAY_DTMF
                dbf     d0,loc_209C0

loc_209D2:                              ; CODE XREF: parse_and_play_string+B4↑j
                                        ; parse_and_play_string+C0↑j
                bclr    #1,(CIAA_PRA).l
                move.w  #$C000,(INTENA).l
                bra.w   loc_20944
; End of function parse_and_play_string


; =============== S U B R O U T I N E =======================================


break_play_and_stop:                    ; CODE XREF: parse_and_play_string+4C↑p
                tst.l   d6
                bsr.s   play_2600_2400_and_2400
                lea     unk_20D50,a0
                cmpi.b  #$A,(a0)
                beq.s   loc_20A1C
                move.l  #$61A80,d6
                bsr.w   j_wait_d6_div_23
                lea     unk_20D50,a0
                moveq   #$29,d0 ; ')'

loc_20A04:                              ; CODE XREF: break_play_and_stop+2C↓j
                moveq   #0,d1
                move.b  (a0)+,d1
                cmpi.b  #$A,d1
                beq.s   loc_20A16
                bsr.w   PLAY_MF
                dbf     d0,loc_20A04

loc_20A16:                              ; CODE XREF: break_play_and_stop+26↑j
                moveq   #$53,d1 ; 'S'
                bsr.w   PLAY_MF

loc_20A1C:                              ; CODE XREF: break_play_and_stop+C↑j
                bclr    #1,(CIAA_PRA).l
                move.w  #$C000,(INTENA).l

locret_20A2C:                           ; CODE XREF: PLAY_MF+E↓j
                                        ; PLAY_DTMF+E↓j
                rts
; End of function break_play_and_stop


; =============== S U B R O U T I N E =======================================


play_2600_2400_and_2400:                ; CODE XREF: break_play_and_stop+2↑p
                move.w  #$4000,(INTENA).l
                bset    #1,(CIAA_PRA).l
                move.l  #1,d6
                clr.l   d0
                bsr.w   wait_d6_frames
                lea     square_wave,a0
                move.l  a0,(AUD0LCH).l
                move.l  a0,(AUD1LCH).l
                move.l  a0,(AUD2LCH).l
                move.l  a0,(AUD3LCH).l
                move.w  #2,(AUD0LEN).l
                move.w  #2,(AUD1LEN).l
                move.w  #2,(AUD2LEN).l
                move.w  #2,(AUD3LEN).l
                move.w  #$800F,(DMACON).l ; start DMA (play)
                move.w  #$40,(AUD0VOL).l ; '@'
                move.w  #$40,(AUD1VOL).l ; '@'
                move.w  #$40,(AUD2VOL).l ; '@'
                move.w  #$40,(AUD3VOL).l ; '@'
                move.w  #$155,(AUD0PER).l
                move.w  #$171,(AUD1PER).l
                move.w  #$155,(AUD2PER).l
                move.w  #$171,(AUD3PER).l
                move.l  #$EA60,d6
                bsr.w   j_wait_d6_div_23
                move.w  #$F,(DMACON).l  ; stop DMA
                clr.w   (AUD0VOL).l
                clr.w   (AUD1VOL).l
                clr.w   (AUD2VOL).l
                clr.w   (AUD3VOL).l
                move.l  #$EA60,d6
                bsr.w   j_wait_d6_div_23
                move.w  #$800F,(DMACON).l ; start DMA (play)
                move.l  #1,d6
                clr.l   d0
                bsr.w   wait_d6_frames
                move.w  #$40,(AUD0VOL).l ; '@'
                move.w  #$40,(AUD1VOL).l ; '@'
                move.w  #$40,(AUD2VOL).l ; '@'
                move.w  #$40,(AUD3VOL).l ; '@'
                move.w  #$171,(AUD0PER).l
                move.w  #$171,(AUD1PER).l
                move.w  #$171,(AUD2PER).l
                move.w  #$171,(AUD3PER).l
                move.l  #$1A000,d6
                bsr.w   j_wait_d6_div_23
                move.w  #$F,(DMACON).l  ; stop DMA
                rts
; End of function play_2600_2400_and_2400


; =============== S U B R O U T I N E =======================================


PLAY_MF:                                ; CODE XREF: break_play_and_stop+28↑p
                                        ; break_play_and_stop+32↑p
                lea     a1234567890zxgl,a2 ; "1234567890ZXGLSzxgls"
                lea     MF_frequency_period_table,a3
                moveq   #0,d2

loc_20B74:                              ; CODE XREF: PLAY_MF+18↓j
                moveq   #0,d3
                move.b  (a2)+,d3
                beq.w   locret_20A2C
                cmp.b   d1,d3
                beq.s   loc_20B84
                addq.w  #1,d2
                bra.s   loc_20B74
; ---------------------------------------------------------------------------

loc_20B84:                              ; CODE XREF: PLAY_MF+14↑j
                asl.w   #2,d2
                move.w  #$800F,(DMACON).l
                move.l  #1,d6
                clr.l   d0
                bsr.w   wait_d6_frames
                move.w  #$20,(AUD0VOL).l ; ' '
                move.w  #$20,(AUD1VOL).l ; ' '
                move.w  #$20,(AUD2VOL).l ; ' '
                move.w  #$20,(AUD3VOL).l ; ' '
                move.w  (a3,d2.w),(AUD0PER).l
                move.w  2(a3,d2.w),(AUD1PER).l
                move.w  (a3,d2.w),(AUD2PER).l
                move.w  2(a3,d2.w),(AUD3PER).l
                move.l  #$7530,d6
                bsr.s   j_wait_d6_div_23
                clr.w   (AUD0VOL).l
                clr.w   (AUD1VOL).l
                clr.w   (AUD2VOL).l
                clr.w   (AUD3VOL).l
                move.w  #$F,(DMACON).l
                move.l  #$2710,d6
; End of function PLAY_MF

; [00000004 BYTES: COLLAPSED FUNCTION j_wait_d6_div_23. PRESS CTRL-NUMPAD+ TO EXPAND]

; =============== S U B R O U T I N E =======================================


PLAY_DTMF:                              ; CODE XREF: parse_and_play_string+C2↑p
                lea     a1234567890,a2  ; "1234567890"
                lea     DTMF_frequency_period_table,a3
                moveq   #0,d2

loc_20C16:                              ; CODE XREF: PLAY_DTMF+18↓j
                moveq   #0,d3
                move.b  (a2)+,d3
                beq.w   locret_20A2C
                cmp.b   d1,d3
                beq.s   loc_20C26
                addq.w  #1,d2
                bra.s   loc_20C16
; ---------------------------------------------------------------------------

loc_20C26:                              ; CODE XREF: PLAY_DTMF+14↑j
                asl.w   #2,d2
                move.w  #$800F,(DMACON).l
                move.l  #1,d6
                clr.l   d0
                bsr.w   wait_d6_frames
                move.w  #$40,(AUD0VOL).l ; '@'
                move.w  #$40,(AUD1VOL).l ; '@'
                move.w  #$40,(AUD2VOL).l ; '@'
                move.w  #$40,(AUD3VOL).l ; '@'
                move.w  (a3,d2.w),(AUD0PER).l
                move.w  2(a3,d2.w),(AUD1PER).l
                move.w  (a3,d2.w),(AUD2PER).l
                move.w  2(a3,d2.w),(AUD3PER).l
                move.l  #$9800,d6
                bsr.s   j_wait_d6_div_23
                clr.w   (AUD0VOL).l
                clr.w   (AUD1VOL).l
                clr.w   (AUD2VOL).l
                clr.w   (AUD3VOL).l
                move.w  #$F,(DMACON).l
                move.l  #$3000,d6
                bra.w   j_wait_d6_div_23
; End of function PLAY_DTMF

; ---------------------------------------------------------------------------
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
square_wave:    dc.l $7F0081            ; DATA XREF: parse_and_play_string+70↑o
                                        ; play_2600_2400_and_2400+1C↑o
a1234567890zxgl:dc.b '1234567890ZXGLSzxgls',0 ; DATA XREF: PLAY_MF↑o
                dc.b   0
MF_frequency_period_table:dc.w $3D9     ; DATA XREF: PLAY_MF+4↑o
                dc.w $4F3
                dc.w $326
                dc.w $4F3
                dc.w $326
                dc.w $3D9
                dc.w $2AA
                dc.w $4F3
                dc.w $2AA
                dc.w $3D9
                dc.w $2AA
                dc.w $326
                dc.w $24F
                dc.w $4F3
                dc.w $24F
                dc.w $3D9
                dc.w $24F
                dc.w $326
                dc.w $24F
                dc.w $2AA
                dc.w $209
                dc.w $4F3
                dc.w $209
                dc.w $3D9
                dc.w $209
                dc.w $2AA
                dc.w $209
                dc.w $326
                dc.w $209
                dc.w $24F
                dc.w $209
                dc.w $4F3
                dc.w $209
                dc.w $3D9
                dc.w $209
                dc.w $2AA
                dc.w $209
                dc.w $326
                dc.w $209
                dc.w $24F
a1234567890:    dc.b '1234567890',0     ; DATA XREF: PLAY_DTMF↑o
                dc.b   0
DTMF_frequency_period_table:dc.w $504   ; DATA XREF: PLAY_DTMF+4↑o
                dc.w $2E4
                dc.w $504
                dc.w $29E
                dc.w $504
                dc.w $25E
                dc.w $48A
                dc.w $2E4
                dc.w $48A
                dc.w $29E
                dc.w $48A
                dc.w $25E
                dc.w $41A
                dc.w $2E4
                dc.w $41A
                dc.w $29E
                dc.w $41A
                dc.w $25E
                dc.w $3B7
                dc.w $29E
unk_20D50:      dc.b   0                ; DATA XREF: parse_and_play_string:loc_20948↑o
                                        ; parse_and_play_string:loc_2095A↑o ...
unk_20D51:      dc.b   0                ; DATA XREF: parse_and_play_string+AC↑o
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b  $A
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b   0
                dc.b  $A
