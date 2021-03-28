Write-Output "..."

java -jar $PSScriptRoot/../bin-java/SaxonHE/saxon-he-10.3.jar -s:$PSScriptRoot/simple.xml -xsl:$PSScriptRoot/simple.xslt -o:$PSScriptRoot/simple.txt

Write-Output ""
Write-Output "Done."
Write-Output ""
Write-Output "Output:"
Write-Output ""
Get-Content simple.txt
Write-Output ""