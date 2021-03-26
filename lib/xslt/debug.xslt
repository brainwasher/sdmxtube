<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <!-- dumps a node to the message buffer
        taken from https://stackoverflow.com/questions/957029/call-xslt-template-with-parameter 
    -->
    <xsl:template name="dumpNode">
      <xsl:param name="node2dump" />
      <xsl:message expand-text="yes">
      ==== Watch Variables ====
          node2dump:     {$node2dump}
      </xsl:message>
      Node:
      <xsl:value-of select="name($node2dump)" />
      :
      <xsl:value-of select="text($node2dump)" />
      <xsl:for-each select="$node2dump/@*">
         Attribute:
         <xsl:value-of select="name()" />
         :
         <xsl:value-of select="." />
      </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>