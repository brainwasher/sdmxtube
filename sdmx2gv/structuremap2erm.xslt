<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
	xmlns:mes="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/message" 
	xmlns:str="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/structure" 
	xmlns:com="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common"
>
	<xsl:output method="text" media-type="text/vnd.graphviz"/>
	<xsl:include href="../lib/xslt/libsdmx.xslt"/><!-- SDMX library -->

	<!-- as the base REST URL of the registry here with trailing /.  -->
	<!-- That will add the REST links to the artefacts in the graph (e.g. SVG output) -->
	<!-- the default value points to the standard Docker image config of Fusion Metadata Registry -->
	<xsl:param name="registryRestEndpoint" select="'http://localhost:8080/ws/public/sdmxapi/rest/'" />

	<!--
		the key stores the concepts by @id in order to look them up later.
		TODO: in case concepts from different concept schemes have the same @id, this creates wrong output (@id is not unique across concept schemes)
	-->
	<xsl:key name="concept" match="str:ConceptScheme//str:Concept" use="@id" />
	<!-- 
		TODO: do we need them for clusters?
		the key stores the structuremaps by @id
	-->
	<!-- <xsl:key name="categorisation" match="//str:Categorisation/str:Source/Ref[@class='StructureSet']" use="@id" /> -->

	<xsl:template match="/">
		<!-- draw directed graph from left to right (LR) -->
		<xsl:text>digraph DependecyMap { rankdir=LR; label="\n\n\nEntity Relationship Model\n\ngenerated </xsl:text>
		<xsl:value-of select="current-dateTime()" />
		<xsl:text>"; </xsl:text>
		<xsl:apply-templates />
		<xsl:text>}</xsl:text>
	</xsl:template>

	<!-- header is ignored -->
	<xsl:template match="mes:Header" />

	<!-- scan structures -->
	<xsl:template match="mes:Structures">

		<!-- loop through DSDs to create entities -->
		<xsl:for-each select=".//str:DataStructure">
			<!-- DSD-Agency:Name(Version) as node identifier -->
			<xsl:text>"</xsl:text>
			<xsl:call-template name="artefactIdentifier"><xsl:with-param name="artefactNode" select="."/></xsl:call-template>
			<xsl:text>"</xsl:text>
			<!-- rounded rectangle record node with DSD name and description (if existing) as tooltip -->
			[shape=Mrecord,
				<xsl:text>tooltip="</xsl:text>
					<xsl:value-of select="./com:Name" />
					<xsl:if test="exists(./com:Description)">\n\n<xsl:value-of select="./com:Description" /></xsl:if>
				<xsl:text>"</xsl:text>
				,
				URL="<xsl:value-of select="$registryRestEndpoint"/>datastructure/<xsl:value-of select="@agencyID" />/<xsl:value-of select="@id" />/<xsl:value-of select="@version" />",
				target=_blank,
				label=" <!-- TODO: convert to HTML label and all text to HTML table to support enhanced formatting ( label=< instead of label=" ) -->

					<!-- DSD identifier -->
					{<xsl:value-of select="@agencyID" />|<xsl:value-of select="@id" />|<xsl:value-of select="@version" />}

					<!-- all dimensions -->
					<xsl:for-each select=".//str:DimensionList/str:Dimension | .//str:DimensionList/str:TimeDimension"> 
						<xsl:call-template name="conceptLabel">
							<xsl:with-param name="conceptNode" select="."/>
						</xsl:call-template>
					</xsl:for-each>

					<!-- all attributes -->
					<xsl:for-each select=".//str:AttributeList/str:Attribute">
						<xsl:call-template name="conceptLabel">
							<xsl:with-param name="conceptNode" select="."/>
						</xsl:call-template>
					</xsl:for-each>

					<!-- INFO: measures are left out because there is no good support in SDMX 2.1 -->
				",
			];
		</xsl:for-each>
		
		<!-- TODO: scan category schemes for creating subgraph clusters -->
		<!-- look for "cluster" https://graphviz.org/Gallery/directed/cluster.html -->
		<!-- subgraph cluster_0 { label="Entity Relationship Model" } -->
		<!-- categorisations that contain a StructureSet -->
		<!-- currently only debug info -->
		<!--
		<xsl:for-each select=".//str:Categorisation/str:Source/Ref[@class='StructureSet']">
				<xsl:text>
				// Categorisation </xsl:text>
				<xsl:call-template name="artefactIdentifier"><xsl:with-param name="artefactNode" select="../.."/></xsl:call-template>
				<xsl:text>
				// for StructureSet </xsl:text>	
				<xsl:call-template name="artefactIdentifier"><xsl:with-param name="artefactNode" select="../.."/></xsl:call-template>	
		</xsl:for-each>
		-->

		<!-- loop through structure maps for creating connectors -->
		<xsl:for-each select=".//str:StructureMap">
			"<xsl:value-of select="./str:Target/Ref/@agencyID" />:<xsl:value-of select="./str:Target/Ref/@id" />(<xsl:value-of select="./str:Target/Ref/@version" />)":<xsl:value-of select="./str:ComponentMap[1]/str:Target/Ref/@id" />
			-> <!-- TODO: MAPPINGS: no arrow with two-dashes symbol instead of -> for mappings (search for no existing annotation with cardinaltiy) --> 
			"<xsl:value-of select="./str:Source/Ref/@agencyID" />:<xsl:value-of select="./str:Source/Ref/@id" />(<xsl:value-of select="./str:Source/Ref/@version" />)":<xsl:value-of select="./str:ComponentMap[1]/str:Source/Ref/@id" />
			<xsl:text> [</xsl:text>

			<!-- read cardinality annotations -->


			<xsl:for-each select="./com:Annotations/com:Annotation">
		
				<!-- head or tail -->
				<xsl:choose>
					<xsl:when test="./com:AnnotationType='CARDINALITY_SOURCE2TARGET'">
						<xsl:text> dir="both" arrowtail="</xsl:text>
						<xsl:call-template name="cardinalityArrow">	<xsl:with-param name="AnnotationTitle" select="./com:AnnotationTitle"/></xsl:call-template>
						<xsl:text>" </xsl:text>
					</xsl:when>
					<xsl:when test="./com:AnnotationType='CARDINALITY_TARGET2SOURCE'">
						<xsl:text> arrowhead="</xsl:text>
						<xsl:call-template name="cardinalityArrow">	<xsl:with-param name="AnnotationTitle" select="./com:AnnotationTitle"/></xsl:call-template>
						<xsl:text>" </xsl:text>
					</xsl:when>					
				</xsl:choose>
						
			</xsl:for-each>
			<xsl:text>] </xsl:text>
		</xsl:for-each>
	</xsl:template>

	<!-- template to display a concept within an entity -->
	<xsl:template name="conceptLabel">
		<!-- conceptNode is the XPath node for processing -->
		<xsl:param name="conceptNode" />
		|{
			&lt;<xsl:value-of select="$conceptNode/@id" />&gt; 
			<xsl:value-of select="substring(local-name($conceptNode),1,3)" /> - 
			<xsl:value-of select="$conceptNode/str:ConceptIdentity/Ref/@agencyID" />:<xsl:value-of select="$conceptNode/str:ConceptIdentity/Ref/@maintainableParentID" />(<xsl:value-of select="$conceptNode/str:ConceptIdentity/Ref/@maintainableParentVersion" />).<xsl:value-of select="$conceptNode/@id" />
			\n<xsl:value-of select="key('concept',$conceptNode/str:ConceptIdentity/Ref/@id)/com:Name" />

			<!-- data type reference -->
			<xsl:if test="exists($conceptNode/str:LocalRepresentation/str:TextFormat)">
				<xsl:text> [</xsl:text><xsl:value-of select="$conceptNode/str:LocalRepresentation/str:TextFormat/@textType" /><xsl:text>]</xsl:text>				
			</xsl:if>

			<!-- code list reference -->
			<xsl:if test="exists($conceptNode/str:LocalRepresentation/str:Enumeration)">
				<xsl:text>\n[🧾</xsl:text>
					<xsl:call-template name="artefactIdentifier">
						<xsl:with-param name="artefactNode" select="$conceptNode/str:LocalRepresentation/str:Enumeration/Ref"/>
					</xsl:call-template>
				<xsl:text>]</xsl:text>
			</xsl:if>
		}
	</xsl:template>

	<!-- template for the arrowhead of cardinality annotations -->
	<!-- arrowstyles: https://www.graphviz.org/doc/info/arrows.html -->
	<xsl:template name="cardinalityArrow">
		<xsl:param name="AnnotationTitle" />
		<xsl:choose>
			<xsl:when test="substring($AnnotationTitle,4,1)='N'">
				<xsl:text>crow</xsl:text>
			</xsl:when>
			<xsl:when test="substring($AnnotationTitle,4,1)='1'">
				<xsl:text>tee</xsl:text>
			</xsl:when>			
			<xsl:when test="substring($AnnotationTitle,4,1)='0'">
				<xsl:text>odot</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="substring($AnnotationTitle,1,1)='G'">
				<xsl:text>onormal</xsl:text>
			</xsl:when>
			<xsl:when test="substring($AnnotationTitle,1,1)='N'">
				<xsl:text>crow</xsl:text>
			</xsl:when>
			<xsl:when test="substring($AnnotationTitle,1,1)='1'">
				<xsl:text>tee</xsl:text>
			</xsl:when>			
			<xsl:when test="substring($AnnotationTitle,1,1)='0'">
				<xsl:text>odot</xsl:text>
			</xsl:when>			
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>