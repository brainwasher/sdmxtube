@echo off
echo ...

java -jar %~dp0../bin-java/SaxonHE/saxon-he-10.3.jar  -s:%~dp0StructureMap.xml -xsl:%~dp0structuremap2erm.xslt -o:%~dp0structuremap2erm.gv

echo .
echo GV done.

%~dp0..\bin-win\graphviz\dot.exe -Tsvg %~dp0structuremap2erm.gv -O

echo .
echo SVG done.

%~dp0..\bin-win\graphviz\dot.exe -Tpng %~dp0structuremap2erm.gv -O

echo .
echo PNG done.

echo .
echo .
