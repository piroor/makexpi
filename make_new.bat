setlocal
set appname=%~n0

rmdir "temp" /s /q
del "%appname%.xpi"
del "%appname%_en.xpi"
del "%appname%.lzh"


:CREATETEMPFILES
mkdir temp
xcopy content temp\content /i /s
xcopy locale temp\locale /i /s
xcopy skin temp\skin /i /s
xcopy defaults temp\defaults /i /s
xcopy components temp\components /i /s
xcopy *.js temp\ /i
xcopy *.rdf temp\ /i
xcopy *.manifest temp\ /i

xcopy *.cfg temp\ /i
xcopy *.light temp\ /i
cd temp

chmod -cfr 644 *.jar *.js *.light *.inf *.rdf *.cfg *.manifest


:MAKEJAR
mkdir "chrome"
zip -r0 "chrome\%appname%.jar" content locale skin


IF EXIST ..\install.js GOTO MAKEOLD
GOTO MAKENEW

:MAKEOLD
copy ja.inf .\locale.inf
copy "options.%appname%.ja.inf" .\options.inf
chmod -cf 644 *.inf

:MAKENEW
zip -9 "..\%appname%.xpi" *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r "..\%appname%.xpi" chrome
zip -9 -r "..\%appname%.xpi" defaults
zip -9 -r "..\%appname%.xpi" components



IF EXIST ..\readme.txt GOTO MAKELZH
IF EXIST ..\install.js GOTO MAKEENOLD
GOTO DELETETEMPFILES

:MAKELZH
unlha.exe a -m0 ..\%appname%.lzh ..\%appname%.xpi ..\readme.txt



:MAKEENOLD
copy en.inf .\locale.inf
copy "options.%appname%.en.inf" .\options.inf
chmod -cf 644 *.inf
zip -9 "..\%appname%_en.xpi" *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r "..\%appname%_en.xpi" chrome
zip -9 -r "..\%appname%_en.xpi" defaults
zip -9 -r "..\%appname%_en.xpi" components



:DELETETEMPFILES

cd ..
rmdir "temp" /s /q

endlocal
