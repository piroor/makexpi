cd d:\data\codes\%~n0\trunk

for /F "tokens=1-3 delims=/ " %%a in ('date /t') do set DATES=%%a%%b%%c

del "%~n0.jar"
rmdir "chrome" /s /q
del "o:\xul\xpi\%~n0_test.xpi"

chmod -cfr 644 *.jar *.js *.light *.inf *.rdf *.cfg *.manifest

mkdir "chrome"
zip -r0 "chrome\%~n0.jar" content locale skin

del locale.inf
copy ..\en.inf .\locale.inf
del options.inf
copy "..\options.%~n0.en.inf" .\options.inf
chmod -cf 644 *.jar *.js *.light *.inf *.rdf *.cfg
zip -9 o:\xul\xpi\%~n0_test.xpi *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r o:\xul\xpi\%~n0_test.xpi chrome
zip -9 -r o:\xul\xpi\%~n0_test.xpi defaults

copy "chrome\%~n0.jar" .\
rmdir "chrome" /s /q

del *.inf
del *.jar


rem copy %~n0.jar C:\Apps\Win\Other\Mozilla\bin\chrome\%~n0.jar
rem copy %~n0.jar C:\Apps\Win\Other\Mozilla\bin16\chrome\%~n0.jar
rem copy %~n0.jar "C:\Apps\Win\Other\Netscape\Netscape 7\chrome\%~n0.jar"
