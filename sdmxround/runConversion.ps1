#Requires -Version 7
<# REQUIREMENTS 
    Windows: Java 1.8
    Linux: Java 1.8
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
    <# path of output file. Default: path of SDMX file is used with extension "output" #>
    $outputFile,
    <# keep the intermediate downloaded input file #>
    [switch] $keepInput
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

<# it is a URI, so try downloading #>

<# check if sdmxFile exists already #>
$randomPath = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName() + ".xml"
if($null -eq $sdmxFile) { 
    $sdmxFile = $randomPath
} else { 
    $isValidPath = Test-Path -Path $sdmxFile -PathType Leaf -IsValid
    $sdmxFile = ($isValidPath -eq $true) ? $sdmxFile : $randomPath
}

Write-Verbose "Using input file path $sdmxFile"

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

$outputFile = ($null -eq $outputFile) ? $sdmxFile -replace "\.xml",".output.xml" : $outputFile
Write-Verbose "converting $sdmxFile -> $outputFile"
java -jar $PSScriptRoot/../bin-java/SaxonHE/saxon-he-10.3.jar -s:$sdmxFile -xsl:$PSScriptRoot/sdmxround.xslt -o:$outputFile

<# clean up if it was temporary #>
if (-not $keepInput -and $sdmxFile.StartsWith([System.IO.Path]::GetTempPath())) {
    Write-Verbose "Removing temporary file $sdmxFile"
    Remove-Item $sdmxFile  
}  else {     
    Write-Verbose "Keeping temporary file $sdmxFile"
}

Write-Output ""
Write-Output "Conversion done, open it with:"
Write-Output " start $outputFile"

Write-Output ""
Write-Output ""
