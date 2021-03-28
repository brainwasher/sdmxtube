echo "..."

<# TODO: get structure file as CL parameter #>
<# TODO: get structure from REST web service as alternative (CL parameter with URL)#>
java -jar $PSScriptRoot/../bin-java/SaxonHE/saxon-he-10.3.jar -s:$PSScriptRoot/StructureMap.xml -xsl:$PSScriptRoot/structuremap2erm.xslt -o:$PSScriptRoot/structuremap2erm.gv

echo ""
echo "GV done."
echo ""

IF($IsWindows) {
    echo "Using Windows: local portable graphviz supported."
    & $PSScriptRoot/../bin-win/graphviz/dot.exe -Tsvg $PSScriptRoot/structuremap2erm.gv -O
    & $PSScriptRoot/../bin-win/graphviz/dot.exe -Tpng $PSScriptRoot/structuremap2erm.gv -O
} ELSEIF($IsLinux) {
    echo "Using Linux: graphviz needs to be installed."
    echo "In case the conversion fails, install graphviz depending on your distro: "
    echo "   Debian: sudo apt-get install graphviz"
    & dot 
}

echo ""
echo "Conversion done."

echo ""
echo ""
