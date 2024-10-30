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
    xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'
    xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#'
    xmlns:core='http://vivoweb.org/ontology/core#'
    xmlns:vitro = 'http://vitro.mannlib.cornell.edu/ns/vitro/0.7#'
    xmlns:vcard = 'http://www.w3.org/2006/vcard/ns#'
    xmlns:db-CSV='jdbc:h2:./data/csv/store/fields/CSV2/'
    xmlns:tibvivo = 'https://vivo.tib.eu/fis/ontology/tib-vivo#'
    xmlns:obo = 'http://purl.obolibrary.org/obo/'>
	
    <xsl:output method = "xml" indent = "yes"/>
    <xsl:variable name = "baseURI">https://vivo.tib.eu/fis/individual/</xsl:variable>

    <xsl:template match = "rdf:RDF">
        <rdf:RDF xmlns:rdf = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
                 xmlns:rdfs = 'http://www.w3.org/2000/01/rdf-schema#'
                 xmlns:core = 'http://vivoweb.org/ontology/core#'
                 xmlns:score = 'http://vivoweb.org/ontology/score#'>
            <xsl:apply-templates select = "rdf:Description" />
        </rdf:RDF>
    </xsl:template>

    <!-- RAW DATA FROM DRITTMITTELLISTE EXAMPLE:
        <db-CSV2:ROWID>2</db-CSV2:ROWID>
        <db-CSV2:DRITTMITTELGEBER_FUNDER>BMBF</db-CSV2:DRITTMITTELGEBER_FUNDER>
        <db-CSV2:FOERDERKENNZEICHEN>03O1441</db-CSV2:FOERDERKENNZEICHEN>
        <db-CSV2:CALL>Strategien und Konzepte im Bereich des Wissens- und Technologietransfers</db-CSV2:CALL>
        <db-CSV2:KURZTITEL_ACRONYM></db-CSV2:KURZTITEL_ACRONYM>
        <db-CSV2:TITEL_DES_PROJEKTS_TITLE>Sektorale Verwertung - TIB Transfer II</db-CSV2:TITEL_DES_PROJEKTS_TITLE>
        <db-CSV2:WEBSITE></db-CSV2:WEBSITE>
        <db-CSV2:PROJEKTBEGINN>01.03.2015</db-CSV2:PROJEKTBEGINN>
        <db-CSV2:PROJEKTENDE>31.08.2018</db-CSV2:PROJEKTENDE>
        <db-CSV2:BETREUT_DURCH_ORGANISATIONSEINHEIT>C. E</db-CSV2:BETREUT_DURCH_ORGANISATIONSEINHEIT>
        <db-CSV2:INTERNE_PROJEKTNR>53000001</db-CSV2:INTERNE_PROJEKTNR>
        <db-CSV2:STATUS>Accepted</db-CSV2:STATUS>
        <db-CSV2:PUBLIK></db-CSV2:PUBLIK>
    -->
	
	<xsl:template match = "rdf:Description">
		<xsl:variable name = "this" select = "." />
        <xsl:variable name="status" select="$this/db-CSV:STATUS"/>
        <xsl:variable name="public" select="$this/db-CSV:PUBLIK"/>

        <xsl:if test="(lower-case($status) ='accepted' and lower-case($public)='ja')" >
            <xsl:call-template name = "t_Project">
                <xsl:with-param name="funder" select="$this/db-CSV:DRITTMITTELGEBER_FUNDER"/>
                <xsl:with-param name="sponsorawardid" select="$this/db-CSV:FOERDERKENNZEICHEN"/>
                <xsl:with-param name="call" select="$this/db-CSV:CALL"/>
                <xsl:with-param name="acronym" select="$this/db-CSV:KURZTITEL_ACRONYM"/>
                <xsl:with-param name="title" select="$this/db-CSV:TITEL_DES_PROJEKTS_TITLE"/>
                <xsl:with-param name="website" select="$this/db-CSV:WEBSITE"/>
                <xsl:with-param name="start">
                    <xsl:call-template name="formatdate">
                        <xsl:with-param name="DateTimeStr" select="$this/db-CSV:PROJEKTBEGINN"/>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="end">
                    <xsl:call-template name="formatdate">
                        <xsl:with-param name="DateTimeStr" select="$this/db-CSV:PROJEKTENDE"/>
                    </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="org" select="$this/db-CSV:BETREUT_DURCH_ORGANISATIONSEINHEIT"/>
                <xsl:with-param name="projectnr" select="$this/db-CSV:INTERNE_PROJEKTNR"/>
            </xsl:call-template>
        </xsl:if>
	</xsl:template>

    <xsl:template name = "t_Project">
        <xsl:param name="funder"/>
        <xsl:param name="sponsorawardid"/>
        <xsl:param name="call"/>
        <xsl:param name="acronym"/>
        <xsl:param name="title"/>
        <xsl:param name="website"/>
        <xsl:param name="start"/>
        <xsl:param name="end"/>
        <xsl:param name="org"/>
        <xsl:param name="projectnr"/>

        <!--   Mapping of organization name to organization URI   -->
        <xsl:variable name="organizations" >
            <entry key="A. BuL">https://vivo.tib.eu/fis/individual/orgb44</entry>
            <entry key="A. EuK">https://vivo.tib.eu/fis/individual/orgb33</entry>
            <entry key="A. Ref. L">https://vivo.tib.eu/fis/individual/n9421</entry>
            <entry key="A. Ref. PM">https://vivo.tib.eu/fis/individual/n31417</entry>
            <entry key="A. W-Dienst">https://vivo.tib.eu/fis/individual/orgb32</entry>
            <entry key="B. PD">https://vivo.tib.eu/fis/individual/orgb62</entry>
            <entry key="BFW">https://vivo.tib.eu/fis/individual/n6022</entry>
            <entry key="BMBF">http://d-nb.info/gnd/5309538-8</entry>
            <entry key="BMG">https://vivo.tib.eu/fis/individual/n30652</entry>
            <entry key="BMWi">http://d-nb.info/gnd/5311495-4</entry>
            <entry key="Bundeskulturstiftung">https://vivo.tib.eu/fis/individual/n10961</entry>
            <entry key="C. DSDL">https://vivo.tib.eu/fis/individual/orgb67</entry>
            <entry key="C. E">https://vivo.tib.eu/fis/individual/orgb70</entry>
            <entry key="C. FuE">https://vivo.tib.eu/fis/individual/orgab66</entry>
            <entry key="D. KI">https://vivo.tib.eu/fis/individual/n1315</entry>
            <entry key="C. LSA">https://vivo.tib.eu/fis/individual/n6541</entry>
            <entry key="C. LSK">https://vivo.tib.eu/fis/individual/n27291</entry>
            <entry key="C. NTM">https://vivo.tib.eu/fis/individual/n8144</entry>
            <entry key="C. OSL">https://vivo.tib.eu/fis/individual/orgb66</entry>
            <entry key="C. SDM">https://vivo.tib.eu/fis/individual/n160</entry>
            <entry key="C. SKE">https://vivo.tib.eu/fis/individual/n15632</entry>
            <entry key="C. VA">https://vivo.tib.eu/fis/individual/orgb68</entry>
            <entry key="D. DSDL">https://vivo.tib.eu/fis/individual/n20007</entry>
            <entry key="D. KCB">https://vivo.tib.eu/fis/individual/n29776</entry>
            <entry key="ZA. WuA">https://vivo.tib.eu/fis/individual/orgab8</entry>
            <entry key="CDZ">http://d-nb.info/gnd/2183420-9</entry>
            <entry key="DBU">http://d-nb.info/gnd/5090756-6</entry>
            <entry key="DFG">http://d-nb.info/gnd/2007744-0</entry>
            <entry key="DHV">http://d-nb.info/gnd/2091795-8</entry>
            <entry key="DRA">http://d-nb.info/gnd/2032728-6</entry>
            <entry key="EK">http://d-nb.info/gnd/5100798-8</entry>
            <entry key="EU">https://vivo.tib.eu/fis/individual/org_ror_019w4f821</entry>
            <entry key="European Patent Office">https://vivo.tib.eu/fis/individual/org_Q7132151</entry>
            <entry key="HP Labs Bristol">https://vivo.tib.eu/fis/individual/n1918</entry>
            <entry key="IEEE">http://d-nb.info/gnd/1692-5</entry>
            <entry key="IISTE">http://d-nb.info/gnd/1029671583</entry>
            <entry key="INTAS">http://d-nb.info/gnd/6006812-7</entry>
            <entry key="ISAST">http://d-nb.info/gnd/16157585-7</entry>
            <entry key="IWM">http://d-nb.info/gnd/1072317591</entry>
            <entry key="KEK">https://vivo.tib.eu/fis/individual/org_Q15824236</entry>
            <entry key="Klosterkamm Hannover">https://vivo.tib.eu/fis/individual/org_Q1776414</entry>
            <entry key="Leibniz Forschungsverbund Science 2.0">https://vivo.tib.eu/fis/individual/n10921</entry>
            <entry key="Leibniz Forschungsverbund Science 2.0: Interne Ausschreibung für Projekte und Veranstaltungen">https://vivo.tib.eu/fis/individual/n10921</entry>
            <entry key="Leibniz-Gemeinschaft">http://d-nb.info/gnd/5271371-4</entry>
            <entry key="Leibniz-WissenschaftsCampi 2019">https://vivo.tib.eu/fis/individual/n28891</entry>
            <entry key="MWK">http://d-nb.info/gnd/5055588-1</entry>
            <entry key="NTK">http://d-nb.info/gnd/102963761X</entry>
            <entry key="RWTH Aachen">http://d-nb.info/gnd/36225-6</entry>
            <entry key="SLUB">http://d-nb.info/gnd/5165770-3</entry>
            <entry key="SNB">http://d-nb.info/gnd/10171799-4</entry>
            <entry key="Stiftung Niedersachsen">https://vivo.tib.eu/fis/individual/org_Q1549515</entry>
            <entry key="TU Clausthal">http://d-nb.info/gnd/36230-X</entry>
            <entry key="TUCS">https://vivo.tib.eu/fis/individual/n2028</entry>
            <entry key="UB Heidelberg">http://d-nb.info/gnd/2002498-8</entry>
            <entry key="UEF">http://d-nb.info/gnd/16162019-X</entry>
            <entry key="VGH-Stiftung">https://vivo.tib.eu/fis/individual/org_Q19964894</entry>
            <entry key="VST GmbH">https://vivo.tib.eu/fis/individual/kpart216</entry>
            <entry key="VW Stiftung">https://vivo.tib.eu/fis/individual/org_ror_03bsmfz84</entry>
            <entry key="ZBW">http://d-nb.info/gnd/10158795-8</entry>
            <entry key="Stadt Hamburg">https://vivo.tib.eu/fis/individual/n32604</entry>
            <entry key="Twincore">https://vivo.tib.eu/fis/individual/org_ror_04bya8j72</entry>
            <entry key="Chan Zuckerberg Initiative">https://vivo.tib.eu/fis/individual/n15794</entry>
            <entry key="Mozilla Fund">https://vivo.tib.eu/fis/individual/n20730</entry>
            <entry key="Robert Bosch Stiftung">https://vivo.tib.eu/fis/individual/n22237</entry>
            <entry key="Klaus Tschira Stiftung">https://vivo.tib.eu/fis/individual/n25231</entry>
            <entry key="Nieders. Lotto-Soprt-Stiftung">https://vivo.tib.eu/fis/individual/n52592</entry>
            <entry key="DUG-WW">https://vivo.tib.eu/fis/individual/n10395</entry>
            <entry key="DAAD">https://vivo.tib.eu/fis/individual/n19275</entry>
            <entry key="Humboldt-Stiftung">https://vivo.tib.eu/fis/individual/n26357</entry>
            <entry key="Alfred Landecker Foundation">https://vivo.tib.eu/fis/individual/n49638</entry>
            <entry key="Bundesinstitut für Sportwissenschaft (BISp)">https://vivo.tib.eu/fis/individual/n64361</entry>
            <entry key="Forschungsgruppe Artificial Intelligence for Scholarly Communications">https://vivo.tib.eu/fis/individual/n40822</entry>
        </xsl:variable>


        <!--	Creating a Project   -->
        <rdf:Description rdf:about = "{$baseURI}gr{$projectnr}">
            <rdf:type rdf:resource = "https://vivo.tib.eu/fis/ontology/tib-vivo#TIBProjekt"/>

            <rdfs:label><xsl:value-of select = "$title" /></rdfs:label>

            <xsl:if test="normalize-space( $acronym )">
                <core:abbreviation><xsl:value-of select="$acronym"/></core:abbreviation>
            </xsl:if>
            <xsl:if test="normalize-space( $sponsorawardid )">
                <core:sponsorAwardId><xsl:value-of select = "$sponsorawardid" /></core:sponsorAwardId>
            </xsl:if>
            <xsl:if test="normalize-space( $call )">
                <tibvivo:project_Call><xsl:value-of select = "$call" /></tibvivo:project_Call>
            </xsl:if>
            <xsl:if test="normalize-space( $projectnr )">
                <core:localAwardId><xsl:value-of select="$projectnr"/></core:localAwardId>
            </xsl:if>
            <xsl:if test="normalize-space( $funder )">
                <core:assignedBy rdf:resource="{$organizations/entry[@key=$funder]}" />
            </xsl:if>
            <xsl:if test="normalize-space( $website )">
                <obo:ARG_2000028 rdf:resource="{$baseURI}vc_{$projectnr}"/>
            </xsl:if>
            <xsl:if test="normalize-space( $org )">
                <tibvivo:betreutDurchOrganisationseinheit rdf:resource="{$organizations/entry[@key=$org]}"/>
            </xsl:if>

        </rdf:Description>

        <!-- vcard for project website url -->
        <xsl:if test="normalize-space( $website )">
            <rdf:Description rdf:about="{$baseURI}vc_{$projectnr}">
                <vcard:hasURL rdf:resource="{$baseURI}vcurl_{$projectnr}"/>
            </rdf:Description>

            <!-- vcard URL -->
            <rdf:Description rdf:about="{$baseURI}vcurl_{$projectnr}">
                <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#URL"/>
                <vitro:mostSpecificType rdf:resource="http://www.w3.org/2006/vcard/ns#URL"/>
                <vcard:url rdf:datatype="http://www.w3.org/2001/XMLSchema:anyURI"><xsl:value-of select="$website"/></vcard:url>
            </rdf:Description>
        </xsl:if>

        <!-- date time interval -->
        <xsl:if test="normalize-space( $start )">
            <rdf:Description rdf:about="{$baseURI}dti_{$projectnr}">
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeInterval"/>
                <core:start rdf:resource="{$baseURI}dtvs_{$projectnr}"/>
                <core:end rdf:resource="{$baseURI}dtve_{$projectnr}"/>
            </rdf:Description>
        </xsl:if>

        <!-- date time value start-->
        <xsl:if test="normalize-space( $start )">
            <rdf:Description rdf:about="{$baseURI}dtvs_{$projectnr}">
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
                <core:dateTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                    <xsl:value-of select="$start"/></core:dateTime>
                <core:dateTimePrecision rdf:resource="http://vivoweb.org/ontology/core#yearMonthDayPrecision"/>
            </rdf:Description>
        </xsl:if>

        <!-- date time value end-->
        <xsl:if test="normalize-space( $end )">
            <rdf:Description rdf:about="{$baseURI}dtve_{$projectnr}">
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
                <core:dateTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                    <xsl:value-of select="$end"/></core:dateTime>
                <core:dateTimePrecision rdf:resource="http://vivoweb.org/ontology/core#yearMonthDayPrecision"/>
            </rdf:Description>
        </xsl:if>

    </xsl:template>

    <xsl:template name="formatdate">
        <xsl:param name="DateTimeStr" /> <!-- date comes as dd.mm.yyyy-->

        <xsl:variable name="dd">
            <xsl:call-template name="formatday">
                <xsl:with-param name="day" select="substring-before($DateTimeStr, '.')"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="mm">
            <xsl:call-template name="formatmonth">
                <xsl:with-param name="month" select="substring-before(substring-after($DateTimeStr, '.'), '.')"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="yyyy">
            <xsl:value-of select="substring-after(substring-after($DateTimeStr, '.'), '.')" />
        </xsl:variable>

        <xsl:value-of select="concat($yyyy,'-',$mm,'-', $dd, 'T00:00:00')" />
    </xsl:template>

    <xsl:template name="formatmonth">
        <xsl:param name="month" />
        <xsl:choose>
            <xsl:when test="string-length($month) = 1">
                <xsl:value-of select="concat('0',$month)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$month"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="formatday">
        <xsl:param name="day" />
        <xsl:choose>
            <xsl:when test="string-length($day) = 1">
                <xsl:value-of select="concat('0',$day)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$day"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
