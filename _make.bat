setlocal
set appname=%~n0

d:
cd d:\data\codes\%appname%

rmdir "jar_temp" /s /q
rmdir "xpi_temp" /s /q
del "%appname%.xpi"
del "%appname%_en.xpi"
del "%appname%_noupdate.xpi"
del "%appname%_noupdate_en.xpi"
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
xcopy platform xpi_temp\platform /i /s
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
zip -9 "..\%appname%.xpi" *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r "..\%appname%.xpi" chrome defaults components license platform

sed -e "s#^.*<em:*\(updateURL\|updateKey\)>.*</em:*\(updateURL\|updateKey\)>##g" -e "s#^.*em:*\(updateURL\|updateKey\)=\(\".*\"\|'.*'\)##g" ..\install.rdf > install.rdf
zip -9 "..\%appname%_noupdate.xpi" *.js *.light *.inf *.rdf *.cfg *.manifest
zip -9 -r "..\%appname%_noupdate.xpi" chrome defaults components license platform



:MAKELZH
IF EXIST ..\readme.txt (
	unlha.exe a -m0 ..\%appname%.lzh ..\%appname%.xpi ..\readme.txt
)

:MAKEENOLD
IF EXIST ..\install.js (
	copy ..\install.rdf .\install.rdf
	copy ..\en.inf .\locale.inf
	copy "..\options.%appname%.en.inf" .\options.inf
	chmod -cf 644 *.inf
	zip -9 "..\%appname%_en.xpi" *.js *.light *.inf *.rdf *.cfg *.manifest
	zip -9 -r "..\%appname%_en.xpi" chrome defaults components license platform

	sed -e "s#^.*<em:*\(updateURL\|updateKey\)>.*</em:*\(updateURL\|updateKey\)>##g" -e "s#^.*em:*\(updateURL\|updateKey\)=\(\".*\"\|'.*'\)##g" ..\install.rdf > install.rdf
	zip -9 "..\%appname%_noupdate_en.xpi" *.js *.light *.inf *.rdf *.cfg *.manifest
	zip -9 -r "..\%appname%_noupdate_en.xpi" chrome defaults components license platform
)



:DELETETEMPFILES

cd ..
del "%appname%.jar"
rmdir "jar_temp" /s /q
rmdir "xpi_temp" /s /q





del "o:\xul\xpi\%appname%.xpi"
del "o:\xul\xpi\%appname%_en.xpi"
del "o:\xul\xpi\%appname%.lzh"

for /F "tokens=1-3 delims=/ " %%a in ('date /t') do set DATES=%%a%%b%%c

IF EXIST readme.txt (
	copy %appname%.lzh c:\apps\win\other\mozilla\_packages\%appname%_%DATES%.lzh
) ELSE (
	copy %appname%.xpi c:\apps\win\other\mozilla\_packages\%appname%_%DATES%.xpi.zip
)

:CREATEHASH
sha1sum -b %appname%*.xpi > sha1hash.txt

:MOVEFILES
mv %appname%.xpi o:\xul\xpi\
mv %appname%_en.xpi o:\xul\xpi\
mv %appname%.lzh o:\xul\xpi\



endlocal
