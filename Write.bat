::Roms
set baseImage=%cd%\roms\Tensai Bakabon (Japan).sms
set newImage=%cd%\roms\Tensai Bakabon (NEW).sms

::Folders
set projectFolder=%cd%
set toolsFolder=%projectFolder%\tools

set spiroFolder=%toolsFolder%\spiro
set armipsFolder=%toolsFolder%\armips
set compressionTool=%toolsFolder%\compression

set asmFolder=%cd%\asm

set graphicsUncompressedOriginal=%projectFolder%\graphics\uncompressed (original)
set graphicsUncompressedNew=%projectFolder%\graphics\uncompressed (new)
set graphicsCompressedNew=%projectFolder%\graphics\compressed (new)

set tileMapUncompressedOriginal=%projectFolder%\tilemap\uncompressed (original)
set tileMapUncompressedNew=%projectFolder%\tilemap\uncompressed (new)
set tileMapCompressedNew=%projectFolder%\tilemap\compressed (new)

del "%newImage%"
copy "%baseImage%" "%newImage%"

"%spiroFolder%\Spiro.exe" /ProjectDirectory "%projectFolder%" /WriteScriptToROM

::Compress graphics

copy "%graphicsUncompressedOriginal%\skycastle1.bin" "%graphicsUncompressedNew%\skycastle1.bin"
copy "%graphicsUncompressedOriginal%\skycastle2.bin" "%graphicsUncompressedNew%\skycastle2.bin"

"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%graphicsUncompressedNew%\font - blank.bin" "%graphicsCompressedNew%\font - blank.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%graphicsUncompressedNew%\font - password.bin" "%graphicsCompressedNew%\font - password.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%graphicsUncompressedNew%\title.bin" "%graphicsCompressedNew%\title.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%graphicsUncompressedNew%\overworld.bin" "%graphicsCompressedNew%\overworld.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%graphicsUncompressedNew%\shooter.bin" "%graphicsCompressedNew%\shooter.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%graphicsUncompressedNew%\skycastle1.bin" "%graphicsCompressedNew%\skycastle1.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%graphicsUncompressedNew%\skycastle2.bin" "%graphicsCompressedNew%\skycastle2.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%graphicsUncompressedNew%\shootersprites.bin" "%graphicsCompressedNew%\shootersprites.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%graphicsUncompressedNew%\endcard.bin" "%graphicsCompressedNew%\endcard.bin" "4"
"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%graphicsUncompressedNew%\hajimegame.bin" "%graphicsCompressedNew%\hajimegame.bin" "4"

"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%tileMapUncompressedNew%\title.bin" "%tileMapCompressedNew%\title.bin" "2"
"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%tileMapUncompressedNew%\talktime.bin" "%tileMapCompressedNew%\talktime.bin" "2"
"%compressionTool%\Tensei Bakabon GFX.exe" "Write" "%tileMapUncompressedNew%\underground.bin" "%tileMapCompressedNew%\underground.bin" "12"


::Armips scripts
"%armipsFolder%\armips.exe" "%projectFolder%\asm\main.asm"

::"%newImage%"
@Pause