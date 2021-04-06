<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
>

	<!-- maximum number of characters to cut to -->
	<xsl:param name="maxLength" select="15" />

	<!-- TODO: add correct SDMX mime type --><xsl:output method="xml" media-type="application/xml"/>

	<xsl:template match="@*|node()">
		<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
	</xsl:template>

	<xsl:template match="//*[local-name()='Obs']/@OBS_VALUE">
		<xsl:choose>
			<xsl:when test="string-length(.)>$maxLength">
				<!-- check for decimal point position in string -->
				<xsl:variable name="dotPos" select="string-length(substring-before(., '.'))+1"/>
				<xsl:variable name="decimalFormat"><xsl:value-of select="string-join((for $i in 1 to ($maxLength - $dotPos) return '#'),'')" /></xsl:variable>
				<xsl:attribute name="OBS_VALUE"><xsl:value-of select="format-number(.,concat('0.',$decimalFormat))" /></xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="OBS_VALUE"><xsl:value-of select="." /></xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>