Write-Output "..."

<# TODO: get structure file as CL parameter #>
<# TODO: get structure from REST web service as alternative (CL parameter with URL)#>
java -jar $PSScriptRoot/../bin-java/SaxonHE/saxon-he-10.3.jar -s:$PSScriptRoot/StructureMap.xml -xsl:$PSScriptRoot/structuremap2erm.xslt -o:$PSScriptRoot/structuremap2erm.gv

Write-Output ""
Write-Output "GV done."
Write-Output ""

IF($IsWindows) {
    Write-Output "Running on Windows: local portable graphviz used..."
    & $PSScriptRoot/../bin-win/graphviz/dot.exe -Tsvg $PSScriptRoot/structuremap2erm.gv -O
    & $PSScriptRoot/../bin-win/graphviz/dot.exe -Tpng $PSScriptRoot/structuremap2erm.gv -O
} ELSEIF($IsLinux) {
    Write-Output "Running on Linux: trying installed graphviz package..."
    try {
        & dot -Tsvg $PSScriptRoot/structuremap2erm.gv -O
        & dot -Tpng $PSScriptRoot/structuremap2erm.gv -O            
    }
    catch {
        Write-Output "Conversion failed, is graphviz installed? Install graphviz depending on your distro: "
        Write-Output "   Debian: sudo apt-get install graphviz"
        Write-Output ""
        throw "script terminated. astalavista baby."
    }
}

Write-Output ""
Write-Output "Conversion done."

Write-Output ""
Write-Output ""
