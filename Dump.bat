::Folders
set projectFolder=%cd%
set toolsFolder=%projectFolder%\tools

set spiroFolder=%toolsFolder%\spiro
set compressionTool=%toolsFolder%\compression

set graphicsUncompressedOriginal=%projectFolder%\graphics\uncompressed (original)
set tilemapUncompressedOriginal=%projectFolder%\tilemap\uncompressed (original)

::Roms
set baseImage=%cd%\roms\Tensai Bakabon (Japan).sms

cd "%projectFolder%"

::Dump script
"%spiroFolder%\Spiro.exe" /ProjectDirectory "%projectFolder%" /DumpScript /Verbose

::Decompress graphics
"%compressionTool%\Tensei Bakabon GFX.exe" "Dump" "%baseImage%" "0x0000C222" "%graphicsUncompressedOriginal%\font.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Dump" "%baseImage%" "0x00018000" "%graphicsUncompressedOriginal%\title.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Dump" "%baseImage%" "0x00020000" "%graphicsUncompressedOriginal%\overworld.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Dump" "%baseImage%" "0x0002208E" "%graphicsUncompressedOriginal%\shooter.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Dump" "%baseImage%" "0x0000E42D" "%graphicsUncompressedOriginal%\shootersprites.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Dump" "%baseImage%" "0x00029FDF" "%graphicsUncompressedOriginal%\endcard.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Dump" "%baseImage%" "0x00025BBB" "%graphicsUncompressedOriginal%\hajimegame.bin" "4"

"%compressionTool%\Tensei Bakabon GFX.exe" "Dump" "%baseImage%" "0x00022AA1" "%graphicsUncompressedOriginal%\skycastle1.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Dump" "%baseImage%" "0x000231AC" "%graphicsUncompressedOriginal%\skycastle2.bin" "4"

"%compressionTool%\Tensei Bakabon GFX.exe" "Dump" "%baseImage%" "0x0001917B" "%tilemapUncompressedOriginal%\title.bin" "2"
"%compressionTool%\Tensei Bakabon GFX.exe" "Dump" "%baseImage%" "0x0002489D" "%tilemapUncompressedOriginal%\talktime.bin" "2"

"%compressionTool%\Tensei Bakabon GFX.exe" "Dump" "%baseImage%" "0x00014E3C" "%tilemapUncompressedOriginal%\underground.bin" "12"

@pause