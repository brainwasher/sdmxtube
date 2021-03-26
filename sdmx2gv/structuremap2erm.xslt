<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
	xmlns:mes="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message" 
	xmlns:str="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/structure" 
	xmlns:com="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common"
>
	<xsl:output method="text" media-type="text/vnd.graphviz"/>

	<!-- as the base REST URL of the registry here. That will add the REST links to the artefacts in the graph (not supported in PNG, use SVG) -->
	<xsl:variable name="registryRestUrl">https://registry.sdmx.org/ws/public/sdmxapi/rest</xsl:variable>

	<!--
		the key stores the concepts by @id in order to look them up later.
		FIXME: in case concepts from different concept schemes have the same @id, this creates wrong output (@id is not unique across concept schemes)
	-->
	<xsl:key name="concept" match="str:ConceptScheme//str:Concept" use="@id" />

	<xsl:template match="/">
		<!-- draw directed graph from left to right (LR) -->
		<xsl:text>digraph DependecyMap { rankdir=LR;</xsl:text>
		<xsl:apply-templates />
		<xsl:text>}</xsl:text>
	</xsl:template>

	<!-- header is ignored -->
	<xsl:template match="mes:Header" />

	<!-- scan structures -->
	<xsl:template match="mes:Structures">
		<!-- loop through DSDs -->
		<xsl:for-each select=".//str:DataStructure">
			<!-- DSD-Agency:Name(Version) -->
			"<xsl:value-of select="@agencyID" />:<xsl:value-of select="@id" />(<xsl:value-of select="@version" />)"
			[shape=record,
				URL="<xsl:value-of select="$registryRestUrl"/>/datastructure/<xsl:value-of select="@agencyID" />/<xsl:value-of select="@id" />/<xsl:value-of select="@version" />",
				target=_blank,
				label="
					{<xsl:value-of select="@agencyID" />|<xsl:value-of select="@id" />|<xsl:value-of select="@version" />}
					<xsl:for-each select=".//str:DimensionList/str:Dimension"> 
						<xsl:call-template name="conceptLabel">
							<xsl:with-param name="conceptNode" select="."/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:for-each select=".//str:AttributeList/str:Attribute">
						<xsl:call-template name="conceptLabel">
							<xsl:with-param name="conceptNode" select="."/>
						</xsl:call-template>
					</xsl:for-each>
				",
			];
		</xsl:for-each>

		<!-- loop through structure maps for creating connectors -->
		<xsl:for-each select=".//str:StructureMap">
			"<xsl:value-of select="./str:Target/Ref/@agencyID" />:<xsl:value-of select="./str:Target/Ref/@id" />(<xsl:value-of select="./str:Target/Ref/@version" />)":<xsl:value-of select="./str:ComponentMap/str:Source/Ref/@id" />
			->
			"<xsl:value-of select="./str:Source/Ref/@agencyID" />:<xsl:value-of select="./str:Source/Ref/@id" />(<xsl:value-of select="./str:Source/Ref/@version" />)":<xsl:value-of select="./str:ComponentMap/str:Source/Ref/@id" />
			<!-- TODO: the below is only an example, it still needs to be replaced with the real symbols depending on the annotations -->
			<!-- arrowstyles: https://www.graphviz.org/doc/info/arrows.html -->
			[dir="both" arrowhead="crowodot", arrowtail="teetee"]
		</xsl:for-each>
	</xsl:template>

	<!-- template to display a concept within an entity -->
	<xsl:template name="conceptLabel">
		<!-- conceptNode is the XPath node for processing -->
		<xsl:param name="conceptNode" />
		|{
			&lt;<xsl:value-of select="$conceptNode/@id" />&gt; 
			<xsl:value-of select="substring(local-name($conceptNode),1,3)" /> - 
			<xsl:value-of select="$conceptNode/str:ConceptIdentity/Ref/@agencyID" />.<xsl:value-of select="$conceptNode/str:ConceptIdentity/Ref/@maintainableParentID" />:<xsl:value-of select="$conceptNode/@id" />
			\n<xsl:value-of select="key('concept',$conceptNode/str:ConceptIdentity/Ref/@id)" />
		}
	</xsl:template>

</xsl:stylesheet>