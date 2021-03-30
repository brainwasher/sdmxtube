<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
<!-- SDMX library for XSLT -->

<!-- returns the standard format for maintainable artefacts as string: agencyID:id(version) -->
<xsl:template name="artefactIdentifier">
    <xsl:param name="artefactNode" /><!-- node from which the string the taken -->
    <xsl:value-of select="$artefactNode/@agencyID" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="$artefactNode/@id" />
    <xsl:text>(</xsl:text>
    <xsl:value-of select="$artefactNode/@version" />
    <xsl:text>)</xsl:text>
</xsl:template>

</xsl:stylesheet>