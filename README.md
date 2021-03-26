# sdmxtube
SDMX-related tools, scripts and ideas. Why? Because I can...

## sdmxtube projects
* **bin-java**: binaries (jar files) for Java (should be cross-platform)
* **bin-win**: binaries for Windows
* **lib**: library, with one subfolder per technology
* **sdmx2gv**: SDMX to GraphViz DOT visualisations of SDMX artefacts as a graph
  * _structuremap2erm_: takes an SDMX _StructureMap_ artefact and generates an entity relationship model with support for the ECB draft controlled annotations for cardinalities (linked ot the _ComponentMap_) 
* **xslt-test**: a little playground for XSLT scripting - you may choose to ignore if you are beyond "hello world" in XSLT...

## how branches are used
* **main**: only tested and production ready code goes here. Take stuff from here if you like it stable
* **sandbox**: as the name suggests, that branch is to play aaround with stuff. Things here might or might not make sense. Don't ask, just play
* **dev-\***: those branches are dev branches for a specific project (e.g. dev-sdmx2gv for developing stuff for the sdmx2gv project)

## further reading
* **Clickable SDMX**: check out the clickable SDMX page to dive into the SDMX IM and make sure that you are literate in UML before you do so... (https://statswiki.unece.org/display/ClickSDMX/Clickable+SDMX+Home)
* **PowerShell**: PowerShell 7 suppports Windows and Linux. Thus, scripts are written in PowerShell and not in bash or cmd. Deal with it. Install PowerShell: (https://aka.ms/powershell) 
