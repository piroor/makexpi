setlocal
set appname=%~n0

rmdir "jar_temp" /s /q
rmdir "xpi_temp" /s /q
del "%appname%.xpi"
del "%appname%_en.xpi"
del "%appname%.lzh"


:CREATEJARTEMPFILES
mkdir jar_temp
xcopy content jar_temp\content /i /s
xcopy locale jar_temp\locale /i /s
xcopy skin jar_temp\skin /i /s

cd jar_temp
chmod -cfr 644 *.jar *.js *.light *.inf *.rdf *.cfg *.manifest

:MAKEJAR
rem cd ..
rem signtool -d "証明書データベースのパス" -k "証明書の名前" -p "パスワード" -Z "chrome\%appname%.jar" jar_temp
zip -r0 "%appname%.jar" content locale skin
cd ..


:CREATEXPITEMPFILES
mkdir xpi_temp
xcopy defaults xpi_temp\defaults /i /s
xcopy components xpi_temp\components /i /s
xcopy chrome xpi_temp\chrome /i /s
xcopy *.js xpi_temp\ /i
xcopy *.rdf xpi_temp\ /i
xcopy *.manifest xpi_temp\ /i
xcopy *.cfg xpi_temp\ /i
xcopy *.light xpi_temp\ /i

cd xpi_temp

mkdir chrome
xcopy ..\jar_temp\*.jar chrome\ /i /s

chmod -cfr 644 *.jar *.js *.light *.inf *.rdf *.cfg *.manifest

:MAKEXPI



IF EXIST ..\install.js GOTO MAKEOLD
GOTO MAKENEW

:MAKEOLD
copy ..\ja.inf .\locale.inf
copy "..\options.%appname%.ja.inf" .\options.inf
chmod -cf 644 *.inf

:MAKENEW
rem cd ..
rem signtool -d "証明書データベースのパス" -k "証明書の名前" -p "パスワード" -X -Z "..\%appname%.xpi" xpi_temp
rem cd xpi_temp
zip -9 "..\%appname%.xpi" *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r "..\%appname%.xpi" chrome defaults components



IF EXIST ..\readme.txt GOTO MAKELZH
IF EXIST ..\install.js GOTO MAKEENOLD
GOTO DELETETEMPFILES

:MAKELZH
unlha.exe a -m0 ..\%appname%.lzh ..\%appname%.xpi ..\readme.txt



:MAKEENOLD
copy ..\en.inf .\locale.inf
copy "..\options.%appname%.en.inf" .\options.inf
chmod -cf 644 *.inf
rem cd ..
rem signtool -d "証明書データベースのパス" -k "証明書の名前" -p "パスワード" -X -Z "..\%appname%_en.xpi" xpi_temp
rem cd xpi_temp
zip -9 "..\%appname%_en.xpi" *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r "..\%appname%_en.xpi" chrome defaults components



:DELETETEMPFILES

cd ..
rmdir "jar_temp" /s /q
rmdir "xpi_temp" /s /q


IF EXIST meta GOTO COPYFORMETAPACKAGE
GOTO ENDBATCH



:COPYFORMETAPACKAGE

del "meta\%appname%.xpi"
copy "%appname%.xpi" meta\



:ENDBATCH

endlocal
