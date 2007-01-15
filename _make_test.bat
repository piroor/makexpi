setlocal
set appname=%~n0
set appname=%appname:~0,-5%


cd d:\data\codes\%appname%\trunk

for /F "tokens=1-3 delims=/ " %%a in ('date /t') do set DATES=%%a%%b%%c

del "o:\xul\xpi\%appname%_test.xpi"

chmod -cfr 644 *.jar *.js *.light *.inf *.rdf *.cfg *.manifest



mkdir temp
xcopy content temp\content /i /s
xcopy locale temp\locale /i /s
xcopy skin temp\skin /i /s
xcopy defaults temp\defaults /i /s
cd temp



mkdir "chrome"
zip -r0 "chrome\%appname%.jar" content locale skin

del locale.inf
copy o:\xul\codes\make-xpi\en.inf .\locale.inf
del options.inf
copy "o:\xul\codes\make-xpi\options.%appname%.en.inf" .\options.inf
chmod -cf 644 *.jar *.js *.light *.inf *.rdf *.cfg
zip -9 o:\xul\xpi\%appname%_test.xpi *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r o:\xul\xpi\%appname%_test.xpi chrome
zip -9 -r o:\xul\xpi\%appname%_test.xpi defaults


cd ..
rmdir "temp" /s /q


rem copy %appname%.jar C:\Apps\Win\Other\Mozilla\bin\chrome\%appname%.jar
rem copy %appname%.jar C:\Apps\Win\Other\Mozilla\bin16\chrome\%appname%.jar
rem copy %appname%.jar "C:\Apps\Win\Other\Netscape\Netscape 7\chrome\%appname%.jar"

endlocal

