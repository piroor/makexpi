setlocal
set appname=%~n0
set appname=%appname:~0,-5%


c:
cd c:\Users\Public\data\codes\%appname%


rmdir "jar_temp" /s /q
rmdir "xpi_temp" /s /q
del "%appname%_test.xpi"



:CREATEJARTEMPFILES
mkdir jar_temp
xcopy content jar_temp\content /i /s
xcopy locale jar_temp\locale /i /s
xcopy skin jar_temp\skin /i /s

cd jar_temp
chmod -cfr 644 *.jar *.js *.light *.inf *.rdf *.cfg *.manifest

:MAKEJAR
rem cd ..
rem signtool -d "%certpath%" -k "%certname%" -p "%certpass%" -Z "%appname%.jar" jar_temp
zip -r0 "..\%appname%.jar" content locale skin
cd ..



:CREATEXPITEMPFILES
mkdir xpi_temp
xcopy defaults xpi_temp\defaults /i /s
xcopy components xpi_temp\components /i /s
xcopy license xpi_temp\license /i /s
xcopy chrome xpi_temp\chrome /i /s
xcopy platform xpi_temp\platform /i /s
xcopy *.js xpi_temp\ /i
xcopy *.rdf xpi_temp\ /i
xcopy *.manifest xpi_temp\ /i
xcopy *.cfg xpi_temp\ /i
xcopy *.light xpi_temp\ /i

:PACKPLATFORMS
IF EXIST platform (
	cd xpi_temp\platform
	for /D  %%d in (*) do (
		if exist "%%d\chrome.manifest" (
			cd %%d
			mkdir chrome
			zip -r0 "chrome\%appname%.jar" content locale skin
			rmdir "content" /s /q
			rmdir "locale" /s /q
			rmdir "skin" /s /q
			cd ..
		)
	)
	cd ..\..
)

cd xpi_temp
mkdir chrome

cd ..
copy "%appname%.jar" xpi_temp\chrome\ /y
cd xpi_temp

chmod -cfr 644 *.jar *.js *.light *.inf *.rdf *.cfg *.manifest

:MAKEXPI
IF EXIST ..\install.js (
	copy ..\ja.inf .\locale.inf
	copy "..\options.%appname%.ja.inf" .\options.inf
	chmod -cf 644 *.inf
)

zip -9 "..\%appname%_test.xpi" *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r "..\%appname%_test.xpi" chrome defaults components license platform




:DELETETEMPFILES

cd ..
del "%appname%.jar"
rmdir "jar_temp" /s /q
rmdir "xpi_temp" /s /q





del "o:\xul\xpi\%appname%_test.xpi"

:CREATEHASH
sha1sum -b %appname%*.xpi > sha1hash.txt

:MOVEFILES
copy %appname%_test.xpi o:\xul\xpi\


endlocal
