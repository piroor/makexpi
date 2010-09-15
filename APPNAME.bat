set appname=%~n0

copy buildscript\makexpi.sh .\
bash makexpi.sh %appname% version=0
del makexpi.sh
