#Requires -Version 7
<# enable support for verbose mode #>
[CmdletBinding(SupportsShouldProcess=$true)]
Param()

Write-Output "..."

<# global variables #>
    <# operating system output info #>
    $osString =
        if($IsWindows) { (Get-CimInstance -ClassName CIM_OperatingSystem).Caption +
            " ("+(Get-CimInstance -ClassName CIM_OperatingSystem).Version+" " +
            (Get-CimInstance -ClassName CIM_OperatingSystem).OSArchitecture+")" +
            " on "+(Get-CimInstance -ClassName CIM_OperatingSystem).CSName
        } else { Invoke-Expression "uname -a" }
    <# executable for graphviz: for Windows, use local portable version, for others assume installed version in path #>
    $global:graphvizExe = 
        if($IsWindows) { "$PSScriptRoot/../bin-win/graphviz/dot.exe" }
        else { "dot" }
<# /global #>

Write-Verbose ""
Write-Verbose ""
Write-Verbose "Detected OS: $osString"

<# verbose OS choice for DOT executable #>
IF($IsWindows) { Write-Verbose "Running on Windows: local portable graphviz used..." } 
ELSE { Write-Verbose "Running on non-Windows OS: trying installed graphviz package..." }

<# testing prerequists #>
try {
    Write-Verbose "Testing DOT: $global:graphvizExe -V"
    Invoke-Expression "$global:graphvizExe -V" <# this is currently not silent #>
    <# TODO: silence output in non-verbose mode this Out-Null below did not work #>
    <# 
    if($VerbosePreference -eq "SilentlyContinue") { 
        Invoke-Expression "$global:graphvizExe -V" | Out-Null        
    } else { 
        Invoke-Expression "$global:graphvizExe -V"
    }
    #>
} catch {
    Write-Output "For some reason graphviz failed, is graphviz installed?"
    Write-Output "On Linux, install graphviz depending on your distro: "
    Write-Output "   Debian: sudo apt-get install graphviz"
    Write-Output "" 
    Write-Output "On Windows, check why the portable version is not working:"
    Write-Output "   $global:graphvizExe -V"
    Write-Output ""
    throw "script terminated. astalavista baby."
}

<# TODO: get structure file as CL parameter #>
<# TODO: get structure from REST web service as alternative (CL parameter with URL)#>
<# sample URL: http://localhost:8080/ws/public/sdmxapi/rest/categorisation/SIMM/all/latest/?format=sdmx-2.1&detail=full&references=all&prettyPrint=true #>

java -jar $PSScriptRoot/../bin-java/SaxonHE/saxon-he-10.3.jar -s:$PSScriptRoot/StructureMap.xml -xsl:$PSScriptRoot/structuremap2erm.xslt -o:$PSScriptRoot/StructureMap.gv

Write-Verbose "SDMX -> GV done."

Invoke-Expression "$global:graphvizExe -Tsvg $PSScriptRoot/StructureMap.gv -O"
Write-Verbose "GV -> SVG done."

Invoke-Expression "$global:graphvizExe -Tpng $PSScriptRoot/StructureMap.gv -O"
Write-Verbose "GV -> PNG done."

Write-Output ""
Write-Output "Conversion done."

Write-Output ""
Write-Output ""
