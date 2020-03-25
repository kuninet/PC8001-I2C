;**********************************************************************
; PC-8001 Software I2C DRIVER use 8255 PPI 
;**********************************************************************

; PPI I/O Address EQU
;
PPI_A		equ 80h
PPI_B		equ 81h
PPI_C		equ 82h
PPI_CTL		equ 83h
;
B_DS1307	 equ	0
B_DS3231	 equ	1
B_24LC1025	 equ	2
B_EEPROM32k	 equ	3
B_LATCH_SET      equ    7  ; 74HCT573 latch set H->L
;
PPI_INIT	equ 10001001b        ; Port C = IN , PortA/B = OUT
;
;--------------------------------------
; 8255 PPI INIT
;--------------------------------------
INI_LSI:
	; set Input Mode
	LD	A,PPI_INIT
	LD	(PPI_C_CONF),A
	OUT	(PPI_CTL),A
	;
	RET
;--------------------------------------
; I2C DEVICE SELECT
;--------------------------------------
DS3231_ENABLE:
	;  DS3231 Enable,DS1307 Disable
	IN	A,(PPI_A)
	SET	B_DS3231,A
	RES     B_DS1307,A
	SET     B_LATCH_SET,A
	OUT	(PPI_A),A
	RES     B_LATCH_SET,A
	OUT	(PPI_A),A
	RET
DS1307_ENABLE:
	;  DS1307 Enable,DS3231 Disable
	IN	A,(PPI_A)
	RES	B_DS3231,A
	SET     B_DS1307,A
	SET     B_LATCH_SET,A
	OUT	(PPI_A),A
	RES     B_LATCH_SET,A
	OUT	(PPI_A),A
	RET
DS3231_DISABLE:
	;  DS3132 Disable
	IN	A,(PPI_A)
	RES	B_DS3231,A
	SET     B_LATCH_SET,A
	OUT	(PPI_A),A
	RES     B_LATCH_SET,A
	OUT	(PPI_A),A
	RET
DS1307_DISABLE:
	;  DS3132 Disable
	IN	A,(PPI_A)
	RES	B_DS1307,A
	SET     B_LATCH_SET,A
	OUT	(PPI_A),A
	RES     B_LATCH_SET,A
	OUT	(PPI_A),A
	RET
;
EEPROM2015_ENABLE:
	;  24LC1025 Enable,EEPROM32k Disable
	IN	A,(PPI_A)
	SET	B_24LC1025,A
	RES     B_EEPROM32k,A
	SET     B_LATCH_SET,A
	OUT	(PPI_A),A
	RES     B_LATCH_SET,A
	OUT	(PPI_A),A
	RET
EEPROM32k_ENABLE:
	;  EEPROM32k Enable,24LC1025 Disable
	IN	A,(PPI_A)
	RES	B_24LC1025,A
	SET     B_EEPROM32k,A
	SET     B_LATCH_SET,A
	OUT	(PPI_A),A
	RES     B_LATCH_SET,A
	OUT	(PPI_A),A
	RET
EEPROM2015_DISABLE:
	;  EEPROM32k Disable
	IN	A,(PPI_A)
	RES	B_EEPROM32k,A
	SET     B_LATCH_SET,A
	OUT	(PPI_A),A
	RES     B_LATCH_SET,A
	OUT	(PPI_A),A
	RET
EEPROM1025_DISABLE:
	;  24LC1025 Disable
	IN	A,(PPI_A)
	RES	B_24LC1025,A
	SET     B_LATCH_SET,A
	OUT	(PPI_A),A
	RES     B_LATCH_SET,A
	OUT	(PPI_A),A
	RET
;--------------------------------------
; I2C Bus Reset
;--------------------------------------
RST_I2C:
	LD	B,0Ah
RST_I2C_L:
	CALL	SCL_CYCLE
	DJNZ	RST_I2C_L
	CALL	SCL_IN     ; SCL = H
	RET

;--------------------------------------
; I2C START/STOP
;--------------------------------------
I2C_START:
	CALL	SDA_OUT  ; SDA = L
	CALL	SCL_OUT  ; SCL = L
	RET


I2C_STOP:
	CALL	SDA_OUT  ; SDA = L
	CALL	SCL_IN   ; SCL = H
	CALL	SDA_IN	 ; SDA = H
	RET


;--------------------------------------
; I2C Transmit
;--------------------------------------
I2C_tx:
	CALL	SEND_BYTE
	BIT	4,D
	SCF
	RET Z
;
; ACK error
	CALL	I2C_STOP
	SCF
	CCF
	RET

;--------------------------------------
; I2C COLTROL (W)
;--------------------------------------
I2C_ctl_w:
	SLA A
	RES 0,A         ; I2C WRITE MODE
	CALL I2C_tx
	RET

;--------------------------------------
; I2C COLTROL (R)
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
	BIT	4,A
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
	CALL	SCL_OUT
	CALL	SDA_OUT
	CALL	SCL_IN
	NOP
	NOP
	NOP
	NOP
	CALL	SCL_OUT
	CALL	SDA_IN
;
	RET
;--------------------------------------
; SCL_SYCLE
;--------------------------------------
SCL_CYCLE:
	CALL	SCL_OUT
	CALL	SCL_IN
	IN	A,(PPI_C)
	LD	D,A
	CALL	SCL_OUT
	RET

;--------------------------------------
; SDA_IN/OUT
;--------------------------------------
SDA_IN:
	LD	A,(PPI_C_CONF)
	SET	3,A
	OUT	(PPI_CTL),A
	LD	(PPI_C_CONF),A
	RET

SDA_OUT:
	LD	A,(PPI_C_CONF)
	RES	3,A
	OUT	(PPI_CTL),A
	LD	(PPI_C_CONF),A
	RET

;--------------------------------------
; SCL_IN/OUT
;--------------------------------------
SCL_IN:
	LD	A,(PPI_C_CONF)
	SET	0,A
	OUT	(PPI_CTL),A
	LD	(PPI_C_CONF),A
	RET



SCL_OUT:
	LD	A,(PPI_C_CONF)
	RES	0,A
	OUT	(PPI_CTL),A
	LD	(PPI_C_CONF),A
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
	CALL	SDA_OUT
	JP	SEND_BYTE_L2
;
SEND_BYTE_SDA_H:
	CALL	SDA_IN
SEND_BYTE_L2:
	CALL	SCL_CYCLE
	DJNZ	SEND_BYTE_L1
	CALL	SDA_IN
	CALL	SCL_CYCLE
	RET
;
;
WORK_TOP	EQU	$
;
; Wok Area
;
PPI_C_CONF	DB  00h


