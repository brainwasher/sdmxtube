echo "..."

java -jar $PSScriptRoot/../bin-java/SaxonHE/saxon-he-10.3.jar -s:$PSScriptRoot/simple.xml -xsl:$PSScriptRoot/simple.xslt -o:$PSScriptRoot/simple.txt

echo ""
echo "Done."
echo ""
echo "Output:"
echo ""
Get-Content simple.txt
echo ""