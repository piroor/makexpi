cd d:\data\codes\%~n0\trunk

for /F "tokens=1-3 delims=/ " %%a in ('date /t') do set DATES=%%a%%b%%c

del "%~n0.jar"
rmdir "chrome" /s /q
del "o:\xul\xpi\%~n0.xpi"
del "o:\xul\xpi\%~n0_en.xpi"
del "o:\xul\xpi\%~n0.lzh"

chmod -cfr 644 *.jar *.js *.light *.inf *.rdf *.cfg *.manifest

mkdir "chrome"
zip -r0 "chrome\%~n0.jar" content locale skin

del locale.inf
copy ..\ja.inf .\locale.inf
del options.inf
copy "..\options.%~n0.ja.inf" .\options.inf
zip -9 o:\xul\xpi\%~n0.xpi *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r o:\xul\xpi\%~n0.xpi chrome
zip -9 -r o:\xul\xpi\%~n0.xpi defaults


IF EXIST readme.txt GOTO MAKELZH
GOTO MAKEEN

:MAKELZH
c:\apps\Dos\unlha\unlha.exe a -m0 o:\xul\xpi\%~n0.lzh o:\xul\xpi\%~n0.xpi readme.txt


:MAKEEN
del locale.inf
copy ..\en.inf .\locale.inf
del options.inf
copy "..\options.%~n0.en.inf" .\options.inf
chmod -cf 644 *.inf
zip -9 o:\xul\xpi\%~n0_en.xpi *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r o:\xul\xpi\%~n0_en.xpi chrome
zip -9 -r o:\xul\xpi\%~n0_en.xpi defaults



IF EXIST readme.txt GOTO COPYLZH
copy o:\xul\xpi\%~n0.xpi c:\apps\win\other\mozilla\_packages\%~n0_%DATES%.xpi.zip
GOTO COPYFILES

:COPYLZH
copy o:\xul\xpi\%~n0.lzh c:\apps\win\other\mozilla\_packages\%~n0_%DATES%.lzh



:COPYFILES

copy "chrome\%~n0.jar" .\
rmdir "chrome" /s /q

del *.inf
del *.jar


rem copy %~n0.jar C:\Apps\Win\Other\Mozilla\bin\chrome\%~n0.jar
rem copy %~n0.jar C:\Apps\Win\Other\Mozilla\bin16\chrome\%~n0.jar
rem copy %~n0.jar "C:\Apps\Win\Other\Netscape\Netscape 7\chrome\%~n0.jar"
