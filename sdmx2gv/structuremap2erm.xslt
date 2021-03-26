<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
	xmlns:mes="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message" 
	xmlns:str="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/structure" 
	xmlns:com="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common"
>
	<xsl:output method="text" media-type="text/vnd.graphviz"/>
	<xsl:variable name="registryRestUrl">https://registry.sdmx.org/ws/public/sdmxapi/rest</xsl:variable>

	<xsl:key name="concept" match="str:ConceptScheme//str:Concept" use="@id" />

	<xsl:template match="/">
		<xsl:text>digraph DependecyMap { rankdir=LR;</xsl:text>
		<xsl:apply-templates />
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template match="mes:Header" />

	<xsl:template match="mes:Structures">
		<xsl:for-each select=".//str:DataStructure">
			"<xsl:value-of select="@agencyID" />:<xsl:value-of select="@id" />(<xsl:value-of select="@version" />)"
			[shape=record,
				URL="<xsl:value-of select="$registryRestUrl"/>/datastructure/<xsl:value-of select="@agencyID" />/<xsl:value-of select="@id" />/<xsl:value-of select="@version" />",
				target=_blank,
				label="
					{<xsl:value-of select="@agencyID" />|<xsl:value-of select="@id" />|<xsl:value-of select="@version" />}
					<xsl:for-each select=".//str:DimensionList/str:Dimension"> 
						|{&lt;<xsl:value-of select="@id" />&gt; 
						Dim - <xsl:value-of select="./str:ConceptIdentity/Ref/@agencyID" />.<xsl:value-of select="./str:ConceptIdentity/Ref/@maintainableParentID" />:<xsl:value-of select="@id" />
						<!-- TODO: can we find the label from the concept scheme here?	
						those currently do not work
						\n1<xsl:value-of select="./str:ConceptIdentity/Ref/@maintainableParentID" />,<xsl:value-of select="./str:ConceptIdentity/Ref/@id" />
						\n2<xsl:value-of select="mes:Structures/str:Concepts/str:ConceptScheme[@id=./str:ConceptIdentity/Ref/@maintainableParentID]/Concept[@id=./str:ConceptIdentity/Ref/@id]" />
						\n3<xsl:value-of select="mes:Structures/str:Concepts/str:ConceptScheme[@id='CS_REFERENCE']/Concept[@id='ESI']/com:Name" />
						-->
						\n<xsl:value-of select="key('concept', str:ConceptIdentity/Ref/@maintainableParentID)/com:Name" />
						}
					</xsl:for-each>
					<xsl:for-each select=".//str:AttributeList/str:Attribute">
						|{&lt;<xsl:value-of select="@id" />&gt; 
						Att - <xsl:value-of select="./str:ConceptIdentity/Ref/@agencyID" />.<xsl:value-of select="./str:ConceptIdentity/Ref/@maintainableParentID" />:<xsl:value-of select="@id" />}
					</xsl:for-each>
				",
			];
		</xsl:for-each>
		<xsl:for-each select=".//str:StructureMap">
			"<xsl:value-of select="./str:Target/Ref/@agencyID" />:<xsl:value-of select="./str:Target/Ref/@id" />(<xsl:value-of select="./str:Target/Ref/@version" />)":<xsl:value-of select="./str:ComponentMap/str:Source/Ref/@id" />
			->
			"<xsl:value-of select="./str:Source/Ref/@agencyID" />:<xsl:value-of select="./str:Source/Ref/@id" />(<xsl:value-of select="./str:Source/Ref/@version" />)":<xsl:value-of select="./str:ComponentMap/str:Source/Ref/@id" />
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>