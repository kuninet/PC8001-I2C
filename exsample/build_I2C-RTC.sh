#!/bin/bash -eu

asl -cpu z80 -L -D DS3231 -OLIST I2C-DS3231_WR.lst -o I2C-DS3231_WR.p I2C-RTC_WR.ASM
p2hex -r \$-\$ -F Intel I2C-DS3231_WR.p

asl -cpu z80 -L -D DS3231 -OLIST I2C-DS3231_RD.lst -o I2C-DS3231_RD.p I2C-RTC_RD.ASM
p2hex -r \$-\$ -F Intel I2C-DS3231_RD.p

asl -cpu z80 -L -D DS1307 -OLIST I2C-DS1307_WR.lst -o I2C-DS1307_WR.p I2C-RTC_WR.ASM
p2hex -r \$-\$ -F Intel I2C-DS1307_WR.p

asl -cpu z80 -L -D DS1307 -OLIST I2C-DS1307_RD.lst -o I2C-DS1307_RD.p I2C-RTC_RD.ASM
p2hex -r \$-\$ -F Intel I2C-DS1307_RD.p
