.z80

//Format hex to ASM db thing
//Find: [0-9A-Z][0-9A-Z]
//Replace: ,\$$&
//Replace example: xxxxxxxxx$&xxxxxxxxx

// Remove metadata from script dump
//                   "metadata": \{\r\n.*\r\n.*\r\n.*\r\n.*\r\n                  \},*\r\n

.open ".\roms\Tensai Bakabon (NEW).sms",0

.include ".\asm\gfx.asm"
.include ".\asm\vwf.asm"

// https://www.smspower.org/Development/ROMHeader#RegionCode0x7fff05Bytes
// Change region
org 0x7fff
	db 0x40

.close