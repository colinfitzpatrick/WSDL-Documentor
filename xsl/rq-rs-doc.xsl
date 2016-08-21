<?xml version="1.0" encoding="ISO-8859-1"?>
<!--

	Copright © 2012 Colin Fitzpatrick

	Generates HTML documentation from a Request or Response XML sample, using a WSDL to descibe the data structure.

	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

	based on:

    XML to HTML Verbatim Formatter with Syntax Highlighting
    Version 1.1
    Contributors: Doug Dicks, added auto-indent (parameter -elements)
                  for pretty-print

    Copyright 2002 Oliver Becker
    ob@obqo.de
 
    Licensed under the Apache License, Version 2.0 (the "License"); 
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing, software distributed
    under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
    CONDITIONS OF ANY KIND, either express or implied. See the License for the
    specific language governing permissions and limitations under the License.

    Alternatively, this software may be used under the terms of the 
    GNU Lesser General Public License (LGPL).
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:verb="http://informatik.hu-berlin.de/xmlverbatim" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="verb xs">
	<xsl:output method="html" omit-xml-declaration="yes" indent="no"/>
	<xsl:param name="indent-elements" select="true()"/>
	<xsl:param name="WSDL"/>
	<xsl:param name="TITLE" select="'Request/Response Documentation'"/>
	<xsl:param name="css-stylesheet" select="'../../css/rq-rs-doc.css'"/>
	<xsl:param name="select"/>
	<xsl:variable name="schema" select="document($WSDL)"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/" mode="xmlverbwrapper"/>
	</xsl:template>

	<xsl:template match="/" mode="xmlverbwrapper">
		<html>
			<head>
				<title>
					<xsl:value-of select="$TITLE"/>
				</title>
				<link rel="stylesheet" type="text/css" href="{$css-stylesheet}"/>
			</head>
			<body class="xmlverb-default">
				<tt>
					<xsl:choose>
						<!-- "select" parameter present? -->
						<xsl:when test="$select">
							<xsl:apply-templates mode="xmlverbwrapper"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="." mode="xmlverb"/>
						</xsl:otherwise>
					</xsl:choose>
				</tt>
			</body>
		</html>
		<xsl:text>&#xA;</xsl:text>
	</xsl:template>
	
	<xsl:template match="*" mode="xmlverbwrapper">
		<xsl:choose>
			<xsl:when test="name()=$select">
				<!-- switch to render mode -->
				<!-- print indent -->
				<span class="xmlverb-text">
					<xsl:call-template name="preformatted-output">
						<xsl:with-param name="text">
							<xsl:call-template name="find-last-line">
								<xsl:with-param name="text" select="preceding-sibling::node()[1][self::text()]"/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</span>
				<!-- print element -->
				<xsl:apply-templates select="." mode="xmlverb"/>
				<br/>
				<br/>
			</xsl:when>
			<xsl:otherwise>
				<!-- look for the selected element among the children -->
				<xsl:apply-templates select="*" mode="xmlverbwrapper"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
<!-- return the last line (after newline) in parameter $text -->	
	<xsl:template name="find-last-line">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text,'&#xA;')">
				<xsl:call-template name="find-last-line">
					<xsl:with-param name="text" select="substring-after($text,'&#xA;')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="/" mode="xmlverb">
		<xsl:text>&#xA;</xsl:text>
		<xsl:comment>
			<xsl:text> converted by xmlverbatim.xsl 1.1, (c) O. Becker </xsl:text>
		</xsl:comment>
		<xsl:text>&#xA;</xsl:text>
		<div class="xmlverb-default">
			<table>
				<xsl:apply-templates mode="xmlverb">
					<xsl:with-param name="indent-elements" select="$indent-elements"/>
				</xsl:apply-templates>
			</table>
		</div>
		<xsl:text>&#xA;</xsl:text>
	</xsl:template>

	<!-- wrapper -->
	<xsl:template match="verb:wrapper">
		<xsl:apply-templates mode="xmlverb">
			<xsl:with-param name="indent-elements" select="$indent-elements"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="verb:wrapper" mode="xmlverb">
		<xsl:apply-templates mode="xmlverb">
			<xsl:with-param name="indent-elements" select="$indent-elements"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- element nodes -->
	<xsl:template match="*" mode="xmlverb">
		<xsl:param name="indent-elements" select="false()"/>
		<xsl:param name="indent" select="''"/>
		<xsl:param name="indent-increment" select="'&#xA0;&#xA0;'"/>
		<xsl:variable name="element-name" select="local-name()"/>
		<xsl:variable name="ns-prefix" select="substring-before(name(),':')"/>

		<tr>
			<td>
				<xsl:if test="$indent-elements">
					<xsl:value-of select="$indent"/>
				</xsl:if>
				<xsl:text>&lt;</xsl:text>
				<xsl:if test="$ns-prefix != ''">
					<span class="xmlverb-element-nsprefix">
						<xsl:value-of select="$ns-prefix"/>
					</span>
					<xsl:text>:</xsl:text>
				</xsl:if>
				<span class="xmlverb-element-name">
					<xsl:value-of select="local-name()"/>
				</span>
				<xsl:variable name="pns" select="../namespace::*"/>
				<xsl:if test="$pns[name()=''] and not(namespace::*[name()=''])">
					<span class="xmlverb-ns-name">
						<xsl:text> xmlns</xsl:text>
					</span>
					<xsl:text>=&quot;&quot;</xsl:text>
				</xsl:if>
				<xsl:for-each select="namespace::*">
					<xsl:if test="not($pns[name()=name(current()) and .=current()])">
						<xsl:call-template name="xmlverb-ns"/>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="count(@*) = 0 and not(node())">
					<xsl:text>/&gt;</xsl:text>
				</xsl:if>
				<xsl:if test="count(@*) = 0 and node()">
					<xsl:text>&gt;</xsl:text>
				</xsl:if>				
			</td>
			<td>
				<span class="xmlverb-comment">
					<xsl:text> </xsl:text>
					<xsl:choose>
						<xsl:when test="$schema//xs:element[@name=$element-name]/xs:annotation/xs:documentation">
							<xsl:value-of select="$schema//xs:element[@name=$element-name]/xs:annotation/xs:documentation"/>
						</xsl:when>
						<!-- <xsl:otherwise>
					<xsl:text>TODO</xsl:text>
				</xsl:otherwise>-->
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$schema//xs:element[@name=$element-name]/@minOccurs = 0">
							<xsl:text> [OPTIONAL] </xsl:text>
						</xsl:when>
						<!-- <xsl:otherwise>
					<xsl:text> [REQUIRED] </xsl:text>
				</xsl:otherwise> -->
					</xsl:choose>
				</span>
			</td>
		</tr>
		<!-- 
			Determine the parent element of the attribute.
		-->
		<xsl:if test="count(@*) > 0">

			<xsl:choose>
				<xsl:when test="$schema//xs:element[@name=$element-name]/@type">
					<xsl:variable name="wsdl-doc-root" select="$schema//xs:complexType[@name = $schema//xs:element[@name=$element-name]/@type] "/>
					<xsl:for-each select="@*">
						<xsl:call-template name="xmlverb-attrs">
							<xsl:with-param name="indent" select="concat($indent, $indent-increment)"/>
							<xsl:with-param name="wsdl-doc-root" select="$wsdl-doc-root"/>
							<xsl:with-param name="attr-element" select="$element-name"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="$schema//xs:element[@name=$element-name]/xs:complexType">
					<xsl:variable name="wsdl-doc-root" select="$schema//xs:element[@name=$element-name]/xs:complexType"/>
					<xsl:for-each select="@*">
						<xsl:call-template name="xmlverb-attrs">
							<xsl:with-param name="indent" select="concat($indent, $indent-increment)"/>
							<xsl:with-param name="wsdl-doc-root" select="$wsdl-doc-root"/>
							<xsl:with-param name="attr-element" select="$element-name"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="@*">
						<xsl:call-template name="xmlverb-attrs">
							<xsl:with-param name="indent" select="concat($indent, $indent-increment)"/>
							<xsl:with-param name="attr-element" select="$element-name"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="node()">
				<xsl:if test="count(@*) > 0">
					<tr>
						<td colspan="2">
							<xsl:value-of select="$indent"/>
							<xsl:text> &gt;</xsl:text>
						</td>
					</tr>
				</xsl:if>
				<xsl:apply-templates mode="xmlverb">
					<xsl:with-param name="indent-elements" select="$indent-elements"/>
					<xsl:with-param name="indent" select="concat($indent, $indent-increment)"/>
					<xsl:with-param name="indent-increment" select="$indent-increment"/>
				</xsl:apply-templates>
				<tr>
					<td colspan="2">
						<xsl:value-of select="$indent"/>
						<xsl:text>&lt;/</xsl:text>
						<xsl:if test="$ns-prefix != ''">
							<span class="xmlverb-element-nsprefix">
								<xsl:value-of select="$ns-prefix"/>
							</span>
							<xsl:text>:</xsl:text>
						</xsl:if>
						<span class="xmlverb-element-name">
							<xsl:value-of select="local-name()"/>
						</span>
						<xsl:text>&gt;</xsl:text>
					</td>
				</tr>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="count(@*) > 0">
					<tr>
						<td colspan="2">
							<xsl:value-of select="$indent"/>
							<xsl:text> /&gt;</xsl:text>
						</td>
					</tr>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- attribute nodes -->
	<xsl:template name="xmlverb-attrs">
		<xsl:param name="indent" select="''"/>
		<xsl:param name="wsdl-doc-root" select="$schema"/>
		<xsl:param name="attr-element" select="''"/>
		<xsl:variable name="attrs-name" select="name()"/>
		<tr>
			<td>
				<xsl:value-of select="$indent"/>
				<xsl:text> </xsl:text>
				<span class="xmlverb-attr-name">
					<xsl:value-of select="name()"/>
				</span>
				<xsl:text>=</xsl:text><wbr/><xsl:text>&quot;</xsl:text>
				<xsl:variable name="attr-text">
					<xsl:call-template name="html-replace-entities">
						<xsl:with-param name="text" select="normalize-space(.)"/>
						<xsl:with-param name="attrs" select="true()"/>
					</xsl:call-template>
				</xsl:variable>
				<span class="xmlverb-attr-content">
					<xsl:value-of select="$attr-text"/>
				</span>
				<xsl:text>&quot;</xsl:text>
			</td>
			<td>
				<span class="xmlverb-comment">
					<xsl:choose>
						<!-- <xsl:when test="$schema//xs:attribute[@name=$attrs-name]/xs:annotation/xs:documentation[not(xs:documentation = preceding-sibling::xs:annotation/xs:documentation)]"> -->
						<xsl:when test="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/xs:annotation/xs:documentation">
							<xsl:value-of select="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/xs:annotation/xs:documentation"/>
						</xsl:when>
						<!--<xsl:otherwise>
					<xsl:text>TODO</xsl:text>
				</xsl:otherwise>-->
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/@use='optional'">
							<xsl:text> [Optional] </xsl:text>
						</xsl:when>
						<!-- <xsl:otherwise>
					<xsl:text> [REQUIRED] </xsl:text>
				</xsl:otherwise> -->
					</xsl:choose>
					<xsl:if test="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/@type">
						<xsl:choose>
							<xsl:when test="contains($wsdl-doc-root//xs:attribute[@name=$attrs-name]/@type,':')">
						[<xsl:value-of select="substring-after($wsdl-doc-root//xs:attribute[@name=$attrs-name]/@type,':')"/>]
					</xsl:when>
							<xsl:otherwise>
						[<xsl:value-of select="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/@type"/>]
					</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/xs:simpleType/xs:restriction/xs:enumeration">
						<xsl:variable name="calc-unique-attr" select="$wsdl-doc-root//xs:attribute[@name=$attrs-name]"/>
						<xsl:variable name="unique-attr" select="$calc-unique-attr[1]"/>
						<xsl:if test="$unique-attr/xs:simpleType/xs:restriction/xs:enumeration">
							<br/>Choose from:
							<ul>
								<xsl:for-each select="$unique-attr/xs:simpleType/xs:restriction/xs:enumeration">
									<li>
										<xsl:choose>
											<xsl:when test="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/@default = @value">
												<b>"<xsl:value-of select="@value"/>"</b>(Default)
											</xsl:when>
											<xsl:otherwise>
												"<xsl:value-of select="@value"/>"
											</xsl:otherwise>
										</xsl:choose>
										<xsl:if test="xs:annotation/xs:documentation">
											(<xsl:value-of select="xs:annotation/xs:documentation"/>)
										</xsl:if>
									</li>
								</xsl:for-each>
							</ul>
						</xsl:if>
					</xsl:if>
					<xsl:if test="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/xs:simpleType/xs:restriction/xs:minInclusive/@value">
						[Min=<xsl:value-of select="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/xs:simpleType/xs:restriction/xs:minInclusive/@value"/>]
					</xsl:if>
					<xsl:if test="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/xs:simpleType/xs:restriction/xs:maxInclusive/@value">
						[Max=<xsl:value-of select="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/xs:simpleType/xs:restriction/xs:maxInclusive/@value"/>]	
					</xsl:if>
					<xsl:if test="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/@default">
						[Default=<xsl:value-of select="$wsdl-doc-root//xs:attribute[@name=$attrs-name]/@default"/>]	
					</xsl:if>
				</span>
			</td>
		</tr>
	</xsl:template>

	<!-- namespace nodes -->
	<xsl:template name="xmlverb-ns">
		<xsl:if test="name()!='xml'">
			<span class="xmlverb-ns-name">
				<xsl:text> xmlns</xsl:text>
				<xsl:if test="name()!=''">
					<xsl:text>:</xsl:text>
				</xsl:if>
				<xsl:value-of select="name()"/>
			</span>
			<xsl:text>=</xsl:text><wbr/><xsl:text>&quot;</xsl:text>
			<span class="xmlverb-ns-uri">
				<xsl:call-template name="clean-urn">
				  <xsl:with-param name="text" select="." />
				</xsl:call-template>			
			</span>
			<xsl:text>&quot;</xsl:text>
		</xsl:if>
	</xsl:template>

<!-- adds <wbr> to the dots in a namespace for better line breaking -->
 <xsl:template name="clean-urn">
    <xsl:param name="text" />
    <xsl:choose>
      <xsl:when test="contains($text, '.')">
        <xsl:value-of select="substring-before($text,'.')" />
        <xsl:text>.</xsl:text><wbr/>
        <xsl:call-template name="clean-urn">
          <xsl:with-param name="text" select="substring-after($text,'.')" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

	<!-- text nodes -->
	<xsl:template match="text()" mode="xmlverb">
		<xsl:param name="indent" select="." />

		<xsl:variable name="nodeText">
			<xsl:call-template name="preformatted-output">
				<xsl:with-param name="text">
					<xsl:call-template name="html-replace-entities">
						<xsl:with-param name="text" select="normalize-space(.)"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:if test="string-length($nodeText) > 0">
			<tr>
				<td colspan="2">
					<xsl:value-of select="$indent"/>
					<span class="xmlverb-text">
						<xsl:value-of select="$nodeText"/>
					</span>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>

	<!-- comments -->
	<xsl:template match="comment()" mode="xmlverb">
		<xsl:text>&lt;!--</xsl:text>
		<span class="xmlverb-comment">
			<xsl:call-template name="preformatted-output">
				<xsl:with-param name="text" select="."/>
			</xsl:call-template>
		</span>
		<xsl:text>--&gt;</xsl:text>
		<xsl:if test="not(parent::*)">
			<br/>
			<xsl:text>&#xA;</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- processing instructions -->
	<xsl:template match="processing-instruction()" mode="xmlverb">
		<xsl:text>&lt;?</xsl:text>
		<span class="xmlverb-pi-name">
			<xsl:value-of select="name()"/>
		</span>
		<xsl:if test=".!=''">
			<xsl:text> </xsl:text>
			<span class="xmlverb-pi-content">
				<xsl:value-of select="."/>
			</span>
		</xsl:if>
		<xsl:text>?&gt;</xsl:text>
		<xsl:if test="not(parent::*)">
			<br/>
			<xsl:text>&#xA;</xsl:text>
		</xsl:if>
	</xsl:template>
	<!-- =========================================================== -->
	<!--                    Procedures / Functions                   -->
	<!-- =========================================================== -->

	<!-- generate entities by replacing &, ", < and > in $text -->
	<xsl:template name="html-replace-entities">
		<xsl:param name="text"/>
		<xsl:param name="attrs"/>
		<xsl:variable name="tmp">
			<xsl:call-template name="replace-substring">
				<xsl:with-param name="from" select="'&gt;'"/>
				<xsl:with-param name="to" select="'&amp;gt;'"/>
				<xsl:with-param name="value">
					<xsl:call-template name="replace-substring">
						<xsl:with-param name="from" select="'&lt;'"/>
						<xsl:with-param name="to" select="'&amp;lt;'"/>
						<xsl:with-param name="value">
							<xsl:call-template name="replace-substring">
								<xsl:with-param name="from" select="'&amp;'"/>
								<xsl:with-param name="to" select="'&amp;amp;'"/>
								<xsl:with-param name="value" select="$text"/>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<!-- $text is an attribute value -->
			<xsl:when test="$attrs">
				<xsl:call-template name="replace-substring">
					<xsl:with-param name="from" select="'&#xA;'"/>
					<xsl:with-param name="to" select="'&amp;#xA;'"/>
					<xsl:with-param name="value">
						<xsl:call-template name="replace-substring">
							<xsl:with-param name="from" select="'&quot;'"/>
							<xsl:with-param name="to" select="'&amp;quot;'"/>
							<xsl:with-param name="value" select="$tmp"/>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tmp"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- replace in $value substring $from with $to -->

	<xsl:template name="replace-substring">
		<xsl:param name="value"/>
		<xsl:param name="from"/>
		<xsl:param name="to"/>
		<xsl:choose>
			<xsl:when test="contains($value,$from)">
				<xsl:value-of select="substring-before($value,$from)"/>
				<xsl:value-of select="$to"/>
				<xsl:call-template name="replace-substring">
					<xsl:with-param name="value" select="substring-after($value,$from)"/>
					<xsl:with-param name="from" select="$from"/>
					<xsl:with-param name="to" select="$to"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- preformatted output: space as &nbsp;, tab as 8 &nbsp;
                             nl as <br> -->
	<xsl:template name="preformatted-output">
		<xsl:param name="text"/>
		<xsl:call-template name="output-nl">
			<xsl:with-param name="text">
				<xsl:call-template name="replace-substring">
					<xsl:with-param name="value" select="translate($text,' ','&#xA0;')"/>
					<xsl:with-param name="from" select="'&#9;'"/>
					<xsl:with-param name="to" select="'&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;'"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- output nl as <br> -->
	<xsl:template name="output-nl">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text,'&#xA;')">
				<xsl:value-of select="substring-before($text,'&#xA;')"/>
				<br/>
				<xsl:text>&#xA;</xsl:text>
				<xsl:call-template name="output-nl">
					<xsl:with-param name="text" select="substring-after($text,'&#xA;')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
