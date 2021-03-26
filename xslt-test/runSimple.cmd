@echo off

echo ...

java -jar %~dp0../bin-java/SaxonHE/saxon-he-10.3.jar  -s:%~dp0simple.xml -xsl:%~dp0simple.xslt -o:%~dp0simple.txt

echo Done.
echo.
echo Result:
echo.
type simple.txt
echo.
echo.