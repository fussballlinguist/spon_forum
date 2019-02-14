<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>
	<xsl:template match="/">
		<html>
			<meta charset='UTF-8'/>
			<head>
				<title>
					<xsl:value-of select="text/title"/>
				</title>
			</head>
			<h1>
				<xsl:value-of select="text/title"/>
			</h1>
			<table border="1">
				<tr>
					<xsl:for-each select="text/comment[1]/*">
						<th>
							<xsl:value-of select ="local-name()"/>
						</th>
					</xsl:for-each>
				</tr>
				<xsl:for-each select="text/comment">
					<tr>
						<xsl:for-each select="*">
							<td>
								<xsl:value-of select="."/>
							</td>
						</xsl:for-each>
					</tr>
				</xsl:for-each>
			</table>
		</html>
	</xsl:template>
</xsl:stylesheet>
