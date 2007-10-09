setlocal
set appname=%~n0

rem 証明書データベースのパス
set certpath=C:\cert
rem 証明書の名前
set certname=foobar
rem データベース生成時のパスワード
set certpass=passowrd


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
rem signtool -d "%certpath%" -k "%certname%" -p "%certpass%" -Z "%appname%.jar" jar_temp
zip -r0 "..\%appname%.jar" content locale skin
cd ..


:CREATEXPITEMPFILES
mkdir xpi_temp
xcopy defaults xpi_temp\defaults /i /s
xcopy components xpi_temp\components /i /s
xcopy license xpi_temp\license /i /s
xcopy chrome xpi_temp\chrome /i /s
xcopy *.js xpi_temp\ /i
xcopy *.rdf xpi_temp\ /i
xcopy *.manifest xpi_temp\ /i
xcopy *.cfg xpi_temp\ /i
xcopy *.light xpi_temp\ /i

:PACKPLATFORMS
IF EXIST platform (
	xcopy platform xpi_temp\platform /i /s
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

rem cd ..
rem signtool -d "%certpath%" -k "%certname%" -p "%certpass%" -X -Z "%appname%.xpi" xpi_temp
rem cd xpi_temp
zip -9 "..\%appname%.xpi" *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r "..\%appname%.xpi" chrome defaults components license platform



:MAKELZH
IF EXIST ..\readme.txt (
	unlha.exe a -m0 ..\%appname%.lzh ..\%appname%.xpi ..\readme.txt
)

:MAKEENOLD
IF EXIST ..\install.js (
	copy ..\en.inf .\locale.inf
	copy "..\options.%appname%.en.inf" .\options.inf
	chmod -cf 644 *.inf
	rem cd ..
	rem signtool -d "%certpath%" -k "%certname%" -p "%certpass%" -X -Z "%appname%_en.xpi" xpi_temp
	rem cd xpi_temp
	zip -9 "..\%appname%_en.xpi" *.js *.light *.inf *.rdf *.cfg *.manifest
	zip -9 -r "..\%appname%_en.xpi" chrome defaults components license platform
)



:DELETETEMPFILES
cd ..
del "%appname%.jar"
rmdir "jar_temp" /s /q
rmdir "xpi_temp" /s /q


:COPYFORMETAPACKAGE
IF EXIST meta (
	del "meta\%appname%.xpi"
	copy "%appname%.xpi" meta\
)

:CREATEHASH
sha1sum -b %appname%*.xpi > sha1hash.txt


:ENDBATCH
endlocal
