setlocal
set appname=%~n0
set appname=%appname:~0,-5%


d:
cd d:\data\codes\%appname%

rmdir "temp" /s /q
del "%appname%_test.xpi"


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
copy ..\ja.inf .\locale.inf
copy "..\options.%appname%.ja.inf" .\options.inf
chmod -cf 644 *.inf

:MAKENEW
zip -9 "..\%appname%.xpi" *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r "..\%appname%_test.xpi" chrome
zip -9 -r "..\%appname%_test.xpi" defaults
zip -9 -r "..\%appname%_test.xpi" components



IF EXIST ..\install.js GOTO MAKEENOLD
GOTO DELETETEMPFILES




:DELETETEMPFILES

cd ..
rmdir "temp" /s /q





del "o:\xul\xpi\%appname%_test.xpi"

:MOVEFILES
mv %appname%_test.xpi o:\xul\xpi\


endlocal
