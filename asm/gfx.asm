////////////////////////////////////////////////
// Font
////////////////////////////////////////////////

.org 0xC222
	FontPasswordScreenGfx:
	.incbin ".\graphics\compressed (new)\font - password.bin"

	
////////////////////////////////////////////////
// Shooter (Sprites)
////////////////////////////////////////////////
.org 0x0000E42D
	.incbin ".\graphics\compressed (new)\shootersprites.bin"
	
////////////////////////////////////////////////
// Shooter
////////////////////////////////////////////////

.org 0x00003C05
	.db ShooterGraphics
	.db (ShooterGraphics>>8)
.org 0x00003C0F
	.db ShooterGraphics
	.db (ShooterGraphics>>8)
.org 0x00003BFB
	.db SkyCastle1
	.db (SkyCastle1>>8)
.org 0x00003C19
	.db ShooterGraphics
	.db (ShooterGraphics>>8)	
.org 0x00003BF1
	.db SkyCastle2
	.db (SkyCastle2>>8)
	
////////////////////////////////////////////////
// Shooter (Tilemap)
////////////////////////////////////////////////

// "Only good kids can pass"
// おりこうさんは
// とうりやんせ
.org 0x15bd7
	db 0x30,0x01
	db 0x31,0x01 // Line 1
	db 0x30,0x01 // Line 2
	db 0x3C,0x01 // Line 2
	db 0x36,0x01 // Line 1
	db 0x37,0x01 // Line 1
	db 0x3F,0x01 // Line 2
	db 0x40,0x01 // Line 2
	db 0x38,0x01 // Line 1
	db 0x39,0x01 // Line 1
	db 0x41,0x01 // Line 2
	db 0x42,0x01 // Line 2
	db 0x3A,0x01 // Line 1
	db 0x3B,0x01 // Line 1
	db 0x32,0x01 // Line 2
	db 0x32,0x01 // Line 2
	
	db 0x30,0x01
	db 0x44,0x01 // Line 3
	db 0x3D,0x01
	db 0x3E,0x01
	db 0x45,0x01 // Line 3
	db 0x46,0x01 // Line 3
	db 0x3E,0x01
	db 0x3E,0x01
	db 0x32,0x01 // Line 3
	db 0x32,0x01 // Line 3
	db 0x3E,0x01
	db 0x3E,0x01
	db 0x32,0x01 // Line 3
	db 0x32,0x01 // Line 3
	db 0x3E,0x01
	db 0x3E,0x01
	
// Cost of donathan fries

.org 0x00015B5D
	db 0x32
	
.org 0x00015b7f
	db 0x30,0x01
	db 0x47,0x01 // Line 1
	db 0x30,0x01
	db 0x8F,0x01 // Line 2
	db 0x48,0x01 // Line 1
	db 0x49,0x01 // Line 1
	db 0x90,0x01 // Line 2
	db 0x91,0x01 // Line 2
	db 0x4A,0x01 // Line 1
	db 0x4B,0x01 // Line 1
	db 0x92,0x01 // Line 2
	db 0x93,0x01 // Line 2
	db 0x4C,0x01 // Line 1
	db 0x8C,0x01 // Line 1
	db 0x94,0x01 // Line 2
	db 0x95,0x01 // Line 2
	db 0x8D,0x01 // Line 1
	db 0x32,0x01 // Line 1
	db 0x32,0x01 // Line 2
	db 0x32,0x01 // Line 2
	db 0x30,0x01
	db 0X96,0x01 // Line 3
	db 0x3D,0x01
	db 0x3E,0x01
	db 0X97,0x01 // Line 3
	db 0X98,0x01 // Line 3
	db 0x3E,0x01
	db 0x3E,0x01
	db 0X99,0x01 // Line 3
	db 0X32,0x01 // Line 3
	db 0x3E,0x01
	db 0x3E,0x01
	db 0X32,0x01 // Line 3
	db 0X32,0x01 // Line 3
	db 0x3E,0x01
	db 0x3E,0x01
	db 0X32,0x01 // Line 3
	db 0X32,0x01 // Line 3
	db 0x3E,0x01
	db 0x3E,0x01
	
// Money
org 0x00015C4B
	db 0x32,0x01
	db 0x34,0x01
	db 0x30,0x01 // Price 1
	db 0x64,0x01 // Price 1
	
	db 0x3D,0x01
	db 0x3E,0x01
	db 0x65,0x01 // Price 1
	db 0x66,0x01 // Price 1
	
	db 0x3E,0x01
	db 0x3E,0x01
	db 0x30,0x01
	db 0x67,0x01 // Price 2
	
	db 0x3D,0x01
	db 0x3E,0x01
	db 0x68,0x01 // Price 2
	db 0x43,0x01 // Price 2
	
	db 0x3E,0x01
	db 0x3E,0x01
	db 0x9D,0x01 // Price 2/3
	db 0x34,0x01 // Price 2/3
	
	db 0x3E,0x01
	db 0x35,0x01
	db 0x30,0x01
	db 0x9A,0x01 // Price 3
	
	db 0x3D,0x01
	db 0x3E,0x01
	db 0x9B,0x01 // Price 3
	db 0x9C,0x01 // Price 3

////////////////////////////////////////////////
// Title
////////////////////////////////////////////////

.org 0x18000
	.incbin ".\graphics\compressed (new)\title.bin"

// relocate title graphics in VRAM to increase amount of tiles we can use.
.org 0x89B
	ld de,0x5620
	
// フジオ　プロダクション
// Fujio Productions

.org 0x0001917B
	.incbin ".\tilemap\compressed (new)\title.bin"

////////////////////////////////////////////////
// Talk Time
////////////////////////////////////////////////

// old location
.org 0x0002489D
	.fill 0x111

.org 0x0000060E
	ld hl,TalkTimeTilemap
.org 0x00000DD2
	ld hl,TalkTimeTilemap
.org 0x00000E2E
	ld hl,TalkTimeTilemap
.org 0x0000377A
	ld hl,TalkTimeTilemap

////////////////////////////////////////////////
// Overworld
////////////////////////////////////////////////

.org 0x20000
	.fill 0xC32
.org 0x20000
.headersize 0x8000-0x20000
	OverworldGraphics:
	.incbin ".\graphics\compressed (new)\overworld.bin"
.headersize 0x0

.org 0x00003B97
	.db OverworldGraphics
	.db (OverworldGraphics>>8)

// Tilemap adjust for cheap-estate sign
.org 0x0001584B
	.dh 0x01A0
	.dh 0x01A1
	.dh 0x05A0
	.dh 0x01A5
	
	.dh 0x01A2
	.dh 0x01A3
	.dh 0x01A6
	.dh 0x01A7
	
	.dh 0x01A4
	.dh 0x03A0
	.dh 0x01A8
	.dh 0x07A0
	
////////////////////////////////////////////////
// Underground MetaTiles
////////////////////////////////////////////////

org 0x00014E3C
	.fill 0x572
org 0x000031F9
	.db UndergroundMetatiles
	.db (UndergroundMetatiles>>8)
	
////////////////////////////////////////////////
// End Card
////////////////////////////////////////////////

org 0x00029FDF
	.fill 0x3E6
org 0x00029FDF
	.incbin ".\graphics\compressed (new)\endcard.bin"

////////////////////////////////////////////////
// Hajime Minigame
////////////////////////////////////////////////
org 0x000006D0
	ld hl,HajimeMinigame
org 0x000009C7
	ld hl,HajimeMinigame
org 0x00003733
	ld hl,HajimeMinigame
	
org 0x00025BBB
	.fill 0x270
	
////////////////////////////////////////////////
// Free Space
////////////////////////////////////////////////
	
.org 0x27A00
.headersize 0xAA00-0x26A00
	TalkTimeTilemap:
	.incbin ".\tilemap\compressed (new)\talktime.bin"
	
	HajimeMinigame:
	.incbin ".\graphics\compressed (new)\hajimegame.bin"
.headersize 0x0

////////////////////////////////////////////////
// End of bank space #1
////////////////////////////////////////////////

.org 0x0002208E
.headersize 0xA08E-0x0002208E
	ShooterGraphics:
	.incbin ".\graphics\compressed (new)\shooter.bin"
	SkyCastle1:
	.incbin ".\graphics\compressed (new)\skycastle1.bin"
	SkyCastle2:
	.incbin ".\graphics\compressed (new)\skycastle2.bin"
.headersize 0x0

////////////////////////////////////////////////
// End of bank space #2
////////////////////////////////////////////////

org 0x16cd0
.headersize 0xACD0-0x16cd0
	UndergroundMetatiles:
	.incbin ".\tilemap\compressed (new)\underground.bin"
.headersize 0x0
