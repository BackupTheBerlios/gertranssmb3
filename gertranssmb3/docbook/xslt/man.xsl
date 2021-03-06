<?xml version='1.0'?>
<!-- vim:set sts=2 shiftwidth=2 syntax=xml: -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.0'>

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl"/>

<xsl:param name="chunk.section.depth" select="0"/>
<xsl:param name="chunk.first.sections" select="1"/>
<xsl:param name="use.id.as.filename" select="1"/>
<xsl:param name="base.dir" select="'../manpages/'"/>

<!-- 
    Our ulink stylesheet omits @url part if content was specified
-->
<xsl:template match="ulink">
  <xsl:variable name="content">
    <xsl:apply-templates/>
  </xsl:variable>
  <xsl:if test="$content = ''">
    <xsl:text>: </xsl:text>
  </xsl:if>
  <xsl:if test="$content != ''">
    <xsl:value-of select="$content" />
  </xsl:if>
  <xsl:if test="$content = ''">
    <xsl:apply-templates mode="italic" select="@url" />
  </xsl:if>
</xsl:template>

<xsl:template match="refentry">

  <xsl:variable name="section" select="refmeta/manvolnum"/>
  <xsl:variable name="name" select="refnamediv/refname[1]"/>
  <xsl:variable name="base.dir" select="$base.dir"/>
  <!-- standard man page width is 64 chars; 6 chars needed for the two
       (x) volume numbers, and 2 spaces, leaves 56 -->
  <xsl:variable name="twidth" select="(74 - string-length(refmeta/refentrytitle)) div 2"/>

  <xsl:variable name="reftitle" 
		select="substring(refmeta/refentrytitle, 1, $twidth)"/>

  <xsl:variable name="title">
    <xsl:choose>
      <xsl:when test="refentryinfo/title">
        <xsl:value-of select="refentryinfo/title"/>
      </xsl:when>
      <xsl:when test="../referenceinfo/title">
        <xsl:value-of select="../referenceinfo/title"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="date">
    <xsl:choose>
      <xsl:when test="refentryinfo/date">
        <xsl:value-of select="refentryinfo/date"/>
      </xsl:when>
      <xsl:when test="../referenceinfo/date">
        <xsl:value-of select="../referenceinfo/date"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="productname">
    <xsl:choose>
      <xsl:when test="refentryinfo/productname">
        <xsl:value-of select="refentryinfo/productname"/>
      </xsl:when>
      <xsl:when test="../referenceinfo/productname">
        <xsl:value-of select="../referenceinfo/productname"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="write.text.chunk">
    <xsl:with-param name="filename"
		    select="concat($base.dir, normalize-space ($name), '.', $section)"/>
    <xsl:with-param name="content">
      <xsl:text>.\"Generated by db2man.xsl. Don't modify this, modify the source.
.de Sh \" Subsection
.br
.if t .Sp
.ne 5
.PP
\fB\\$1\fR
.PP
..
.de Sp \" Vertical space (when we can't use .PP)
.if t .sp .5v
.if n .sp
..
.de Ip \" List item
.br
.ie \\n(.$>=3 .ne \\$3
.el .ne 3
.IP "\\$1" \\$2
..
.TH "</xsl:text>
      <xsl:value-of select="translate($reftitle,'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
      <xsl:text>" </xsl:text>
      <xsl:value-of select="refmeta/manvolnum[1]"/>
      <xsl:text> "</xsl:text>
      <xsl:value-of select="normalize-space($date)"/>
      <xsl:text>" "</xsl:text>
      <xsl:value-of select="normalize-space($productname)"/>
      <xsl:text>" "</xsl:text>
      <xsl:value-of select="$title"/>
      <xsl:text>"
</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>

      <!-- Author section -->
      <xsl:choose>
        <xsl:when test="refentryinfo//author">
          <xsl:apply-templates select="refentryinfo" mode="authorsect"/>
        </xsl:when>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="informalexample|screen|programlisting">
  <xsl:text>.nf&#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>.fi&#10;</xsl:text>
</xsl:template>

<xsl:template match="//emphasis">
  <xsl:text>\fB</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>\fR</xsl:text>
</xsl:template>

<xsl:template match="para|simpara|remark" mode="list">
  <xsl:variable name="foo">
    <xsl:apply-templates/>
  </xsl:variable>
  <xsl:choose match="node()">
    <!-- Don't normalize-space() for verbatim paragraphs        -->
    <xsl:when test="informalexample|screen|programlisting">
      <xsl:value-of select="$foo"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="normalize-space($foo)"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>&#10;</xsl:text>
  <xsl:if test="following-sibling::para or following-sibling::simpara or
		following-sibling::remark">
    <!-- Make sure multiple paragraphs within a list item don't -->
    <!-- merge together.                                        -->
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="refsect3">
  <xsl:text>&#10;.SS "</xsl:text>
  <xsl:value-of select="title[1]"/>
  <xsl:text>"&#10;</xsl:text>
  <xsl:apply-templates/>
</xsl:template>


</xsl:stylesheet>
