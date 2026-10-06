<!--
  Copyright (c) 2010-2011 VIVO Harvester Team. For full list of contributors, please see the AUTHORS file provided.
  All rights reserved.
  This program and the accompanying materials are made available under the terms of the new BSD license which accompanies this distribution, and is available at http://www.opensource.org/licenses/bsd-license.html
-->
<!-- Header information for the Style Sheet
	The style sheet requires xmlns for each prefix you use in constructing
	the new elements
-->

<xsl:stylesheet version="2.0"
                xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:xs='http://www.w3.org/2001/XMLSchema'
                xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'
                xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#'
                xmlns:core='http://vivoweb.org/ontology/core#'
                xmlns:vitro = 'http://vitro.mannlib.cornell.edu/ns/vitro/0.7#'
                xmlns:vcard = 'http://www.w3.org/2006/vcard/ns#'
                xmlns:db-CSV='jdbc:h2:./data/csv/store/fields/CSV2/'
                xmlns:obo = 'http://purl.obolibrary.org/obo/'
                xmlns:bibo = 'http://purl.org/ontology/bibo/'
                xmlns:local = 'http://vivo.mydomain.edu/ontology/local/'>

    <xsl:output method = "xml" encoding="UTF-8" indent = "yes"/>
    <xsl:variable name = "baseURI">http://vivo.school.edu/individual/</xsl:variable>

    <xsl:template match = "rdf:RDF">
        <rdf:RDF xmlns:rdf = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
                 xmlns:rdfs = 'http://www.w3.org/2000/01/rdf-schema#'
                 xmlns:core = 'http://vivoweb.org/ontology/core#'
                 xmlns:bibo = 'http://purl.org/ontology/bibo/'>
            <xsl:apply-templates select = "rdf:Description" />
        </rdf:RDF>
    </xsl:template>

    <xsl:variable name = "lowercase" select="'abcdefghijklmnopqrstuvwxyz_'" />
    <xsl:variable name = "uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ '" />

    <xsl:template match = "rdf:Description">
        <xsl:variable name="this" select = "." />

        <xsl:call-template name="t_projects">
            <xsl:with-param name="projektname" select="$this/db-CSV:"/>
            <xsl:with-param name="projektsumme" />
            <xsl:with-param name="schlagwort1" />
            <xsl:with-param name="schlagwort2" />
            <xsl:with-param name="forschungsorganisation" />
            <xsl:with-param name="forschungsorganisation-id" />
            <xsl:with-param name="foerderorganisation" />
            <xsl:with-param name="foerderorganisation-ror" />
            <xsl:with-param name="foerderprogramm" />
            <xsl:with-param name="projektstart" />
            <xsl:with-param name="projektende" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name = "t_projects">
        <xsl:param name="projektname"/>
        <xsl:param name="projektsumme"/>
        <xsl:param name="schlagwort1"/>
        <xsl:param name="schlagwort2"/>
        <xsl:param name="forschungsorganisation"/>
        <xsl:param name="forschungsorganisation-id"/>
        <xsl:param name="foerderorganisation"/>
        <xsl:param name="foerderorganisation-ror"/>
        <xsl:param name="foerderprogramm"/>
        <xsl:param name="projektstart"/>
        <xsl:param name="projektende"/>

        <!-- Create a project -->
        <xsl:if test="normalize-space( $projektname )"> <!--IF PROJECT NAME EXISTS, CREATE A PROJECT-->
            <rdf:Description rdf:about="{$baseURI}project{ (:CREAT A UNIQUE ID HERE:) }">
                <rdf:type rdf:resource = "(:PROJECT CLASS SHOULD BE HERE:)"/>
                <rdfs:label rdf:datatype="https://www.w3.org/2000/01/rdf-schema#Literal"><xsl:value-of select = "$projektname" /></rdfs:label>

                <xsl:if test="normalize-space($foerderprogramm)" >
                    <local:has_Funding_Programm rdf:resource ="{$baseURI}{translate($foerderprogramm, $uppercase, $lowercase)}"/>
                </xsl:if>

                <xsl:if test="normalize-space((:ADD VARIABLE FOR PROJECT FUNDING AMOUNT:))">
                    <core:totalAwardAmount><xsl:value-of select="(:ADD VARIABLE FOR PROJECT FUNDING AMOUNT:)"/></core:totalAwardAmount>
                </xsl:if>

            </rdf:Description>

        </xsl:if>

    </xsl:template>

</xsl:stylesheet>
