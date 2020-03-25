;
; I2C RTC(DS3231/1307) READ for PC-8001
;      KUNI-NET 2020
;            
RTC_ADDR EQU 68h
;
        ORG     9000h
        JP   MAIN_START
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
RTC_EDIT_DATA DB "                     "
;
;
MAIN_START:
        PUSH DE  ; String Descripter SAVE
;
        CALL INI_LSI         ; 8255 PPI INIT  
        IFDEF DS3231
          CALL DS3231_SEL   ; DS3132 RTC Module Enable
        ENDIF

        IFDEF DS1307
          CALL DS1307_SEL   ; DS1703 RTC Module Enable
        ENDIF
        
;
        CALL SDA_ON     ; SDA = H
        CALL RST_I2C
;
        CALL I2C_START
        LD A,RTC_ADDR
        CALL I2C_ctl_w  ; Slave Addr(W) Send
;
        LD A,0
        CALL I2C_tx
;
;Repeated Start Condition
;
        CALL SDA_OFF
        CALL SDA_ON
        CALL SCL_ON
        CALL I2C_START
;
; RTC DATA READ
;
        LD A,RTC_ADDR
        CALL I2C_ctl_r  ; Slave Addr(R) Send
;
        LD HL,RTC_DATA
        LD B,7
I2C_LOOP:
        PUSH BC
        CALL I2C_rx
        LD (HL),A
        INC HL
        POP BC
        DJNZ I2C_LOOP
        CALL I2C_STOP
;
        CALL EDIT_DT
;
; RETURN DATA SET
;
        POP DE
        LD  A,21
        LD  (DE),A
        LD  HL,RTC_EDIT_DATA
        INC DE
        LD  A,L
        LD  (DE),A
        INC DE
        LD  A,H
        LD  (DE),A
;
        RET
;
; DATE / TIME EDIT
;
EDIT_DT:
        LD  DE,RTC_EDIT_DATA
;
        LD A,(RTC_YEAR)
        CALL EDIT_2BCD
        LD A,'/'
        LD  (DE),A
        INC DE
;
        LD A,(RTC_MON)
        CALL EDIT_2BCD
        LD A,'/'
        LD  (DE),A
        INC DE
;
        LD A,(RTC_DAY_W)
        CALL EDIT_2BCD
;
        CALL EDIT_DAY
;
        LD A,(RTC_HOUR)
        CALL EDIT_2BCD
        LD A,':'
        LD  (DE),A
        INC DE
;
        LD A,(RTC_MIN)
        CALL EDIT_2BCD
        LD A,':'
        LD  (DE),A
        INC DE
;
        LD A,(RTC_SEC)
        CALL EDIT_2BCD
;
        RET
;
EDIT_2BCD:
        LD C,A
        SRA A
        SRA A
        SRA A
        SRA A
        ADD A,'0'
        LD  (DE),A
        INC DE
;
        LD A,C
        AND A,0Fh
        ADD A,'0'
        LD  (DE),A
        INC DE
;
        RET

EDIT_DAY:
        LD HL,YOBI
        LD A,(RTC_DAY)
        DEC A
        SLA A
        SLA A
        ADD A,L
        LD  L,A
        LD  A,0
        ADC A,H
        LD  H,A
;
        LD B,4
EDIT_DAY_L:
        LD A,(HL)
        LD  (DE),A
        INC DE
        INC HL
        DJNZ EDIT_DAY_L
        LD  A,' '
        LD  (DE),A
        INC DE
        RET
;
YOBI    DB " SUN MON TUE WED THU FRI SAT"

        include "NBASIC.ASM"
        include "PPI8001_I2C.ASM"
