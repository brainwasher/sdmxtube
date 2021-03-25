<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    
    <xsl:template name="tokenize">
		<xsl:param name="string" select="''"/>
		<xsl:param name="delimiters" select="' &#x9;&#xA;'"/>
		<xsl:choose>
			<!-- Nichts zu tun, wenn der String leer ist -->
			<xsl:when test="not($string)"/>
			<!-- Fehlende Trennzeichen signalisieren eine Token-Aufteilung auf Zeichenebene. -->
			<xsl:when test="not($delimiters)">
			<xsl:call-template name="_tokenize-characters">
				<xsl:with-param name="string" select="$string"/>
			</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
			<xsl:call-template name="_tokenize-delimiters">
				<xsl:with-param name="string" select="$string"/>
				<xsl:with-param name="delimiters" select="$delimiters"/>
			</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:template>
		<xsl:template name="_tokenize-characters">
		<xsl:param name="string"/>
		<xsl:if test="$string">
			<token>
			<xsl:value-of select="substring($string, 1, 1)"/>
			</token>
			<xsl:call-template name="_tokenize-characters">
			<xsl:with-param name="string" select="substring($string, 2)"/>
			</xsl:call-template>
		</xsl:if>
		</xsl:template>
		<xsl:template name="_tokenize-delimiters">
		<xsl:param name="string"/>
		<xsl:param name="delimiters"/>
		<xsl:param name="last-delimit"/>
		<!-- Extrahieren eines Trennzeichens -->
		<xsl:variable name="delimiter" select="substring($delimiters, 1, 1)"/>
		<xsl:choose>
			<!-- Wenn das Trennzeichen leer ist, haben wir ein Token -->
			<xsl:when test="not($delimiter)">
			<token>
				<xsl:value-of select="$string"/>
			</token>
			</xsl:when>
			<!-- Wenn der String wenigstens ein Trennzeichen enthält, müssen wir ihn aufteilen -->
			<xsl:when test="contains($string, $delimiter)">
			<!-- Wenn er mit dem Trennzeichen beginnt, müssen wir den vorhergehenden Teil nicht behandeln -->
			<xsl:if test="not(starts-with($string, $delimiter))">
				<!-- Behandelt den Teil, der vor dem aktuellen Trennzeichen kommt, mit dem nächsten Trennzeichen. Gibt es kein nächstes Trennzeichen, dann entdeckt der erste Test in diesem Template das Token -->
				<xsl:call-template name="_tokenize-delimiters">
				<xsl:with-param name="string" select="substring-before($string, $delimiter)"/>
				<xsl:with-param name="delimiters" select="substring($delimiters, 2)"/>
				</xsl:call-template>
			</xsl:if>
			<!-- Behandelt den Teil, der nach dem Trennzeichen kommt, mit Hilfe des aktuellen Trennzeichens -->
			<xsl:call-template name="_tokenize-delimiters">
				<xsl:with-param name="string" select="substring-after($string, $delimiter)"/>
				<xsl:with-param name="delimiters" select="$delimiters"/>
			</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
			<!-- Keine Vorkommen des aktuellen Trennzeichens, deshalb weitergehen zum nächsten -->
			<xsl:call-template name="_tokenize-delimiters">
				<xsl:with-param name="string" select="$string"/>
				<xsl:with-param name="delimiters" select="substring($delimiters, 2)"/>
			</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>