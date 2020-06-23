<?xml version="1.0" encoding="UTF-8" ?>
<!-- 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://www.lyncode.com/xoai" 
    xmlns:logUtil="cz.cuni.mff.ufal.utils.XslLogUtil"
    xmlns:isocodes="cz.cuni.mff.ufal.IsoLangCodes"
    xmlns:langUtil="cz.cuni.mff.ufal.utils.LangUtil"
    xmlns:license="cz.cuni.mff.ufal.utils.LicenseUtil"
    xmlns:xalan="http://xml.apache.org/xslt"
    xmlns:str="http://exslt.org/strings"
    xmlns:ms="http://w3id.org/meta-share/meta-share/" 
    exclude-result-prefixes="doc logUtil isocodes license xalan str langUtil"
    version="1.0">
    
    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes" xalan:indent-amount="4"/>

    <!-- VARIABLES BEGIN -->
    <xsl:variable name="identifier_uri" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']"/>
    
    <xsl:variable name="handle" select="/doc:metadata/doc:element[@name='others']/doc:field[@name='handle']/text()"/>

    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='resourceType']/doc:element/doc:field[@name='value']">
          <xsl:value-of select="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='resourceType']/doc:element/doc:field[@name='value']"/>
        </xsl:when>
        <xsl:when test="/doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
          <xsl:value-of select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="logUtil:logMissing('type',$handle)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="upperType">
      <xsl:value-of select="translate(substring($type,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
      <xsl:value-of select="substring($type,2)"/>
    </xsl:variable>

    <xsl:variable name="mediaType">
      <!-- No media type for toolService -->
      <xsl:if test="not($type='toolService')">
        <xsl:choose>
          <xsl:when test="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='mediaType']/doc:element/doc:field[@name='value']">
            <xsl:value-of select="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='mediaType']/doc:element/doc:field[@name='value']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="logUtil:logMissing('mediaType',$handle)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="upperMediaType">
      <xsl:value-of select="translate(substring($mediaType,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
      <xsl:value-of select="substring($mediaType,2)"/>
    </xsl:variable>

    <xsl:variable name="detailedType">
      <!-- No detailed type for corpus -->
      <xsl:if test="not($type='corpus')">
        <xsl:choose>
          <xsl:when
                  test="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='detailedType']/doc:element/doc:field[@name='value'] = 'wordList' ">
            <xsl:value-of select="'wordlist'"/>
          </xsl:when>
          <xsl:when
                  test="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='detailedType']/doc:element/doc:field[@name='value'] ">
            <xsl:value-of select="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='detailedType']/doc:element/doc:field[@name='value']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="logUtil:logMissing('detailedType',$handle)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
  <!-- VARIABLES END -->

  <xsl:template match="/">
    <xsl:call-template name="MetadataRecord"/>
  </xsl:template>

  <xsl:template name="MetadataRecord">
    <ms:MetadataRecord xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://w3id.org/meta-share/meta-share/ ../Schema/ELG-SHARE.xsd">
      <ms:MetadataRecordIdentifier ms:MetadataRecordIdentifierScheme="http://w3id.org/meta-share/meta-share/elg">value automatically assigned - leave as is</ms:MetadataRecordIdentifier>
      <ms:metadataCreationDate><xsl:value-of select="str:split(doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='available']/doc:element/doc:field[@name='value'], 'T')[1]"/></ms:metadataCreationDate>
      <ms:metadataLastDateUpdated><xsl:value-of select="doc:metadata/doc:element[@name='others']/doc:field[@name='lastModifyDate']"/></ms:metadataLastDateUpdated>
      <ms:compliesWith>http://w3id.org/meta-share/meta-share/ELG-SHARE</ms:compliesWith>
      <ms:sourceOfMetadataRecord>LINDAT/CLARIAH-CZ</ms:sourceOfMetadataRecord>
      <ms:sourceMetadataRecord>
        <ms:MetadataRecordIdentifier>
          <xsl:attribute name="ms:MetadataRecordIdentifierScheme">http://purl.org/spar/datacite/handle</xsl:attribute>
          <xsl:value-of select="$identifier_uri"/>
        </ms:MetadataRecordIdentifier>
      </ms:sourceMetadataRecord>
      <ms:DescribedEntity>
        <xsl:call-template name="LanguageResource"/>
      </ms:DescribedEntity>
    </ms:MetadataRecord>
  </xsl:template>

  <xsl:template name="LanguageResource">
    <ms:LanguageResource>
      <ms:entityType>LanguageResource</ms:entityType>
      <xsl:call-template name="resourceName"/>
      <xsl:call-template name="description"/>
      <ms:version>undefined</ms:version>
      <ms:additionalInfo>
        <ms:landingPage><xsl:value-of select="$identifier_uri"/></ms:landingPage>
      </ms:additionalInfo>
      <xsl:call-template name="keyword"/>
      <xsl:call-template name="resourceProvider"/>
      <ms:publicationDate><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']"/></ms:publicationDate>
      <xsl:call-template name="resourceCreator"/>
      <xsl:call-template name="fundingProject"/>
        <!-- TODO replaces need a title; should add that to the xoai format -->
      <xsl:call-template name="LRSubclass"/>
    </ms:LanguageResource>
  </xsl:template>

  <xsl:template name="resourceName">
      <ms:resourceName xml:lang="en">
        <xsl:choose>
          <xsl:when test="doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#IdentificationInfo']/doc:element[@name='resourceName']/doc:element/doc:field[@name='value']">
            <xsl:value-of select="doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#IdentificationInfo']/doc:element[@name='resourceName']/doc:element/doc:field[@name='value']"/>
          </xsl:when>
          <xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="logUtil:logMissing('resourceName',$handle)"/>
          </xsl:otherwise>
        </xsl:choose>
      </ms:resourceName>
  </xsl:template>

  <xsl:template name="description">
      <ms:description xml:lang="en">
        <xsl:choose>
          <xsl:when test="doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='description']/doc:element/doc:field[@name='value']">
            <xsl:value-of select="doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ContentInfo']/doc:element[@name='description']/doc:element/doc:field[@name='value']"/>
          </xsl:when>
          <xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element/doc:field[@name='value']">
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element/doc:field[@name='value']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="logUtil:logMissing('description',$handle)"/>
          </xsl:otherwise>
        </xsl:choose>
      </ms:description>
  </xsl:template>

  <xsl:template name="keyword">
      <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
        <ms:keyword xml:lang='en'><xsl:value-of select="."/></ms:keyword>
      </xsl:for-each>
  </xsl:template>

  <xsl:template name="resourceProvider">
      <ms:resourceProvider>
        <ms:Organization>
          <ms:actorType>Organization</ms:actorType>
          <ms:organizationName xml:lang="en"><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']"/></ms:organizationName>
        </ms:Organization>
      </ms:resourceProvider>
  </xsl:template>

  <xsl:template name="resourceCreator">
      <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
        <xsl:variable name="surname" select="str:split(., ', ')[1]"/>
        <xsl:variable name="given">
          <xsl:for-each select="str:split(., ', ')">
            <xsl:if test="position() &gt; 1">
              <xsl:value-of select="."/>
              <xsl:if test="position() != last()">
                <xsl:text>, </xsl:text>
              </xsl:if>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <ms:resourceCreator>
          <ms:Person>
            <ms:actorType>Person</ms:actorType>
            <!--  xml:lang doesn't make much sense for surnames and givenName; it should be "script", en mandatory -->
            <ms:surname xml:lang="en"><xsl:value-of select="$surname"/></ms:surname>
            <ms:givenName xml:lang="en"><xsl:value-of select="$given"/></ms:givenName>
          </ms:Person>
        </ms:resourceCreator>
      </xsl:for-each>
  </xsl:template>

  <xsl:template name="fundingProject">
    <xsl:for-each select="doc:metadata/doc:element[@name='local']/doc:element[@name='sponsor']/doc:element/doc:field[@name='value']">
      <xsl:variable name="proj_arr" select="str:split(., '@@')"/>
      <ms:fundingProject>
        <ms:projectName xml:lang="en">
          <xsl:value-of select="$proj_arr[3]"/>
        </ms:projectName>
        <ms:ProjectIdentifier>
          <xsl:choose>
            <xsl:when test="starts-with($proj_arr[5], 'info:')">
              <xsl:attribute name="ms:ProjectIdentifierScheme">http://w3id.org/meta-share/meta-share/cordis</xsl:attribute>
              <xsl:value-of select="$proj_arr[5]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="ms:ProjectIdentifierScheme">http://w3id.org/meta-share/meta-share/other</xsl:attribute>
              <xsl:value-of select="$proj_arr[2]"/>
            </xsl:otherwise>
          </xsl:choose>
        </ms:ProjectIdentifier>
          <!--
        <ms:fundingType>
          <xsl:value-of select="$proj_arr[4]"/>
        </ms:fundingType>
        -->
      </ms:fundingProject>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="LRSubclass">
    <ms:LRSubclass>
      <xsl:choose>
        <xsl:when test="$type = 'corpus'">
          <xsl:call-template name="corpus"/>
        </xsl:when>
        <xsl:when test="$type = 'toolService'">
          <xsl:call-template name="toolService"/>
        </xsl:when>
        <xsl:when test="$type = 'languageDescription'">
          <xsl:call-template name="languageDescription"/>
        </xsl:when>
        <xsl:when test="$type = 'lexicalConceptualResource'">
          <xsl:call-template name="lexicalConceptualResource"/>
        </xsl:when>
      </xsl:choose>
    </ms:LRSubclass>
  </xsl:template>

  <xsl:template name="corpus">
      <ms:Corpus>
        <ms:lrType>Corpus</ms:lrType>
        <ms:corpusSubclass>undefined</ms:corpusSubclass>
        <!--
          XXX if undefined not working
        <ms:corpusSubclass>http://w3id.org/meta-share/meta-share/rawCorpus</ms:corpusSubclass>
        -->
        <xsl:call-template name="CommonMediaPart"/>
        <!-- xsl:call-template name="CorpusMediaPart"/ -->
        <xsl:call-template name="Distribution"/>
        <xsl:call-template name="personalSensitiveAnon"/>
      </ms:Corpus>
  </xsl:template>

  <xsl:template name="personalSensitiveAnon">
    <ms:personalDataIncluded>false</ms:personalDataIncluded>
    <ms:sensitiveDataIncluded>false</ms:sensitiveDataIncluded>
  </xsl:template>

  <xsl:template name="CommonMediaPart">
    <xsl:variable name="name" select="concat($upperType, 'MediaPart')"/>
    <xsl:element name="ms:{$name}">
      <xsl:call-template name="commonMediaElements"/>
      <xsl:choose>
        <xsl:when test="$mediaType = 'audio'">
          <xsl:call-template name="audio"/>
        </xsl:when>
        <xsl:when test="$mediaType = 'video'">
          <xsl:call-template name="video"/>
        </xsl:when>
        <xsl:when test="$mediaType = 'text'">
          <xsl:call-template name="text"/>
        </xsl:when>
        <xsl:when test="$mediaType = 'image'">
          <xsl:call-template name="image"/>
        </xsl:when>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="commonMediaElements">
    <xsl:variable name="name" select="concat($upperType, $upperMediaType, 'Part')"/>
    <xsl:variable name="name2" >
      <xsl:choose>
        <xsl:when test="$type = 'lexicalConceptualResource'">lcrMediaType</xsl:when>
        <xsl:when test="$type = 'languageDescription'">ldMediaType</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($type, 'MediaType')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="ms:{$name}">
      <xsl:element name="ms:{$name2}"><xsl:value-of select="$name"/></xsl:element>
      <ms:mediaType><xsl:value-of select="concat('http://w3id.org/meta-share/meta-share/', $mediaType)"/></ms:mediaType>
      <ms:lingualityType>
        <xsl:variable name="langCount" select="count(/doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value'])"/>
        <xsl:text>http://w3id.org/meta-share/meta-share/</xsl:text>
        <xsl:choose>
          <xsl:when test="$langCount=1">monolingual</xsl:when>
          <xsl:when test="$langCount=2">bilingual</xsl:when>
          <xsl:otherwise>multilingual</xsl:otherwise>
        </xsl:choose>
      </ms:lingualityType>
      <xsl:for-each
              select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']">
        <xsl:call-template name="Language">
          <xsl:with-param name="isoCode" select="langUtil:getShortestId(.)"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:if test="$type = 'lexicalConceptualResource' or $type = 'languageDescription'">
        <ms:metalanguage>
          <xsl:call-template name="ms_language_inside">
            <xsl:with-param name="isoCode" select="langutil:getShortestId('und')"/>
          </xsl:call-template>
        </ms:metalanguage>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template name="commonCorpusMediaElements">
      <xsl:variable name="name" select="concat('Corpus', $upperMediaType, 'Part')"/>
      <xsl:element name="ms:{$name}">
        <ms:corpusMediaType><xsl:value-of select="$name"/></ms:corpusMediaType>
        <ms:mediaType><xsl:value-of select="concat('http://w3id.org/meta-share/meta-share/', $mediaType)"/></ms:mediaType>
        <ms:lingualityType>
          <xsl:variable name="langCount" select="count(/doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value'])"/>
          <xsl:text>http://w3id.org/meta-share/meta-share/</xsl:text>
          <xsl:choose>
            <xsl:when test="$langCount=1">monolingual</xsl:when>
            <xsl:when test="$langCount=2">bilingual</xsl:when>
            <xsl:otherwise>multilingual</xsl:otherwise>
          </xsl:choose>
        </ms:lingualityType>
        <xsl:for-each
                select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']">
          <xsl:call-template name="Language">
            <xsl:with-param name="isoCode" select="langUtil:getShortestId(.)"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:element>
  </xsl:template>

  <xsl:template name="text"></xsl:template>
  <xsl:template name="audio"></xsl:template>
    <!-- XXX
     elg.xml:53: element CorpusVideoPart: Schemas validity error : Element '{http://w3id.org/meta-share/meta-share/}CorpusVideoPart': Missing child element(s). Expected is one of ( {http://w3id.org/meta-share/meta-share/}language, {http://w3id.org/meta-share/meta-share/}languageVariety, {http://w3id.org/meta-share/meta-share/}modalityType, {http://w3id.org/meta-share/meta-share/}VideoGenre, {http://w3id.org/meta-share/meta-share/}typeOfVideoContent ).
elg.xml:62: element typeOfVideoContent: Schemas validity error : Element '{http://w3id.org/meta-share/meta-share/}typeOfVideoContent': This element is not expected.
     -->
  <xsl:template name="video">
    <ms:typeOfVideoContent xml:lang="en">undefined</ms:typeOfVideoContent>
  </xsl:template>
  <xsl:template name="image">
    <ms:typeOfImageContent xml:lang="en">undefined</ms:typeOfImageContent>
  </xsl:template>

  <xsl:template name="Language">
    <xsl:param name="isoCode"/>
    <ms:language>
        <xsl:call-template name="ms_language_inside">
          <xsl:with-param name="isoCode" select="$isoCode"/>
        </xsl:call-template>
    </ms:language>
  </xsl:template>

  <xsl:template name="ms_language_inside">
    <xsl:param name="isoCode"/>
    <ms:languageTag>
      <xsl:value-of select="$isoCode"/>
    </ms:languageTag>
    <ms:languageId>
      <xsl:value-of select="$isoCode"/>
    </ms:languageId>
  </xsl:template>

  <xsl:template name="Distribution">
    <xsl:param name="distributionType" select="'Dataset'"/>
    <xsl:variable name="form">
      <xsl:choose>
        <xsl:when test="$distributionType = 'Dataset'">downloadable</xsl:when>
        <xsl:otherwise>sourceCode</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="ms:{$distributionType}Distribution">
      <xsl:element name="ms:{$distributionType}DistributionForm">
        <xsl:value-of select="concat('http://w3id.org/meta-share/meta-share/', $form)"/>
      </xsl:element>
      <ms:accessLocation><xsl:value-of select="$identifier_uri"/></ms:accessLocation>
      <xsl:if test="doc:metadata/doc:element[@name='local']/doc:element[@name='demo']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
        <xsl:variable name="locType">
          <xsl:choose>
            <xsl:when test="$type = 'toolService'">demo</xsl:when>
            <xsl:otherwise>samples</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="ms:{$locType}Location">
          <xsl:value-of select="doc:metadata/doc:element[@name='local']/doc:element[@name='demo']/doc:element[@name='uri']/doc:element/doc:field[@name='value']"/>
        </xsl:element>
      </xsl:if>
      <ms:licenceTerms>
        <ms:licenceTermsName xml:lang="en"><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']" /></ms:licenceTermsName>
        <ms:licenceTermsURL><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='uri']/doc:element/doc:field[@name='value']" /></ms:licenceTermsURL>
      </ms:licenceTerms>
    </xsl:element>
  </xsl:template>

  <xsl:template name="toolService">
      <ms:ToolService>
        <ms:lrType>ToolService</ms:lrType>
        <ms:function>
          <ms:LTClassRecommended>undefined</ms:LTClassRecommended>
            <!-- XXX if undefined not working
          <ms:LTClassRecommended>http://w3id.org/meta-share/omtd-share/Tokenization</ms:LTClassRecommended>
            -->
        </ms:function>
        <xsl:call-template name="Distribution">
          <xsl:with-param name="distributionType" select="'Software'"/>
        </xsl:call-template>
        <ms:languageDependent>
          <xsl:value-of select="/doc:metadata/doc:element[@name='metashare']/doc:element[@name='ResourceInfo#ResourceComponentType#ToolServiceInfo']/doc:element[@name='languageDependent']/doc:element/doc:field[@name='value']"/>
        </ms:languageDependent>
        <ms:inputContentResource>
          <ms:processingResourceType>undefined</ms:processingResourceType>
          <!-- XXX fixed value
          <ms:processingResourceType>http://w3id.org/meta-share/meta-share/file1</ms:processingResourceType>
           -->
        </ms:inputContentResource>
        <ms:evaluated>false</ms:evaluated>
      </ms:ToolService>
  </xsl:template>

  <xsl:template name="languageDescription">
    <ms:LanguageDescription>
      <ms:lrType>LanguageDescription</ms:lrType>
      <ms:LanguageDescriptionSubclass>undefined</ms:LanguageDescriptionSubclass>
        <!-- XXX if undefined not working
        we have only grammar/other in detailed type
        <ms:NGramModel>
          <ms:ldSubclassType>NGramModel</ms:ldSubclassType>
          <ms:baseItem>http://w3id.org/meta-share/meta-share/word</ms:baseItem>
          <ms:order>5</ms:order>
        </ms:NGramModel>
      </ms:LanguageDescriptionSubclass>
       -->
      <xsl:call-template name="CommonMediaPart"/>
      <xsl:call-template name="Distribution"/>
      <xsl:call-template name="personalSensitiveAnon"/>
    </ms:LanguageDescription>
  </xsl:template>

  <xsl:template name="lexicalConceptualResource">
    <ms:LexicalConceptualResource>
      <ms:lrType>LexicalConceptualResource</ms:lrType>
      <ms:lcrSubclass><xsl:value-of select="concat('http://w3id.org/meta-share/meta-share/', $detailedType)"/></ms:lcrSubclass>
      <ms:encodingLevel>undefined</ms:encodingLevel>
      <!-- XXX if undefined not working
      <ms:encodingLevel>http://w3id.org/meta-share/meta-share/morphology</ms:encodingLevel>
      -->
      <xsl:call-template name="CommonMediaPart"/>
      <xsl:call-template name="Distribution"/>
      <xsl:call-template name="personalSensitiveAnon"/>
    </ms:LexicalConceptualResource>
  </xsl:template>

</xsl:stylesheet>
