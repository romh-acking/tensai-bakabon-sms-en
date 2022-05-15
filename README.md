[//]: <> (This readme is in the markdown format. Please preview in a markdown parser.)

# Tensai Bakabon (Sega Master System): English Translation

## About
This is the source code for the complete English translation of Tensai Bakabon for the Sega Master System.

## Folders
* `asm`
	* Contains the asm files which are to be compiled with armips.
* `roms`
	* Use this to store your roms
* `script`
	* Contains the dump script in `Script.json`. It contains the Japanese script and the English translation.
	* You can also store xlsx backups of the script here.
* `tables`
	* "Dictionary" specifies dictionary mapping. A dictionary can be mapped to multiple character values for compression purposes.
	* "FindAndReplace" does some text replacement before serializing to JSON / inserting to the rom.
	* Files with "Length" let you specify how wide, in pixels, characters are. This affects spiro.exe's auto-linebreaking logic.
* `graphics` / `tilemap`
	* Where compressed data is managed
	* Subfolder `compressed (new)` is where compressed version of custom assets are stored.
	* Subfolder `uncompressed (new)` is where uncompressed custom (mostly translated) assets are stored.
	* Subfolder `uncompressed (original)` is where the original uncompressed assets dumped from the rom are stored.
* `tools`
	* `armips` a fork of armips that supports z80 assembly language patches.
	* `compression` [the RLE (de)compressor.](https://github.com/romh-acking/tensei-bakabon-de-compressor)
## Manual
Check out the repo [tensai-bakabon-sms-en-manual](https://github.com/romh-acking/tensai-bakabon-sms-en-manual) for manual resources. It contains two versions of the manual: one with all the Japanese text blanked out and one that is typesetted. Much thanks to Sega Retro for the scans of the manual. Check out the original scans here:
[https://segaretro.org/File:TensaiBakabonSMSJPManual.pdf](https://segaretro.org/File:TensaiBakabonSMSJPManual.pdf)

## Credits

### Main Team
* FCandChill
	* Project lead
	* ASM hacking
	* Graphics
	* Manual Editing
	* Utilities
	* Proofreader
* cccmar
	* For going above and beyond playtesting
	* Spot translations
	* Hacking
* TheMajinZenki
	* Translator
### Support
* Prof9
	* armipsz80 troubleshooting
* Pinobatch
	* Font feedback
* All the lovely people at SMS Power
	* Documentation (game specific and general)
	* Feedback
* Sega Retro
	* Manual scans
* Calindro
	* For making Emulicious that features an amazing debugger.
* Klarth
	* For making TileShop
* Maxim
	* Credits corrections

### Beta Testers
* cccmar
* Révo
	* Real hardware tester
	* Not that guy from the Super Mario 64 decompilation project.
* togemet2