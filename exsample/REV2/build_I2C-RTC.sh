#!/bin/bash -eu
rm -f *.hex *.lst *.p *.bin

asl -cpu z80 -L -D DS3231 -OLIST DS3231WR.lst -o DS3231WR.p I2C-RTC_WR.ASM
p2hex -r \$-\$ -F Intel DS3231WR.p
p2bin -r \$-\$ DS3231WR.p

asl -cpu z80 -L -D DS3231 -OLIST DS3231RD.lst -o DS3231RD.p I2C-RTC_RD.ASM
p2hex -r \$-\$ -F Intel DS3231RD.p
p2bin -r \$-\$ DS3231RD.p

asl -cpu z80 -L -D DS1307 -OLIST DS1307WR.lst -o DS1307WR.p I2C-RTC_WR.ASM
p2hex -r \$-\$ -F Intel DS1307WR.p
p2bin -r \$-\$ DS1307WR.p

asl -cpu z80 -L -D DS1307 -OLIST DS1307RD.lst -o DS1307RD.p I2C-RTC_RD.ASM
p2hex -r \$-\$ -F Intel DS1307RD.p
p2bin -r \$-\$ DS1307RD.p
