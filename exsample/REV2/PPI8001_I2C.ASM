;**********************************************************************
; PC-8001 Software I2C DRIVER use 8255 PPI(REV2基板) 
;**********************************************************************

; PPI I/O Address EQU
;
PPI_A		equ 80h
PPI_B		equ 81h
PPI_C		equ 82h
PPI_CTL		equ 83h
;
SEL_DS1307	 equ	7
SEL_DS3231	 equ	6
SEL_24LC1025	 equ	5
SEL_EEPROM32k	 equ	4
;
SDA_HIGH	equ	00000011b
SDA_LOW		equ	00000010b
SCL_HIGH	equ	00000001b
SCL_LOW		equ	00000000b
;
PPI_INIT	equ 10001000b        ; Port C(High) = IN ,C(Low) = OUT, PortA/B = OUT
;
;--------------------------------------
; 8255 PPI INIT
;--------------------------------------
INI_LSI:
	; set Input Mode
	LD	A,PPI_INIT
	OUT	(PPI_CTL),A
	;
	RET
;--------------------------------------
; I2C DEVICE SELECT
;--------------------------------------
DS3231_SEL:
	IN	A,(PPI_B)
	AND	A,0f8h
	OR	A,SEL_DS3231
	OUT	(PPI_B),A
	RET
DS1307_SEL:
	IN	A,(PPI_B)
	AND	A,0f8h
	OR	A,SEL_DS1307
	OUT	(PPI_B),A
	RET
;
EEPROM1025_SEL:
	IN	A,(PPI_B)
	AND	A,0f8h
	OR	A,SEL_24LC1025
	OUT	(PPI_B),A
	RET
EEPROM32k_SEL:
	IN	A,(PPI_B)
	AND	A,0f8h
	OR	A,SEL_EEPROM32k
	OUT	(PPI_B),A
	RET
;--------------------------------------
; I2C Bus Reset
;--------------------------------------
RST_I2C:
	LD	B,0Ah
RST_I2C_L:
	CALL	SCL_CYCLE
	DJNZ	RST_I2C_L
	CALL	SCL_ON     ; SCL = H
	RET

;--------------------------------------
; I2C START/STOP
;--------------------------------------
I2C_START:
	CALL	SDA_OFF  ; SDA = L
	CALL	SCL_OFF  ; SCL = L
	RET


I2C_STOP:
	CALL	SDA_OFF  ; SDA = L
	CALL	SCL_ON   ; SCL = H
	CALL	SDA_ON	 ; SDA = H
	RET


;--------------------------------------
; I2C Transmit
;--------------------------------------
I2C_tx:
	CALL	SEND_BYTE
	BIT	5,D
	SCF
	RET Z
;
; ACK error
	CALL	I2C_STOP
	SCF
	CCF
	RET

;--------------------------------------
; I2C CONTROL (W)
;--------------------------------------
I2C_ctl_w:
	SLA A
	RES 0,A         ; I2C WRITE MODE
	CALL I2C_tx
	RET

;--------------------------------------
; I2C CONTROL (R)
;--------------------------------------
I2C_ctl_r:
	SLA A
	SET 0,A         ; I2C READ MODE
	CALL I2C_tx
	RET

;--------------------------------------
; I2C Receive
;--------------------------------------
I2C_rx:
	LD	B,8h
I2C_rx_L:
	IN	A,(PPI_C)
	SCF
	BIT	5,A
	JP 	NZ,I2C_rx_H_FOUND
I2C_rx_L_FOUND:
	CCF
I2C_rx_H_FOUND:
	RL	C
	CALL	SCL_CYCLE
	DJNZ    I2C_rx_L
;
	CALL  SEND_ACK
	LD	A,C
	RET

;=============================
; S U B R O U T I N E
;=============================
;--------------------------------------
; SEND ACK
;--------------------------------------
SEND_ACK:
	CALL	SCL_OFF
	CALL	SDA_OFF
	CALL	SCL_ON
	NOP
	NOP
	NOP
	NOP
	CALL	SCL_OFF
	CALL	SDA_ON
;
	RET
;--------------------------------------
; SCL_SYCLE
;--------------------------------------
SCL_CYCLE:
	CALL	SCL_OFF
	CALL	SCL_ON
	IN	A,(PPI_C)
	LD	D,A
	CALL	SCL_OFF
	RET

;--------------------------------------
; SDA_ON/OFF
;--------------------------------------
SDA_ON:
	LD  	A,SDA_HIGH
	OUT	(PPI_CTL),A
	RET

SDA_OFF:
	LD  	A,SDA_LOW
	OUT	(PPI_CTL),A
	RET

;--------------------------------------
; SCL_ON/OFF
;--------------------------------------
SCL_ON:
	LD  	A,SCL_HIGH
	OUT	(PPI_CTL),A
	RET

SCL_OFF:
	LD  	A,SCL_LOW
	OUT	(PPI_CTL),A
	RET

;--------------------------------------
; Send 1Byte
;--------------------------------------
SEND_BYTE:
	LD	B,8h
	LD	C,A
SEND_BYTE_L1:
	SLA	C
	JP	C,SEND_BYTE_SDA_H
SEND_BYTE_SDA_L:
	CALL	SDA_OFF
	JP	SEND_BYTE_L2
;
SEND_BYTE_SDA_H:
	CALL	SDA_ON
SEND_BYTE_L2:
	CALL	SCL_CYCLE
	DJNZ	SEND_BYTE_L1
	CALL	SDA_ON
	CALL	SCL_CYCLE
	RET
;
;


