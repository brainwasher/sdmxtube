echo "..."

java -jar $PSScriptRoot/../bin-java/SaxonHE/saxon-he-10.3.jar -s:$PSScriptRoot/StructureMap.xml -xsl:$PSScriptRoot/structuremap2erm.xslt -o:$PSScriptRoot/structuremap2erm.gv

echo ""
echo "GV done."

& $PSScriptRoot/../bin-win/graphviz/dot.exe -Tsvg $PSScriptRoot/structuremap2erm.gv -O

echo ""
echo "SVG done."

& $PSScriptRoot/../bin-win/graphviz/dot.exe -Tpng $PSScriptRoot/structuremap2erm.gv -O

echo ""
echo "PNG done."

echo ""
echo ""
