;
; I2C RTC(DS3231) WRITE for PC-8001
;      KUNI-NET 2020
RTC_ADDR EQU 68h
;
        ORG     0A000h
        JP      MAIN_START
;
; RTC READ DATA WORK
;
RTC_DATA   EQU $  
RTC_SEC    DB 00h
RTC_MIN    DB 00h
RTC_HOUR   DB 00h
RTC_DAY    DB 00h
RTC_DAY_W  DB 00h
RTC_MON    DB 00h 
RTC_YEAR   DB 00h
;
; RETUEN CONSTANT
;
OK_STR DB "DATE/TIME SEND OK"
OK_LEN EQU $-OK_STR
;
ERR1_STR DB "ERR:TYPE MISS MATCH ERROR"
ERR1_LEN EQU $-ERR1_STR
;
ERR2_STR DB "ERR:PARAMETER LENGTH ERROR(<>14)"
ERR2_LEN EQU $-ERR2_STR
;
MAIN_START:
        PUSH DE
;
        CP 3
        JP NZ,ERR1END
        LD A,(DE)
        CP 14
        JP NZ,ERR2END
;
        CALL STR2BCD
;
        CALL INI_LSI         ; 8255 PPI INIT  
        IFDEF DS3231
          CALL DS3231_SEL   ; DS3132 RTC Module Enable
        ENDIF

        IFDEF DS1307
          CALL DS1307_SEL   ; DS3132 RTC Module Enable
        ENDIF

;
        CALL SDA_ON     ; SDA = H
        CALL RST_I2C
;
;
; RTC DATA WRITE
;
        CALL I2C_START
        LD A,RTC_ADDR
        CALL I2C_ctl_w  ; Slave Addr(W) Send
        LD A,0
        CALL I2C_tx     ; Reister Address Send
;
        LD HL,RTC_DATA
        LD B,7
I2C_LOOP:
        PUSH BC
        LD   A,(HL)
        CALL I2C_tx
        INC HL
        POP BC
        DJNZ I2C_LOOP
;
        CALL I2C_STOP
        LD HL,OK_STR
        LD A,OK_LEN
        JP PROC_END
; 
; Error Exit 
ERR1END:
        LD HL,ERR1_STR
        LD A,ERR1_LEN
        JP PROC_END
ERR2END:
        LD HL,ERR2_STR
        LD A,ERR2_LEN
; 
; Exit Routine (String Descripter Set) 
PROC_END:
        POP DE        
        LD (DE),A
        INC DE
        LD A,L
        LD (DE),A
        INC DE
        LD A,H
        LD (DE),A
        RET
;-----------------------------
; DATE/TIME String to BCD
;-----------------------------
STR2BCD:
        LD B,A
        SRA B
;
        INC DE
        LD A,(DE)
        LD L,A
        INC DE
        LD A,(DE)
        LD H,A
        LD DE,RTC_YEAR
;
STR2BSD_LOOP:
        LD A,(HL)
        SUB '0'
        CP  10
        JP  S,STR2BCD_SKIP
        LD  A,00
STR2BCD_SKIP:
        SLA A
        SLA A
        SLA A
        SLA A
        LD C,A
;
        INC HL
        LD A,(HL)
        SUB '0'
        CP  10
        JP  S,STR2BCD_SKIP2
        LD  A,00
STR2BCD_SKIP2:
        ADD A,C
        LD (DE),A
        DEC DE
        INC HL
        DJNZ STR2BSD_LOOP 
        RET     

;
        include "PPI8001_I2C.ASM"
