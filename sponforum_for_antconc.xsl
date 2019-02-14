<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" />
		<xsl:template match="text">
				<text>
						<xsl:attribute name="title">
					<xsl:value-of select="//title"/>
				</xsl:attribute>
						<xsl:attribute name="url">
					<xsl:value-of select="//url"/>
				</xsl:attribute>
						<xsl:attribute name="date">
					<xsl:value-of select="//date"/>
				</xsl:attribute>
						<xsl:attribute name="teaser">
					<xsl:value-of select="//teaser"/>
				</xsl:attribute>
						<xsl:apply-templates/>
				</text>
		</xsl:template>
	<xsl:template match="comment">
		<comment>
			<xsl:apply-templates/>
		</comment>
	</xsl:template>
		<xsl:template match="*|text()">
		<xsl:apply-templates/>
	</xsl:template>	
	<xsl:template match="comment_title">
	<h1>
		<xsl:value-of select="normalize-space(.)"/>
	</h1>
	</xsl:template>
	<xsl:template match="comment_p">
	<p>
		<xsl:value-of select="normalize-space(.)"/>
	</p>
	</xsl:template>
</xsl:stylesheet>
