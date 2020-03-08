#!/bin/bash -eu

asl -cpu z80 -L -D PIO -OLIST I2C-DS3231_WR.lst -o I2C-DS3231_WR.p I2C-DS3231_WR.ASM
p2hex -r \$-\$ -F Intel I2C-DS3231_WR.p

asl -cpu z80 -L -D PIO -OLIST I2C-DS3231_RD.lst -o I2C-DS3231_RD.p I2C-DS3231_RD.ASM
p2hex -r \$-\$ -F Intel I2C-DS3231_RD.p
