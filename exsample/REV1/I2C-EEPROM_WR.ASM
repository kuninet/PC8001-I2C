;
; I2C EEPROM WRITE for PC-8001
;      KUNI-NET 2020
;
        ORG     09000h
        JP      MAIN_START
;
EPROM_ADDR EQU 057h
;
; EEPROM PARM AREA
;
EEPROM_PARAM    EQU $  
RAM_START       DW 0000h
RAM_END         DW 00h
EEPROM_ADDR     DW 0000h
        org EEPROM_ADDR
EEPROM_ADDR_H   DS 1
EEPROM_ADDR_L   DS 1
;
EEPROM_BANK     DB 00h
;
EEPROM_NO       DB 00h
EEPROM_1st      EQU 01h
EEPROM_2nd      EQU 02h
;
RET_OK          EQU 00h
RET_ERR1        EQU 01h    ; PARAMETER ERROR 1
RET_ERR2        EQU 02h    ; PARAMETER ERROR 2
;
MAIN_START:
        PUSH HL  ; Parameter Pointer Save
        LD A,(HL)
        CP 3
        JP  S,ERR1END
        OR A
        JP NZ,ERR2END
        LD (EEPROM_NO),A
;
        CALL INI_LSI         ; 8255 PPI INIT  
        IFDEF EEPROM32k
          CALL EEPROM32k_ENABLE   ; EEPROM32k(DS3231 Board) Enable
        ENDIF
;
        IFDEF 
          CALL EEPROM2015_ENABLE   ; 24LC1025 Enable
        ENDIF
;
        CALL SDA_IN     ; SDA = H
        CALL RST_I2C    ; I2C BUS RESET
;
;
; RTC DATA WRITE
;
        CALL I2C_START
        LD A,EEPROM_ADDR
        CALL I2C_ctl_w  ; Slave Addr(W) Send
        LD A,(EEPROM_ADDR_H)
        CALL I2C_tx     ; EEPROM Address1 Send
        LD A,(EEPROM_ADDR_L)
        CALL I2C_tx     ; EEPROM Address2 Send
;
        LD HL,RAM_START
        LD BC,DATA_LEN
I2C_LOOP:
        PUSH BC
        LD   A,B
        OR   A
        JP   NZ,I2C_L_32SET
        LD   A,C
        CP   33
        JP   S,I2C_L_SET
;
I2C_L_32SET:
        LD   B,32
        JP   I2C_SEND_LOOP
I2C_L_SET
        LD   B,A
;
I2C_SEND_LOOP:
        LD   A,(HL)
        CALL I2C_tx
        INC HL
        DJNZ I2C_SEND_LOOP
;
        POP BC
        DEC BC
        LD  A,C
        CP  B
        JP  NZ,I2C_LOOP
;
        CALL I2C_STOP
;
        LD A,0         ; PROC OK
        JP PROC_END
;
ERR1END:
        LD A,RET_ERR1
        JP PROC_END
ERR2END:
        LD A,RET_ERR2
PROC_END:
        POP HL 
        LD (HL),A
        INC HL
        LD A,0
        LD (HL),A
        RET

;
TEST_DATA DB "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345"

        include "PPI8001_I2C.ASM"
