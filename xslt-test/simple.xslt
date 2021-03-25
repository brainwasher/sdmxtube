<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="UTF-8"/>

<xsl:key name="concept" match="concept" use="concat(@id, '|', @version)" />

<xsl:template match="/root">
    <xsl:for-each select="structures/structure">
        <xsl:text>Structure </xsl:text>
        <xsl:value-of select="@id" />
        <xsl:text>: </xsl:text>
        <xsl:value-of select="key('concept', concat(conceptRef/@id, '|', conceptRef/@version))/name" />
        <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>