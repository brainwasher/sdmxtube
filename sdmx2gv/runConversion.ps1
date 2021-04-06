#Requires -Version 7
<# REQUIREMENTS 
    Windows: Java 1.8, runs with portable graphviz
    Linux: Java 1.8, graphviz installed for your distro
    MacOS: not tested
#>
<# enable support for verbose mode #>
[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    <#  structure message to be parsed. this can also be piped into the script either as URL 
        TODO: support SDMX message piped in directly.
        TODO: set as defalt parameter of provided without -sdmx flag
        The default fetches everything form the default URL of a local Docker container with Fusion Registry. 
        Any SDMX 2.1 REST URL that returns at leat a DSD and a StructureSet with a StructureMap and ComponentMap will work
     #>
    [parameter(ValueFromPipeline)] $sdmxUrl,
    <#  name of the XML file used. If sdmxUrl is set, that will be the download file and it will be kept. If sdmxUrl is not set, it will be the file used for conversion #>
    $sdmxFile,
    <# path of output file without extension. In case it is not provided, the path of the SDMX file is used #>
    $outputFile,
    <#  the output format can be any format supported by Graphviz
        https://www.graphviz.org/doc/info/output.html
        Default is SVG
    #>
    $format = "svg",
    <# keep the intermediate GV file #>
    [switch] $keepGV
)

Write-Output "..."

if (($null -eq $sdmxFile) -and ($null -eq $sdmxUrl)) { throw "Either -sdmxUrl or -sdmxFile must be provided"}

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
if($IsWindows) { Write-Verbose "Running on Windows: local portable graphviz used..." } 
elseif($IsLinux) { Write-Verbose "Running on Linux: trying installed graphviz packages..." }
else { Write-Verbose "Running on operating system that was not tested (MacOS?): trying installed graphviz, wget packages..." }

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

<# it is a URI, so try downloading #>

<# check if sdmxFile exists already #>
$randomPath = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName() + ".xml"
if($null -eq $sdmxFile) { 
    $sdmxFile = $randomPath
} else { 
    $isValidPath = Test-Path -Path $sdmxFile -PathType Leaf -IsValid
    $sdmxFile = ($isValidPath -eq $true) ? $sdmxFile : $randomPath
}

Write-Verbose "Using structure file path $sdmxFile"

$sdmxExists = Test-Path -Path $sdmxFile -PathType Leaf

if(($sdmxExists -eq $true) -and ($null -eq $sdmxUrl)) {
    Write-Verbose "File $sdmxFile exists and will be used, skipping download"
} else {
    <# download input file #>
    try {
        Write-Output "Attempting download $sdmxUrl to $sdmxFile..."
        Invoke-RestMethod -Uri $sdmxUrl -OutFile $sdmxFile
    } catch {
        Write-Verbose "Trying to delete $sdmxFile..."
        Remove-Item $sdmxFile   
        throw "REST Call error for $global:inputFile --> $sdmxFile"
    }
}

$outputGV = $sdmxFile -replace "\.xml",".gv"
Write-Verbose "converting $sdmxFile -> $outputGV"
java -jar $PSScriptRoot/../bin-java/SaxonHE/saxon-he-10.3.jar -s:$sdmxFile -xsl:$PSScriptRoot/structuremap2erm.xslt -o:$outputGV

Write-Verbose "SDMX -> GV done."

$outputFile = ($null -eq $outputFile) ? $outputGV -replace "\.gv",".$format" : $outputFile+"."+$format
Write-Verbose "converting $outputGV -> $outputFile"
Invoke-Expression "$global:graphvizExe -T$format $outputGV -o$outputFile"
$format = $format.ToUpper()
Write-Verbose "GV -> $format done."

<# clean up if it was temporary #>
if ($sdmxFile.StartsWith([System.IO.Path]::GetTempPath())) {
    Write-Verbose "Removing temporary file $sdmxFile"
    Remove-Item $sdmxFile  
}  else {     
    Write-Verbose "Keeping temporary file $sdmxFile"
}
if (-not $keepGV) {
    Write-Verbose "Removing temporary file $outputGV"
    Remove-Item $outputGV  
}  else {
    Write-Verbose "Keeping temporary file $outputGV"
}

Write-Output ""
Write-Output "Conversion done, open it with:"
Write-Output " start $outputFile"

Write-Output ""
Write-Output ""
