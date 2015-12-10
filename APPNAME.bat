setlocal
set appname=%~n0

bash makexpi\makexpi.sh -n %appname% -o
endlocal
