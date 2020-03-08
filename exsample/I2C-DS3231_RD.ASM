;
; I2C RTC(DS3231/1307) READ for PC-8001
;      KUNI-NET 2020
;
;   START ADDRESS :
;     $9000 - DS3231
;     $9003 - DS1307
;            
RTC_ADDR EQU 68h
;
        ORG     9000h
        JP      DS3231_START
        JP      DS1307_START
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
;
DS1307_START:
        CALL INI_LSI         ; 8255 PPI INIT  
        CALL DS1307_ENABLE   ; DS1307 RTC Module Enable
        JP MAIN_START
;
DS3231_START:
        CALL INI_LSI         ; 8255 PPI INIT  
        CALL DS3231_ENABLE   ; DS3132 RTC Module Enable
;
MAIN_START:
        CALL SDA_IN     ; SDA = H
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
        CALL SDA_OUT
        CALL SDA_IN
        CALL SCL_IN
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
        CALL PRINT_DT
;
        RET
;
; DATE / TIME PRINT (for KZ80-Monitor)
;
PRINT_DT:
        LD A,(RTC_YEAR)
        CALL PRINT_2BCD
        LD A,'/'
        CALL cout
        LD A,(RTC_MON)
        CALL PRINT_2BCD
        LD A,'/'
        CALL cout
        LD A,(RTC_DAY_W)
        CALL PRINT_2BCD
;
        CALL PRINT_DAY
;
        LD A,(RTC_HOUR)
        CALL PRINT_2BCD
        LD A,':'
        CALL cout
        LD A,(RTC_MIN)
        CALL PRINT_2BCD
        LD A,':'
        CALL cout
        LD A,(RTC_SEC)
        CALL PRINT_2BCD
        LD A,0Dh
        CALL cout
        LD A,0Ah
        CALL cout
        RET
;
PRINT_2BCD:
        LD C,A
        SRA A
        SRA A
        SRA A
        SRA A
        ADD A,'0'
        CALL cout
;
        LD A,C
        AND A,0Fh
        ADD A,'0'
        CALL cout
;
        RET

PRINT_DAY:
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
PRINT_DAY_L:
        LD A,(HL)
        CALL cout
        INC HL
        DJNZ PRINT_DAY_L
        LD  A,' '
        CALL cout
        RET
;
YOBI    DB " SUN MON TUE WED THU FRI SAT"

        include "NBASIC.ASM"
        include "PPI8001_I2C.ASM"
