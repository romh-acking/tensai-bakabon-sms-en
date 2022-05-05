// Repurpose old dialogue decompression buffer for our VWF RAM addresses
Width							equ 0xC7D0

VramTileStart					equ Width+0x2
VramTileMapStart				equ 0xC115

GFXIndexer						equ VramTileStart+0x2
FontWidth						equ GFXIndexer+0x2
Tile1Buffer						equ FontWidth+0x2
Tile2Buffer						equ Tile1Buffer+0x8

CharToWrite						equ 0xC13F

Port_VDPData					equ	0xBE
Port_VDPAddress					equ	0xBF

CurrentTileId					equ Tile2Buffer+0x8

NotNPCVRAMLineNo				equ CurrentTileId+0x2
NPCVRAMLineNo					equ NotNPCVRAMLineNo+0x2

// For miscellaneous text where there's an unlimted amount of lines
// that we don't need to worry about swaping locations
MiscTilemapStart				equ NPCVRAMLineNo+0x2

MoneyTextBuffer					equ MiscTilemapStart+0x2

// Voice sample skip a la Metal Slader Glory translation
VoiceSkip						equ MoneyTextBuffer+0x2

// Use to indicate if we're still writing a line. Triggers linebreaks and whatnot.
IsStillWriting					equ 0xC114

// Consts
TileHeight						equ 0x8

NameCardTileIdStart				equ 0x0002
NameCardVRAMStart				equ 0x0040
NameCardTileMapStart 			equ 0x7CE8+0x40

NPCTileIdStartLine1				equ 0x0013
NPCVRAMStartLine1				equ 0x0260

NPCTileIdStartLine2				equ NPCTileIdStartLine1+0xC
NPCVRAMStartLine2				equ NPCVRAMStartLine1+0x180

NotNPCTileIdStartLine1			equ NPCTileIdStartLine2+0xC
NotNPCVRAMStartLine1			equ NPCVRAMStartLine2+0x180

NotNPCTileIdStartLine2			equ NotNPCTileIdStartLine1+0xC
NotNPCVRAMStartLine2			equ NotNPCVRAMStartLine1+0x180

// The tile id itself
MoneyTileIdStart				equ NotNPCTileIdStartLine2+0xC
// Where the tile GFX starts in VRAM
MoneyVRAMStart					equ NotNPCVRAMStartLine2+0x180

// The tile id itself
CustomTileIdStart				equ MoneyTileIdStart+0x5
// Where the tile GFX starts in VRAM
CustomVRAMStart					equ MoneyVRAMStart+0xA0

DialogueDecompressionBuffer		equ 0xDEE0

MoneyStart						equ 0xC0A6

// Points to some random slot with a bunch of zeros.
SmallBlankingText				equ	0x10A9

LineBreakControlCode			equ	0xFF
DelimeterControlCode			equ	0x00

TextSpeed						equ 0x2

.headersize 0x0
.org 0x000039CC
	.fill 0x22
	
.org 0x0000109E
	.fill 0xA5

.org 0x0000109E
	ld iy,0x03
	ld (0xFFFF),iy
	jp PrintDialogue
	
.org 0x00001064
	.fill 0x16
.org 0x00001064
	ld a,0x03
	ld (0xFFFF),a
	jp SetupDialoguePrint1

.org 0x000037EC
	call SetupDialoguePrint2
	
	
////////////////////////////////////////////////
// Increase Text Speed
////////////////////////////////////////////////
org 0x00001080
	ld a,TextSpeed
	
.org 0x0000F300
.headersize 0xB300-0xF300

////////////////////////////////////////////////
// Font Metadata
////////////////////////////////////////////////

	VWFFont:
		.incbin ".\asm\vwf font.bin"

	VWFWidths:
		db 0x8,0x4,0x5,0x5,0x6,0x7,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6
		db 0x3,0x6,0x7,0x6,0x6,0x3,0x3,0x5,0x3,0x3,0x3,0x7,0x7,0x7,0x7,0x7
		db 0x7,0x7,0x7,0x5,0x4,0x7,0x7,0x8,0x7,0x7,0x7,0x7,0x7,0x7,0x7,0x7
		db 0x7,0x8,0x7,0x7,0x7,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x6,0x3,0x4,0x6
		db 0x3,0x8,0x6,0x6,0x6,0x6,0x5,0x6,0x5,0x6,0x6,0x8,0x6,0x6,0x6,0x4
		db 0x7,0x5,0x7
		
		// Space
		db 0x5
		
		// For padding money amount
		db 0x5
		
		// For "Fight" text's border
		db 0x5
		
		// For money counter
		db 0x5,0x5,0x5,0x5,0x5,0x5,0x5,0x5,0x5,0x5
		// Yen
		db 0x5
		
////////////////////////////////////////////////
// Namecard specific
////////////////////////////////////////////////
	
	WriteNamecardFunc:
		// Disable interrupts to prevent register values from getting thrown off (to prevent us from printing garbage).
		// I assume this is done for the dialogue and namecards as well.
		// But better to be safe than sorry.
		di
		ld a,0x01
		ld (IsStillWriting), a
		
		ld de,(VramTileMapStart)
		ld (MiscTilemapStart),de
		
		ld de,NameCardTileIdStart
		ld (CurrentTileId),de
		
		ld hl,NameCardVRAMStart
		dec hl
		ld (VramTileStart),hl
		
		ld de,0x0000
		ld (Width),de
		
		WriteNamecardLoop:
			call WriteLineLoop
			ld a, (IsStillWriting)
			or a
			jr nz,WriteNamecardLoop
		
		call ResetTileBuffer
		ei
		ret

////////////////////////////////////////////////
// General
////////////////////////////////////////////////
	
	WriteLineLoop:
		ld a, (IsStillWriting)
		or a
		ret z
		
		ld hl,(0xC117)
		ld a,(hl)
		or a
		
		jr nz,PrintVWFChar
		ld (IsStillWriting), a
		ret
	
	PrintVWFChar:
		ld (CharToWrite), a
			
		call NamecardLineBreakControlCode
		inc hl
		ld (0xC117), hl
		ret
		
	NamecardLineBreakControlCode:
		cp 0xFF
		jr nz,NotControlCode
		
		push hl
		// Set VDP Address to next line
		
		ld a,(Width)
		cp 0x0
		jp z,ResetTileBufferZeroWidth
			call ResetTileBuffer
			ld a,0x0
			ld (Width),a
			
			// Move to the next tile
			ld hl,(CurrentTileId)
			inc hl
			ld (CurrentTileId),hl
			
			ld hl,(VramTileStart)
			ld bc,0x20
			add hl,bc
			ld (VramTileStart),hl
		
		ResetTileBufferZeroWidth:
			ld hl,(MiscTilemapStart)
			ld bc,0x40
			add hl,bc
			ld (MiscTilemapStart),hl
			ld (VramTileMapStart),hl
			
			pop hl
			ret
		
		NotControlCode:
			// Actually print char
			//call 0x39EE	
			call PrintCharacter
			ret
			

	// ix:	Tile1Buffer
	// iy:	Tile1Buffer
	// c: 	Character width
	// b: 	current row of font gfx indexer
	// 
	PrintCharacter:
		push af
		push bc
		push de
		push hl
		push ix
		push iy
		
		ld b,TileHeight
				
		// Set up font gfx indexing
		ld hl,(CharToWrite)
		add hl,hl
		add hl,hl
		add hl,hl
		ld de,VWFFont
		add hl,de
		ld (GFXIndexer),hl
		
		// Get the width of the font
		ld hl,(CharToWrite)
		ld de,VWFWidths
		add hl,de
		ld c,(hl)
		ld b,0x0
		ld (FontWidth),bc
		
		ld b,TileHeight
		
		// Set up indexer
		ld iy,Tile1Buffer

		PrintCharacterLoop:
			push bc
			
			// Write the left part of the graphic
			ld bc,(Width)
			
			ld de,(GFXIndexer)
			ld a,(de)
			ld h,a
			ld l,0x0
			
			ld a,c
			cp 0x0
			jp z,ShiftRightExit
			
			ShiftRightLoop:
				srl h
				rr l
				dec a
				jp nz,ShiftRightLoop
			
			ShiftRightExit:	
			
			// The left part of the font
			ld a,h
			or (iy)
			ld (iy),a
			
			// The right part of the font that goes into the next tile.
			ld a,l
			or (iy+8)
			ld (iy+8),a
			
			inc de
			ld (GFXIndexer),de
			
			inc hl
			inc iy
			
			pop bc
			dec b
			jp nz,PrintCharacterLoop
		
		ld hl,(FontWidth)
		ld bc,(Width)
		add hl,bc
		ld (Width),hl
		
		call WriteCharToVRAM
		
		pop iy
		pop ix
		pop hl
		pop de
		pop bc
		pop af
		
		ret
	
	// Convert 1BPP to 4BPP
	// The game requires the graphics to be store
	// as black on white 
	// So:
	// Index 0: white
	// index 1: black
	// index 3: 00
	// index 4: 00
	WriteCharToVRAM:
		ld iy,Tile1Buffer
		
		call WriteChar
		
		// Move tiledata in buffers if we've exceeded a width of 8
		ld a,(Width)
		cp 0x9
		jp c,WriteSecondTileExit
		
		WriteSecondTile:
		
			// Move to the next tile
			ld hl,(VramTileStart)
			ld bc,0x20
			add hl,bc
			ld (VramTileStart),hl
		
			call WriteChar
			call MoveToNextTileBuffer
			
			ld a,(Width)
			sub 0x08
			ld (Width),a
			
			call WriteTile
			
			ld de,(CurrentTileId)
			inc de
			ld (CurrentTileId),de
				
			ld de, (VramTileMapStart)
			inc e
			inc e
			ld (VramTileMapStart),de
			
		WriteSecondTileExit:
		call WriteTile
		
		QuickExit:
		ret
		
	MoveToNextTileBuffer:
		// Switch Tile2Buffer with Tile1Buffer if width is 8 or more.
		// Also blank Tile2Buffer in the process
		ld iy,Tile1Buffer
		ld b,0x8
			
		MoveTilemapLoop:
			ld a,(iy+8)
			ld (iy+0),a
			ld (iy+8),0x0
			inc iy
			dec b
		jp nz,MoveTilemapLoop
		ret
		
	WriteTile:
		ld de,(VramTileMapStart)
		ld a,e
		out (Port_VDPAddress),a		
		ld a,d
		out (Port_VDPAddress),a
		
		ld de,(CurrentTileId)
		ld a,e
		inc hl
		out (Port_VDPData),a
		
		push af			; WAIT 15 CLOCK
		pop af			; WAIT 14 CLOCK    TOTAL 29 CLOCK
		
		ld a,d
		out (Port_VDPData),a
		
		push af			; WAIT 15 CLOCK
		pop af			; WAIT 14 CLOCK    TOTAL 29 CLOCK
		ret
	
	// Write the font tile data and tilemap to VRAM.
	WriteChar:
		ld de,(VramTileStart)
		
		// Set up place to write the graphics
		ld a,e
		out (Port_VDPAddress),a		
		ld a,d
		out (Port_VDPAddress),a		
		ld b,0x8
		
		// Write GFX to VRAM
		
		// A delay time is necessary for the CPU to read data from the VRAM. A wait of at least 28 clock pulses is necessary during the first third-byte transfer after the completion of address setting prior to a read operation (this is slightly different to the case of a write operation to the VRAM). 
		// https://www.smspower.org/Development/GGOfficialDocs#DReadingFromVRAM
		
		WriteCharToVRAMLoop:
			ld a,(iy+0)
			xor 0xFF
			inc hl
			out (Port_VDPData),a
			
			push af			; WAIT 15 CLOCK
			pop af			; WAIT 14 CLOCK    TOTAL 29 CLOCK
			
			ld a,(iy+0)
			out (Port_VDPData),a
			
			push af
			pop af
			
			ld a,0x0
			out (Port_VDPData),a
			
			push af
			pop af
			
			ld a,0x0
			out (Port_VDPData),a
		
			push af			; WAIT 15 CLOCK
			pop af			; WAIT 14 CLOCK    TOTAL 29 CLOCK
			
			inc iy
			dec b
			jp nz,WriteCharToVRAMLoop		
		ret
		
////////////////////////////////////////////////
// Dialogue
////////////////////////////////////////////////
	
	// Pre-existing code from the game for printing dialogue.
	// Since there's so much free space, it's convient to relocate 
	// a lot of code here and modify it freely.
	// In retrospect, this is kind of overkill
	// as not many changes were made to it, but I didn't
	// know how many changes I would make at the time.
	PrintDialogue:		
		ld a, (0xC19A)
		or a
		jr z, LABEL_109E_a
		
		ld hl, 0xC199
		dec (hl)
		jp nz, 0x7C9
		ld (hl), 0x04
		call 0x158C
		ld hl, 0xC19A
		dec (hl)
		jp nz, 0x7C9
		ld a, 0x01
		ld (IsStillWriting), a
		
	LABEL_109E_a:	
		ld a, (0xC197)
		ld b, a
		ld a, (IsStillWriting)
		or b
		jr z, LABEL_111C
		
		// Controls text speed
		// Dummying out these three lines shows off
		// how fast the VWF code is, but it's a bit too much
		ld hl, 0xC19B
		dec (hl)
		jp nz, 0x7C9
		
		ld (hl), TextSpeed
		call WriteLineLoop
		
		ld a, (0xC13F)
		cp 0x27
		jr z, LABEL_109E_b
		
		ld a, (0xC18F)
		or a
		jr nz, LABEL_109E_b
		
		ld a, (0xC19E)
		or a
		ld a, 0x00
		ld (0xC19E), a
		jr nz, LABEL_109E_b
		
		
		ld a,(VoiceSkip)
		inc a
		ld (VoiceSkip),a
		and 0x1
		cp 0x1
		jr nz, Branch_VoiceSkip
			// Play voice SFX
			ld a, 0xA1
			rst 0x28
		Branch_VoiceSkip:
		
	LABEL_109E_b:
		ld a, (IsStillWriting)
		or a
		jp nz, 0x7C9
		
		// Line break or dialogue entry is over
		// Now that we're done, VWF VRAM management nonsense
		call ResetTileBuffer
		call SwapLines
		
		ld hl, 0xC197
		dec (hl)
		jr z, LABEL_111C
		ld hl, 0x7944
		ld a, (0xC196)
		or a
		jr z, LABEL_109E_c
		ld l, 0x66
	LABEL_109E_c:	
		ld (VramTileMapStart), hl
		ld hl, (0xC117)
		inc hl
		ld (0xC117), hl
		ld a, 0x04
		ld (0xC199), a
		ld a, 0x02
		ld (0xC19A), a
		jp 0x7C9
		
	LABEL_111C:
		ld a, (0xC18D)
		or a
		jr z, LABEL_111C_a
		xor a
		ld (0xC18D), a
		ld (0xC192), a
		jp 0x7C9
		
	LABEL_111C_a:	
		ld a, (0xC195)
		or a
		jp nz, 0x1248
		ld hl, (0xC190)
		ld a, (hl)
		or a
		jr nz,LABEL_1144
		ld (0xC180), a
		ld (0xC192), a
		jp 0x1540
	LABEL_1144:
		jp 0x1143
	
	// Hooked into prexisting asm code
	// Triggers whenever a new dialogue line is displayed
	SetupDialoguePrint1:
		call SetupLineVars
		ld (0xC190), ix
		jp 0x107A
	
	// Hooked into prexisting asm code
	// Triggers when the dialogue screen is loaded
	SetupDialoguePrint2:		
		call ResetTileBuffer
		
		ld a,0x01
		ld (NotNPCVRAMLineNo),a
		ld (NPCVRAMLineNo),a
		
		jp 0x39F7
	
	ResetTileBuffer:
		ld b,0x8
		ld iy,Tile1Buffer
		
		ResetTileBufferLoop:
			ld (iy+0),0x0
			ld (iy+8),0x0
			inc iy
			dec b
		jp nz,ResetTileBufferLoop
		
		ld a,0x0
		ld (Width),a
		ret
	
	SwapLines:
		ld a, (0xC196)
		or a
		
		jr z, PrintDialogueVRAMNotNPCText
			ld a,(NPCVRAMLineNo)
			xor 0x1
			ld (NPCVRAMLineNo),a
			jp PrintDialogueVRAMExit

		PrintDialogueVRAMNotNPCText:
			ld a,(NotNPCVRAMLineNo)
			xor 0x1
			ld (NotNPCVRAMLineNo),a
		PrintDialogueVRAMExit:
		
		call SetupLineVars
	
		ret

	// Based who's talking, set where to write in VRAM accordingly
	// Additionally, for this translation, we have a line number counter
	// for each character (I'm sure I could deduce this somehow from a 
	// pre-existing RAM value, but I'm lazy).
	// Also, I thought about storing the VRAM settings (what line number maps to what
	// tile id and VRAM location) in a table and refernce it, but again, I'm lazy.
	SetupLineVars:
		ld a, (0xC196)
		or a
		jr z, NotNPCText
			ld hl, 0x7966
			ld (VramTileMapStart), hl	

			ld a,(NPCVRAMLineNo)
			cp 0x1
			jp nz, NPCNotLine1
				ld de,NPCTileIdStartLine1
				ld (CurrentTileId),de
				
				ld hl,NPCVRAMStartLine1
				dec hl
				ld (VramTileStart),hl
				jp NPCTextExit
			NPCNotLine1:
				ld de,NPCTileIdStartLine2
				ld (CurrentTileId),de
				
				ld hl,NPCVRAMStartLine2
				dec hl
				ld (VramTileStart),hl
			
			NPCTextExit:
			jp SetupLineVarsExit
		NotNPCText:
			ld hl, 0x7944
			ld (VramTileMapStart), hl
			
			ld a,(NotNPCVRAMLineNo)
			cp 0x1
			jp nz, NotNPCNotLine1
				ld de,NotNPCTileIdStartLine1
				ld (CurrentTileId),de
				
				ld hl,NotNPCVRAMStartLine1
				dec hl
				ld (VramTileStart),hl
				jp NPCTextExit
			NotNPCNotLine1:
				ld de,NotNPCTileIdStartLine2
				ld (CurrentTileId),de
				
				ld hl,NotNPCVRAMStartLine2
				dec hl
				ld (VramTileStart),hl
			NotNPCTextExit:
		SetupLineVarsExit:
			ret
		
		CustomTextWrite:
			push hl
			ld de,CustomTileIdStart
			ld (CurrentTileId),de
			
			ld hl,CustomVRAMStart
			dec hl
			ld (VramTileStart),hl
			
			pop hl
			call CustomTextWriteMain

			ret
			
		CustomTextWriteMain:
			di
			ld a,0x3
			ld (IsStillWriting),a
			
			ld de,0x0000
			ld (Width),de
			
			ld (0xC117),hl
			
			CustomTextWriteLoop:				
				call WriteLineLoop
				ld a, (IsStillWriting)
				or a
				jr nz,CustomTextWriteLoop
			
			call ResetTileBuffer
			
			ei
			ret
			
			
	
////////////////////////////////////////////////
// Write Yes / No
////////////////////////////////////////////////
// Not enough room in parent, so it's here
	WriteYesNoVWF:
		ld hl,0x7B9E
		ld (VramTileMapStart),hl
		ld (MiscTilemapStart),hl
		ld hl, TextYesNo
		call CustomTextWrite
		ret

////////////////////////////////////////////////
// Actions
////////////////////////////////////////////////
// Not enough room in parent, so it's here
	WriteActionVWF:
		ld hl,0x7B58
		ld (VramTileMapStart),hl
		ld (MiscTilemapStart),hl
		
		ld hl, ActionMenuText
		call CustomTextWrite
		ret
		
////////////////////////////////////////////////
// Print money
////////////////////////////////////////////////	

ConvertToId						equ 0x0056
YenSymbol 						equ 0x60
ConvertedZeroChar 				equ 0x0056
PaddingChar		 				equ 0x0053

	PrintMoney:
	di
	// Convert money amount stored in RAM to a script digest.
	ld ix,MoneyStart
	ld iy,MoneyTextBuffer
	
	ld b,0x4
	ReadNumberLoop:
		// Write lo
		ld h,0x00
		ld l,(ix+0)
		ld a,l
		and 0xF
		ld l,a
		
		// Convert to tile id 
		ld de,ConvertToId
		add hl,de
		ld (iy+1),l
		
		// Write hi
		ld h,0x00
		ld l,(ix+0)
		
		rr l
		rr l
		rr l
		rr l
		
		ld a,l
		and 0xF
		ld l,a
		
		ld de,ConvertToId
		add hl,de
		ld (iy+0),l
		
		ld h,0x00
		ld l,(ix+0)
		
		inc iy
		inc iy
		dec ix
		dec b
		jp nz, ReadNumberLoop
		
	// Add yen symbol
	ld (iy+0),YenSymbol
	inc iy
		
	// Add delimeter
	ld (iy+0),0x00
	
	ld iy,MoneyTextBuffer
	
	RemoveTrailingZerosLoop:
		ld a,(iy+0)
		
		// If not zero character, exit
		cp ConvertedZeroChar
		jp nz, RemoveTrailingZerosExit
		
		// Pad with blank character
		// All digits are of length 0x5 so it prevents
		// the numbers from shifting after any sort of change.
		ld a,PaddingChar
		ld (iy+0),a
		inc iy
		jp RemoveTrailingZerosLoop
		
	RemoveTrailingZerosExit:
	
	ld hl,0x7D5A
	
	// Kind of a dumb hack.
	// Apparently this is triggered after SetupDialoguePrint2
	// is certain circumstances, like after UnagiinuMomNamecard is shown.
	// So we have to preserve these RAM addresses.
	
	ld de,(VramTileMapStart)
	push de
	ld de,(CurrentTileId)
	push de
	ld de,(VramTileStart)
	push de
	ld de,(0xC117)
	push de
	
	ld (VramTileMapStart),hl
	ld (MiscTilemapStart),hl
	ld hl, MoneyTextBuffer+0x1
	call MoneyTextWrite
	
	pop de
	ld (0xC117),de
	pop de
	ld (VramTileStart),de
	pop de
	ld (CurrentTileId),de
	pop de
	ld (VramTileMapStart),de
	
	ei
	ret
	
	// Copy and paste of CustomTextWrite
	MoneyTextWrite:
		ld de,MoneyTileIdStart
		ld (CurrentTileId),de
		
		ld de,MoneyVRAMStart
		dec de
		ld (VramTileStart),de
		
		jp CustomTextWriteMain
		
PrintPauseMenu:
	push hl
	ld hl,0x78C6
	ld (VramTileMapStart),hl
	ld (MiscTilemapStart),hl

	ld de,0xA0
	ld (CurrentTileId),de
		
	ld de,0x1400
	dec de
	ld (VramTileStart),de
	
	pop hl
	jp CustomTextWriteMain
	
PrintPasswordText:
	push hl
	ld hl,0x7854
	ld (VramTileMapStart),hl
	ld (MiscTilemapStart),hl

	ld de,0x54
	ld (CurrentTileId),de
		
	ld de,0xA80
	dec de
	ld (VramTileStart),de
	
	pop hl
	jp CustomTextWriteMain	
		
		
////////////////////////////////////////////////
// Write Harcoded Namecard
////////////////////////////////////////////////
	WriteHarcodedNamecard:
		ld de,NameCardTileMapStart
		ld (VramTileMapStart),de
		ld (MiscTilemapStart),de
		
		ld de,NameCardTileIdStart
		ld (CurrentTileId),de
		
		ld de,NameCardVRAMStart
		dec de
		ld (VramTileStart),de
		
		call CustomTextWriteMain
		ret

////////////////////////////////////////////////
.headersize 0x0
////////////////////////////////////////////////
// Namecard
////////////////////////////////////////////////
.org 0x000037BA
	.fill 0xE
.org 0x000037BA
	// https://www.smspower.org/Development/GGOfficialDocs#UsingTheROMBankSwitchingAndBackupRAM
	// Bank switch
	ld a,0x03
	ld (0xFFFF),a
	call WriteNamecardFunc	
	
// Move namecard text left to take advantage of expanded namecard
.org 0x000037AC
	ld hl,NameCardTileMapStart
	
//-------------------------
// Hardcoded namecards
//-------------------------

.org 0x00000C03
	.fill 0x0C
.org 0x00000C03
	ld a,0x03
	ld (0xFFFF),a
	ld hl,UnagiinuMomNamecard
	call WriteHarcodedNamecard

.org 0x00000C96
	.fill 0x0C	
.org 0x00000C96
	ld a,0x03
	ld (0xFFFF),a
	ld hl,YakuzaNamecard
	call WriteHarcodedNamecard
	
.org 0x00000CE8
	.fill 0x0C	
.org 0x00000CE8
	ld a,0x03
	ld (0xFFFF),a
	ld hl,RealtorNamecard
	call WriteHarcodedNamecard

.org 0x00001379
	.fill 0x0C	
.org 0x00001379
	ld a,0x03
	ld (0xFFFF),a
	ld hl,AlienNamecard
	call WriteHarcodedNamecard
	
.org 0x16EF
	.fill 0x80
.org 0x16EF
UnagiinuMomNamecard:
	.strn "    Eel Dog's",0xFF,"       Mom",0x00
YakuzaNamecard:
	.strn "      Yakuza   ",0xFF,"             ",0x00
RealtorNamecard:
	.strn "   Real Estate",0xFF,"      Agent",0x00
AlienNamecard:
	.strn "      Waruian",0xFF,"             ",0x00

////////////////////////////////////////////////
// Yes / No Text
////////////////////////////////////////////////
.org 0x0000117F
	.fill 0x0C
.org 0x0000117F
	ld a,0x03
	ld (0xFFFF),a
	call WriteYesNoVWF
	
	
//-------------------------
// Yes / no menu
//-------------------------

// Move menu to left to compensate for expanded namecards
.org 0x1173
	// Menu
	ld hl,0x8811 //ld hl,ActionMenuTilemap
	ld de,0x7B1C
	ld bc,0x0A07
	call 0x03E7

// Move cursor left
.org 0x13B4
	ld a,0x70
	
// Move blanking to left
.org 0x13E5
	ld de,0x7B1C
	ld bc,0x0A07  

////////////////////////////////////////////////
// Action menu option
////////////////////////////////////////////////

.org 0x1625
	.fill 0x2D

.org 0x154F
	.fill 0x0C
.org 0x154F
	ld a,0x03
	ld (0xFFFF),a
	call WriteActionVWF
	
.org 0x3804
	.fill 0x0C
.org 0x3804
	ld a,0x03
	ld (0xFFFF),a
	call WriteActionVWF
	
////////////////////////////////////////////////
// Actual text
////////////////////////////////////////////////
	
.loadtable ".\asm\tb-vwf - New.tbl"

.org 0x00001643
	.fill 0x9
.org 0x00001643
	TextYesNo:
	.strn "Yes",0xFF,0xFF
	.strn "No",0x00

.org 0x1625
	ActionMenuText:
	.strn "Talk",0xFF,0xFF
	.strn "Fight",0x55,0xFF,0xFF
	.strn "Give",0x00
	
// https://chilliant.com/z80shift.html

////////////////////////////////////////////////
// Menu box
////////////////////////////////////////////////

// Change white BG tile
.org 0x00024811
	db 0x78,0x00,0x79,0x00,0x79,0x00,0x79,0x00,0x78,0x02
	db 0x7A,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x7A,0x02
	db 0x7A,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x7A,0x02
	db 0x7A,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x7A,0x02
	db 0x7A,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x7A,0x02
	db 0x7A,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x7A,0x02
	db 0x78,0x04,0x79,0x04,0x79,0x04,0x79,0x04,0x78,0x06
	
	// Money menu
	db 0x87,0x00,0x81,0x04,0x81,0x04,0x81,0x04,0x81,0x04,0x81,0x04,0x87,0x02
	db 0x88,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x88,0x02
	db 0x88,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x88,0x02
	db 0x88,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x88,0x02
	db 0x89,0x00,0x82,0x00,0x82,0x00,0x82,0x00,0x82,0x00,0x82,0x00,0x89,0x02

////////////////////////////////////////////////
// Expand dialogue decompression buffer
////////////////////////////////////////////////

.org 0x0000102F
	ld iy, DialogueDecompressionBuffer // Old: ld iy,0xC7D0
	
.org 0x0000107A
	ld hl,DialogueDecompressionBuffer // 0xC7D0

////////////////////////////////////////////////
// Print money
////////////////////////////////////////////////

.org 0x00000532
	.fill 0x3D
.org 0x00000532
	ld a,0x03
	ld (0xFFFF),a
	call PrintMoney
	ret
	
	
////////////////////////////////////////////////
// -------
////////////////////////////////////////////////

org 0x00006E0A
	.fill 0x0C
org 0x00006E0A
	ld a,0x03
	ld (0xFFFF),a
	ld hl,PasswordScreenPrompt
	call PrintPasswordText

org 0x00007446
	.fill 0x0C
org 0x00007446
	ld a,0x03
	ld (0xFFFF),a
	ld hl,PasswordScreenInvalid
	call PrintPasswordText


// 0x72aa
// パスワード　を　いれてください。
// パスワード　が　ちがいます。
.org 0x72aa
	.fill 0x58
.org 0x72aa
	PasswordScreenPrompt:
	.strn "  Please enter a",0xFF
	.strn "     password.",0x00
	PasswordScreenInvalid:
	.strn "    Password is",0xFF
	.strn "        invalid.  ",0x00

.org 0x261BB
	.incbin ".\asm\tilemaps\password screen.bin"

//ゲームをつづける。 (Continue Game)
//ゲームをやめる。 (Quit Game)
.org 0x00000776
	.fill 0x24
.org 0x00000776
	MenuText:
	.strn "Continue",0xFF,0xFF
	.strn "Quit",0x00
	
org 0x00000626
	.fill 0x0C
.org 0x00000626
	ld a,0x03
	ld (0xFFFF),a
	ld hl,MenuText
	call PrintPauseMenu
	

// Move tile blanking to the left
org 0x00000744
	ld hl,0x16A7
	ld de,0x7886
	ld bc,0x1204
	call 0x3E7

// White blanking (adjust for new blank tile)
org 0x16A7
	db 0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00
	db 0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00
	db 0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00
	db 0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00
	
////////////////////////////////////////////////
// Pause screen blanking expand
////////////////////////////////////////////////

org 0x0000061A
	ld hl,SmallBlankingText
	ld de,0x7CA6
	ld bc,0x0F06
	call 0x03E7

org 0x00001619
	ld hl,SmallBlankingText
	ld de,0x7CB6
	ld bc,0x0806
	jp 0x03E7
	

////////////////////////////////////////////////
// Ending screen blanking expand
////////////////////////////////////////////////

org 0x00000E37
	ld hl,SmallBlankingText
	ld de,0x7CA6
	ld bc,0x1806
	call 0x03E7
	
////////////////////////////////////////////////
// Yakuza/Realtor gone namecard blanking
////////////////////////////////////////////////
	
org 0x000039A5
	ld hl,SmallBlankingText
	ld de,0x7CA6
	ld bc,0x1806
	jp 0x03E7

org 0x00000C47
	ld hl,SmallBlankingText
	ld de,0x7CA6
	ld bc,0x1806
	call 0x03E7

////////////////////////////////////////////////
// Print password
////////////////////////////////////////////////

PasswordText						equ 0xCF00

org 0x00000F72
	.fill 0x0C
org 0x00000F72
	call WritePasswordSetup

org 0x7f00
	WritePasswordSetup:
	
	// Write menu
	ld hl,PasswordMenuTilemap
	ld de,0x7B84
	ld bc,0x1C07
	call 0x03E7
	
	// Prepare text
	ld a,0x03
	ld (0xFFFF),a
	
	WritePassword:
	ld hl,DialogueDecompressionBuffer
	ld de,PasswordText
	
	ld b,0x24
	ld c,0x0
	WritePasswordLoop:
		// Add linebreak after every 10 characters
		ld a,c
		cp 0xC
		jp nz, WritePasswordLoopLineBreakSkip
			ld (hl),LineBreakControlCode
			inc hl
			ld (hl),LineBreakControlCode
			inc hl
			ld c,0x00
		WritePasswordLoopLineBreakSkip:
		
		// insert chara
		ld a,(de)
		ld (hl),a
			
		inc hl
		inc de
			
		inc c
		dec b
		jp nz, WritePasswordLoop
		
	ld (hl),DelimeterControlCode
	
	// Write text to screen
	ld hl,0x7BC8
	ld (VramTileMapStart),hl
	ld (MiscTilemapStart),hl
	ld hl, DialogueDecompressionBuffer
	call CustomTextWrite
	
	// Return back to original bank
	ld a,0x0B
	ld (0xFFFF),a
	ret

org 0x000071A6
PasswordMenuTilemap:
	db 0x78,0x00,0x79,0x00,0x79,0x00,0x79,0x00,0x79,0x00,0x79,0x00,0x79,0x00,0x79,0x00,0x79,0x00,0x79,0x00,0x79,0x00,0x79,0x00,0x79,0x00,0x78,0x02
	db 0x7A,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x7A,0x02
	db 0x7A,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x7A,0x02
	db 0x7A,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x7A,0x02
	db 0x7A,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x7A,0x02
	db 0x7A,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x01,0x00,0x7A,0x02
	db 0x78,0x04,0x79,0x04,0x79,0x04,0x79,0x04,0x79,0x04,0x79,0x04,0x79,0x04,0x79,0x04,0x79,0x04,0x79,0x04,0x79,0x04,0x79,0x04,0x79,0x04,0x78,0x06

// Password: Hex to letter mapping
org 0x0000726A
	.loadtable ".\asm\tb-vwf - New.tbl"
// 	db 
	.strn "ABCDEFGHKLMNOPQ"
	.strn "RSTUVWXYZabcdef"
	.strn "ghkmnopqrstuvwx"
	.strn "yz123456789()-/"
	.strn "?",0x12,0x50,0x52

// Change blank character for password screen
org 0x00006E27
	ld (hl),0x01
