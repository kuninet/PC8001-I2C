10 '%
20 '% I2C PC-8001 Driver for TL/1-PC
30 '%
40 'PROC INILSI,DEVSEL,DS1307SEL,DS3231SEL,EPROM32kSEL,EPROM1025SEL,RSTI2C,I2CSTART,I2CSTOP
50 '     ,I2CTX,I2CCTLW,I2CCTLR,SENDACK,SDAON,SDAOFF,SCLON,SCLOFF,PRINTDT
60 '     ,PRBCD
70 'FUNC I2CRX,SCLCYCLE,SENDBYTE,I2C8255RX,EDBCDH,EDBCDL
80 'VAR PPIA,PPIB,PPIC,PPICTL,DS1307,DS3231,EPROM1025,EPROM32k,SDAHIGH,SDALOW,SCLHIGH,SCLLOW,PPIINIT,DEVAD,RCNT,RECVC
90 'ARRAY RECVC[7],YOBI[20]
100 '% Main
110 'BEGIN
120 '  PPIA:=$80 PPIB:=$81 PPIC:=$82 PPICTL:=$83 
130 '  DS1307:=7 DS3231:=6 EPROM1025:=5 EPROM32k:=4
140 '  SDAHIGH:=$03 SDALOW:=$02 SCLHIGH:=$01 SCLLOW:=$00
150 '  PPIINIT:=$88
160 '  DEVAD:=$68
170 '  %---------------------
180 '  % INIT & ADDRESS WRITE
190 '  %---------------------
200 '  INILSI
210 '  DS1307SEL
220 '  SDAON RSTI2C
230 '  I2CSTART
240 '  I2CCTLW(DEVAD) I2CTX(0)
250 '  %---------------------
260 '  % REPEATED START
270 '  %---------------------
280 '  SDAOFF SDAON SCLON
290 '  I2CSTART
300 '  %---------------------
310 '  % RTC DATA READ
320 '  %---------------------
330 '  I2CCTLR(DEVAD)
340 '  FOR RCNT:=1 TO 7 DO
350 '    BEGIN
360 '      RECVC[RCNT]:=I2CRX
370 '    END
380 '  I2CSTOP
390 '  PRINTDT
400 'END
410 '
420 '%
430 '% PRINT DATE TIME
440 '%
450 'PRINTDT;VAR I
460 '  BEGIN
470 '    PRBCD(RECVC[7]) WRITE(0:"/") PRBCD(RECVC[6]) WRITE(0:"/") PRBCD(RECVC[5]) WRITE(0: " ")
480 '    CASE RECVC[4] OF
490 '      1 (WRITE(0:"SUN "))
500 '      2 (WRITE(0:"MON "))
510 '      3 (WRITE(0:"TUE "))
520 '      4 (WRITE(0:"WED "))
530 '      5 (WRITE(0:"THU "))
540 '      6 (WRITE(0:"FRI "))
550 '      7 (WRITE(0:"SAT "))
560 '      ELSE ( )
570 '    PRBCD(RECVC[3]) WRITE(0:":") PRBCD(RECVC[2]) WRITE(0:":") PRBCD(RECVC[1]) WRITE(0:CRLF)
580 '  END
590 '%
600 '% PRINT 2 BCD Digit
610 '%
620 'PRBCD(HDATA)
630 '  BEGIN
640 '    WRITE(0:ASCII(EDBCDH(HDATA)),ASCII(EDBCDL(HDATA)))
650 '  END
660 '%
670 '% EDIT HEX to BCD (High 4bit)
680 '%
690 'EDBCDH(HDATA)
700 '  BEGIN
710 '    RETURN ((HDATA/16) + '0')
720 '  END
730 '%
740 '% EDIT HEX to BCD (Low 4bit)
750 '%
760 'EDBCDL(HDATA)
770 '  BEGIN
780 '    RETURN ((HDATA AND $0F)+'0')
790 '  END
800 '........................................................
810 '%
820 '%  8255 PPI INIT
830 '%
840 'INILSI
850 '  BEGIN
860 '    PORT(PPICTL):=PPIINIT
870 '  END
880 '........................................................
890 '%
900 '%  I2C DEVICE SELECT
910 '%
920 'DEVSEL(DEV)
930 '  BEGIN
940 '    PORT(PPIB):=DEV
950 '  END
960 '............................
970 'DS1307SEL
980 '  BEGIN
990 '    DEVSEL(DS1307)
1000 '  END
1010 '............................
1020 'DS3231SEL
1030 '  BEGIN
1040 '    DEVSEL(DS3231)
1050 '  END
1060 '............................
1070 'EPROM32kSEL
1080 '  BEGIN
1090 '    DEVSEL(EPROM32k)
1100 '  END
1110 '............................
1120 'EPROM1025SEL
1130 '  BEGIN
1140 '    DEVSEL(EPROM1025)
1150 '  END
1160 '........................................................
1170 '%
1180 '%  I2C BUS RESET
1190 '%
1200 'RSTI2C;VAR I,ACK
1210 '  BEGIN
1220 '    FOR I:=1 TO 10 DO
1230 '	  BEGIN
1240 '	    ACK:=SCLCYCLE
1250 '	  END
1260 '    SCLON
1270 '  END
1280 '........................................................
1290 '%
1300 '%  I2C START/STOP
1310 '%
1320 'I2CSTART
1330 '  BEGIN
1340 '    SDAOFF
1350 '    SCLOFF
1360 '  END
1370 '............................
1380 'I2CSTOP
1390 '  BEGIN
1400 '    SDAOFF
1410 '    SCLON
1420 '    SDAON
1430 '  END
1440 '........................................................
1450 '%
1460 '%  I2C TRANSMIT
1470 '%
1480 'I2CTX(C);VAR ACK
1490 '  BEGIN
1500 '    ACK:=SENDBYTE(C)
1510 '    IF ACK=1 THEN I2CSTOP
1520 '  END
1530 '........................................................
1540 '%
1550 '%  I2C CTL WORD SEND(W)
1560 '%
1570 'I2CCTLW(AD)
1580 '  BEGIN
1590 '    AD:=(ASL(AD) OR $00)
1600 '    I2CTX(AD)
1610 '  END
1620 '............................
1630 '%
1640 '%  I2C CTL WORD SEND(R)
1650 '%
1660 'I2CCTLR(AD)
1670 '  BEGIN
1680 '    AD:=(ASL(AD) OR $01)
1690 '    I2CTX(AD)
1700 '  END
1710 '........................................................
1720 '%
1730 '%  I2C RECEIVE
1740 '%
1750 'I2CRX;VAR I,WKC,WKIN,ACK
1760 '  BEGIN
1770 '    WKC:=0
1780 '    FOR I:=1 TO 8 DO
1790 '	  BEGIN
1800 '	    WKC:=ASL(WKC)
1810 '      IF I2C8255RX THEN WKC:=(WKC OR $01)
1820 '      ACK:=SCLCYCLE
1830 '    END
1840 '    SENDACK
1850 '    RETURN WKC
1860 '  END
1870 '.........................
1880 'I2C8255RX;VAR WKIN
1890 '  BEGIN
1900 '    WKIN:=PORT(PPIC)
1910 '    WKIN:=(WKIN AND $20)
1920 '    IF WKIN=$20 THEN RETURN TRUE
1930 '                ELSE RETURN FALSE
1940 '  END
1950 '........................................................
1960 '%
1970 '%  I2C SEND ACK
1980 '%
1990 'SENDACK
2000 '  BEGIN
2010 '    SCLOFF
2020 '    SDAOFF
2030 '    SCLON
2040 '    SCLOFF
2050 '    SDAON
2060 '  END
2070 '........................................................
2080 '%
2090 '%  I2C SCL 1CYCLE
2100 '%
2110 'SCLCYCLE;VAR ACK
2120 '  BEGIN
2130 '    SCLOFF
2140 '    SCLON
2150 '    ACK:=PORT(PPIC)
2160 '    ACK:=(ACK AND $20)/$20
2170 '    SCLOFF
2180 '    RETURN ACK
2190 '  END
2200 '........................................................
2210 '%
2220 '%  I2C SDA ON/OFF
2230 '%
2240 'SDAON
2250 '  BEGIN
2260 '    PORT(PPICTL):=SDAHIGH
2270 '  END
2280 'SDAOFF
2290 '  BEGIN
2300 '    PORT(PPICTL):=SDALOW
2310 '  END
2320 '........................................................
2330 '%
2340 '%  I2C SCL ON/OFF
2350 '%
2360 'SCLON
2370 '  BEGIN
2380 '    PORT(PPICTL):=SCLHIGH
2390 '  END
2400 'SCLOFF
2410 '  BEGIN
2420 '    PORT(PPICTL):=SCLLOW
2430 '  END
2440 '........................................................
2450 '%
2460 '%  I2C SEND 1BYTE
2470 '%
2480 'SENDBYTE(C);VAR I,BITCHK,ACK
2490 '  BEGIN
2500 '    FOR I:=1 TO 8 DO
2510 '    BEGIN
2520 '      BITCHK:=(C AND $80)
2530 '      IF BITCHK=$80 THEN SDAON
2540 '                    ELSE SDAOFF
2550 '      C:=ASL(C)
2560 '      ACK:=SCLCYCLE
2570 '    END
2580 '    SDAON
2590 '    ACK:=SCLCYCLE
2600 '    RETURN ACK
2610 '  END
