@echo off

echo ...

%~dp0..\bin-win\libxml\xsltproc.exe %~dp0simple.xslt %~dp0simple.xml > %~dp0simple.txt

echo Done.
echo.
echo Result:
echo.
type simple.txt
echo.
echo.