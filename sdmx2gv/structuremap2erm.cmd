@echo off
echo ...

%~dp0..\bin-win\libxml\xsltproc.exe %~dp0structuremap2erm.xslt %~dp0StructureMap.xml > %~dp0structuremap2erm.gv

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
