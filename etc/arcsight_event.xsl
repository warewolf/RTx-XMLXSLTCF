<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:uri="urn:uri"> 
  <xsl:param name="arcsightweb"/>
  <xsl:output method="html" indent="yes"/>
  <xsl:template name="case_link"><!--{{{-->
    <xsl:param name="arcsightweb"/>
    <xsl:param name="case_id"/>
    <xsl:param name="case_name"/>
    Arcsight Case: <a><xsl:attribute name="href"><xsl:value-of select="$arcsightweb"/>/arcsight/app?service=external/Case&amp;sp=S<xsl:value-of select="uri:escape-uri($case_id)"/></xsl:attribute><xsl:value-of select="$case_name"/></a><br/>
  </xsl:template><!--}}}-->
  <xsl:template match="/archive"><!--{{{-->
    <xsl:for-each select="Case"><!--{{{-->
    <xsl:variable name="case_id" select="@id"/> <!-- case ID is used in case_link template -->
    <xsl:variable name="case_name" select="@name"/>
      <xsl:call-template name="case_link">
        <xsl:with-param name="arcsightweb" select="$arcsightweb"/>
        <xsl:with-param name="case_id" select="$case_id"/>
        <xsl:with-param name="case_name" select="$case_name"/>
      </xsl:call-template>
      <xsl:for-each select="caseEvents/list/ref"><!--{{{-->
	<xsl:sort select="@id" order="descending"/> <!-- sort descending so base events show last -->
	<xsl:variable name="case_event_id" select="@id"/>
	<xsl:variable name="case_event" select="//SecurityEvent[@id = $case_event_id]"/>
	<xsl:choose><!--{{{-->
	  <xsl:when test="count(//SecurityEvent/baseEventIds/list//ref/@id[. = $case_event_id]) = 0"><!--{{{-->
	    <!-- no events refer to this event, this is the last event in a correlated chain -->
            <xsl:variable name="content"><!--{{{-->
              <xsl:call-template name="event_details"><xsl:with-param name="event" select="$case_event"/></xsl:call-template>
            </xsl:variable><!--}}}-->
	    <xsl:copy-of select="$content"/>
	  </xsl:when><!--}}}-->
	</xsl:choose><!--}}}-->
      </xsl:for-each><!--}}}-->
    </xsl:for-each><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="boxtainer"><!--{{{-->
    <xsl:param name="content"/> <!-- content is what to display inside -->
    <xsl:param name="title"/> <!-- title is the box title -->
    <xsl:param name="element"/> <!-- element is the node the data came from, so we can generate a unique ID for collapseability -->
    <xsl:param name="boxclass"/> <!-- name is the class of the box, to set colors -->
    <table class="ticket-summary" width="100%"><!--{{{-->
      <tr><!--{{{-->
        <td valign="top" class="boxtainer"><!--{{{-->
          <div><xsl:attribute name="class">titlebox <xsl:value-of select="$boxclass"/></xsl:attribute><!--{{{-->
            <div id=""><!--{{{-->
              <div class="titlebox-title"><!--{{{-->
                <span class="widget"><!--{{{-->
                <a>
                  <xsl:attribute name="title">Toggle visibility</xsl:attribute>
		  <xsl:attribute name="onclick">return rollup('<xsl:value-of select="generate-id($element)"/>');</xsl:attribute>
                  <xsl:attribute name="href">#</xsl:attribute>
                </a>
                </span><!--}}}-->
		<a><xsl:attribute name="name"><xsl:value-of select="$title"/></xsl:attribute></a>
		<span class="left" style="color: #fff;"><xsl:value-of select="$title"/></span>
		<span class="right-empty">
		</span>
              </div><!--}}}-->
	      <div><!--{{{-->
                <xsl:attribute name="class">titlebox-content</xsl:attribute>
                <xsl:attribute name="id"><xsl:value-of select="generate-id($element)"/></xsl:attribute>
		<table><!--{{{-->
                  <xsl:copy-of select="$content"/>
                </table><!--}}}-->
		<hr class="clear" />
              </div><!--}}}-->
            </div><!--}}}-->
          </div><!--}}}-->
        </td><!--}}}-->
      </tr><!--}}}-->
    </table><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="event_details"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:variable name="content"><!--{{{-->
      <xsl:call-template name="common-event">
	<xsl:with-param name="event" select="$event"/>
      </xsl:call-template>
    </xsl:variable><!--}}}-->
    <xsl:variable name="boxclass">
      <xsl:choose><!--{{{-->
        <xsl:when test="$event/type[text() = 'Correlation']">ticket-info-cfs</xsl:when>
        <xsl:when test="$event/type[text() = 'Base']">ticket-info-attachments</xsl:when>
      </xsl:choose><!--}}}-->
    </xsl:variable>
    <xsl:call-template name="boxtainer"><!--{{{-->
      <xsl:with-param name="content" select="$content"/>
      <xsl:with-param name="title" select="$event/@name"/>
      <xsl:with-param name="element" select="$event"/>
      <xsl:with-param name="boxclass" select="$boxclass"/>
    </xsl:call-template><!--}}}-->
    <xsl:for-each select="$event/baseEventIds/list//ref"><!--{{{-->
      <xsl:variable name="parentevent_id" select="@id"/>
      <xsl:if test="count(//SecurityEvent[@id = $parentevent_id]) > 0">
	<xsl:variable name="parentevent" select="//SecurityEvent[@id = $parentevent_id]"/>
	<xsl:call-template name="event_details">
	  <xsl:with-param name="event" select="$parentevent"/>
	</xsl:call-template>
      </xsl:if>
    </xsl:for-each><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="common-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:call-template name="agent-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="category-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="target-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="destination-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="attacker-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="event-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="file-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="flex-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="generator-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="oldfile-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="request-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="source-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="device-custom-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="device-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
    <xsl:call-template name="generic-event"><xsl:with-param name="event" select="$event"/></xsl:call-template>
  </xsl:template><!--}}}-->
  <xsl:template name="agent-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/agent/map/address"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'Agent Address:'"/>
      <xsl:with-param name="value" select="$event/agent/map/address"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agent/map/descriptorId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'Agent Descriptor Id:'"/>
      <xsl:with-param name="value" select="$event/agent/map/descriptorId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agent/map/hostName"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'Agent Hostname:'"/>
      <xsl:with-param name="value" select="$event/agent/map/hostName"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agent/map/id"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'Agent Id:'"/>
      <xsl:with-param name="value" select="$event/agent/map/id"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agent/map/type"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'Agent Type:'"/>
      <xsl:with-param name="value" select="$event/agent/map/type"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agent/map/version"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'Agent Version:'"/>
      <xsl:with-param name="value" select="$event/agent/map/version"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentAssetId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'Agent Asset ID:'"/>
      <xsl:with-param name="value" select="$event/agentAssetId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/assetCriticality"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'Agent Asset ID:'"/>
      <xsl:with-param name="value" select="$event/assetCriticality"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentDescriptorId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'Agent Descriptor ID:'"/>
      <xsl:with-param name="value" select="$event/agentDescriptorId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentDnsDomain"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentDnsDomain:'"/>
      <xsl:with-param name="value" select="$event/agentDnsDomain"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentMacAddress"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentMacAddress:'"/>
      <xsl:with-param name="value" select="$event/agentMacAddress"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentNtDomain"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentNtDomain:'"/>
      <xsl:with-param name="value" select="$event/agentNtDomain"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentReceiptTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentReceiptTime:'"/>
      <xsl:with-param name="value" select="$event/agentReceiptTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentSeverity"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentSeverity:'"/>
      <xsl:with-param name="value" select="$event/agentSeverity"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentTimeZone"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentTimeZone:'"/>
      <xsl:with-param name="value" select="$event/agentTimeZone"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentTranslatedAddress"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentTranslatedAddress:'"/>
      <xsl:with-param name="value" select="$event/agentTranslatedAddress"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentTranslatedZoneExternalID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentTranslatedZoneExternalID:'"/>
      <xsl:with-param name="value" select="$event/agentTranslatedZoneExternalID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentTranslatedZoneID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentTranslatedZoneID:'"/>
      <xsl:with-param name="value" select="$event/agentTranslatedZoneID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentTranslatedZoneReferenceID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentTranslatedZoneReferenceID:'"/>
      <xsl:with-param name="value" select="$event/agentTranslatedZoneReferenceID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentTranslatedZoneURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentTranslatedZoneURI:'"/>
      <xsl:with-param name="value" select="$event/agentTranslatedZoneURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentZoneExternalID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentZoneExternalID:'"/>
      <xsl:with-param name="value" select="$event/agentZoneExternalID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentZoneID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentZoneID:'"/>
      <xsl:with-param name="value" select="$event/agentZoneID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentZoneReferenceID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentZoneReferenceID:'"/>
      <xsl:with-param name="value" select="$event/agentZoneReferenceID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentZoneURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentZoneURI:'"/>
      <xsl:with-param name="value" select="$event/agentZoneURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/agentZoneURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'agentZoneURI:'"/>
      <xsl:with-param name="value" select="$event/agentZoneURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="category-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/categoryBehavior"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'categoryBehavior:'"/>
      <xsl:with-param name="value" select="$event/categoryBehavior"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/categoryCustomFormatField"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'categoryCustomFormatField:'"/>
      <xsl:with-param name="value" select="$event/categoryCustomFormatField"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/categoryDescriptorId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'categoryDescriptorId:'"/>
      <xsl:with-param name="value" select="$event/categoryDescriptorId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/categoryDeviceGroup"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'categoryDeviceGroup:'"/>
      <xsl:with-param name="value" select="$event/categoryDeviceGroup"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/categoryObject"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'categoryObject:'"/>
      <xsl:with-param name="value" select="$event/categoryObject"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/categoryOutcome"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'categoryOutcome:'"/>
      <xsl:with-param name="value" select="$event/categoryOutcome"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/categorySignificance"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'categorySignificance:'"/>
      <xsl:with-param name="value" select="$event/categorySignificance"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/categoryTechnique"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'categoryTechnique:'"/>
      <xsl:with-param name="value" select="$event/categoryTechnique"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/categoryTupleDescription"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'categoryTupleDescription:'"/>
      <xsl:with-param name="value" select="$event/categoryTupleDescription"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="target-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/targetAddress"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'targetAddress:'"/>
      <xsl:with-param name="value" select="$event/targetAddress"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/targetHostName"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'targetHostName:'"/>
      <xsl:with-param name="value" select="$event/targetHostName"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/targetPort"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'targetPort:'"/>
      <xsl:with-param name="value" select="$event/targetPort"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/targetUserId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'targetUserId:'"/>
      <xsl:with-param name="value" select="$event/targetUserId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="destination-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/destinationAddress"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationAddress:'"/>
      <xsl:with-param name="value" select="$event/destinationAddress"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationAssetId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationAssetId:'"/>
      <xsl:with-param name="value" select="$event/destinationAssetId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationDnsDomain"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationDnsDomain:'"/>
      <xsl:with-param name="value" select="$event/destinationDnsDomain"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationGeoCountryCode"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationGeoCountryCode:'"/>
      <xsl:with-param name="value" select="$event/destinationGeoCountryCode"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationGeoDescriptorId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationGeoDescriptorId:'"/>
      <xsl:with-param name="value" select="$event/destinationGeoDescriptorId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationGeoLatitude"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationGeoLatitude:'"/>
      <xsl:with-param name="value" select="$event/destinationGeoLatitude"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationGeoLocationInfo"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationGeoLocationInfo:'"/>
      <xsl:with-param name="value" select="$event/destinationGeoLocationInfo"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationGeoLongitude"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationGeoLongitude:'"/>
      <xsl:with-param name="value" select="$event/destinationGeoLongitude"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationGeoPostalCode"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationGeoPostalCode:'"/>
      <xsl:with-param name="value" select="$event/destinationGeoPostalCode"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationGeoRegionCode"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationGeoRegionCode:'"/>
      <xsl:with-param name="value" select="$event/destinationGeoRegionCode"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationHostName"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationHostName:'"/>
      <xsl:with-param name="value" select="$event/destinationHostName"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationMacAddress"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationMacAddress:'"/>
      <xsl:with-param name="value" select="$event/destinationMacAddress"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationNtDomain"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationNtDomain:'"/>
      <xsl:with-param name="value" select="$event/destinationNtDomain"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationPort"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationPort:'"/>
      <xsl:with-param name="value" select="$event/destinationPort"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationProcessName"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationProcessName:'"/>
      <xsl:with-param name="value" select="$event/destinationProcessName"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationServiceName"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationServiceName:'"/>
      <xsl:with-param name="value" select="$event/destinationServiceName"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationTranslatedAddress"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationTranslatedAddress:'"/>
      <xsl:with-param name="value" select="$event/destinationTranslatedAddress"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationTranslatedPort"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationTranslatedPort:'"/>
      <xsl:with-param name="value" select="$event/destinationTranslatedPort"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationTranslatedZoneExternalID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationTranslatedZoneExternalID:'"/>
      <xsl:with-param name="value" select="$event/destinationTranslatedZoneExternalID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationTranslatedZoneID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationTranslatedZoneID:'"/>
      <xsl:with-param name="value" select="$event/destinationTranslatedZoneID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationTranslatedZoneReferenceID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationTranslatedZoneReferenceID:'"/>
      <xsl:with-param name="value" select="$event/destinationTranslatedZoneReferenceID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationTranslatedZoneURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationTranslatedZoneURI:'"/>
      <xsl:with-param name="value" select="$event/destinationTranslatedZoneURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationUserId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationUserId:'"/>
      <xsl:with-param name="value" select="$event/destinationUserId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationUserName"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationUserName:'"/>
      <xsl:with-param name="value" select="$event/destinationUserId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationUserPrivileges"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationUserPrivileges:'"/>
      <xsl:with-param name="value" select="$event/destinationUserPrivileges"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationZoneExternalID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationZoneExternalID:'"/>
      <xsl:with-param name="value" select="$event/destinationZoneExternalID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationZoneID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationZoneID:'"/>
      <xsl:with-param name="value" select="$event/destinationZoneID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationZoneReferenceID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationZoneReferenceID:'"/>
      <xsl:with-param name="value" select="$event/destinationZoneReferenceID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/destinationZoneURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'destinationZoneURI:'"/>
      <xsl:with-param name="value" select="$event/destinationZoneURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="attacker-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/attackerAddress"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'attackerAddress:'"/>
      <xsl:with-param name="value" select="$event/attackerAddress"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/attackerHostName"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'attackerHostName:'"/>
      <xsl:with-param name="value" select="$event/attackerHostName"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/attackerPort"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'attackerPort:'"/>
      <xsl:with-param name="value" select="$event/attackerPort"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/attackerUserId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'attackerUserId:'"/>
      <xsl:with-param name="value" select="$event/attackerUserId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="event-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/eventAnnotationAuditTrail"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationAuditTrail:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationAuditTrail"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationComment"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationComment:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationComment"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationEndTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationEndTime:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationEndTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationEventId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationEventId:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationEventId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationFlags"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationFlags:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationFlags"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationManagerReceiptTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationManagerReceiptTime:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationManagerReceiptTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationModificationTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationModificationTime:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationModificationTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationModifiedByExternalID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationModifiedByExternalID:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationModifiedByExternalID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationModifiedByID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationModifiedByID:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationModifiedByID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationModifiedByReferenceID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationModifiedByReferenceID:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationModifiedByReferenceID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationModifiedByURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationModifiedByURI:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationModifiedByURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationStageEventId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationStageEventId:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationStageEventId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationStageExternalID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationStageExternalID:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationStageExternalID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationStageID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationStageID:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationStageID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationStageReferenceID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationStageReferenceID:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationStageReferenceID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationStageURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationStageURI:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationStageURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationStageUpdateTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationStageUpdateTime:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationStageUpdateTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationStageUserExternalID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationStageUserExternalID:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationStageUserExternalID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationStageUserID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationStageUserID:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationStageUserID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationStageUserReferenceID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationStageUserReferenceID:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationStageUserReferenceID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationStageUserURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationStageUserURI:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationStageUserURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/eventAnnotationVersion"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationVersion:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationVersion"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="file-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/fileName"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'fileName:'"/>
      <xsl:with-param name="value" select="$event/fileName"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/fileCreateTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'fileCreateTime:'"/>
      <xsl:with-param name="value" select="$event/fileCreateTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/fileHash"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'fileHash:'"/>
      <xsl:with-param name="value" select="$event/fileHash"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/fileId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'fileId:'"/>
      <xsl:with-param name="value" select="$event/fileId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/fileModificationTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'fileModificationTime:'"/>
      <xsl:with-param name="value" select="$event/fileModificationTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/filePath"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'filePath:'"/>
      <xsl:with-param name="value" select="$event/filePath"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/filePermission"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'filePermission:'"/>
      <xsl:with-param name="value" select="$event/filePermission"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/fileSize"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'fileSize:'"/>
      <xsl:with-param name="value" select="$event/fileSize"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="flex-event"><!--{{{-->
    <xsl:param name="event"/>
  </xsl:template><!--}}}-->
  <xsl:template name="generator-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/generatorExternalID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'generatorExternalID:'"/>
      <xsl:with-param name="value" select="$event/generatorExternalID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/generatorID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'generatorID:'"/>
      <xsl:with-param name="value" select="$event/generatorID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/generatorReferenceID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'generatorReferenceID:'"/>
      <xsl:with-param name="value" select="$event/generatorReferenceID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/generatorURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'generatorURI:'"/>
      <xsl:with-param name="value" select="$event/generatorURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="oldfile-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/oldFileCreateTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'oldFileCreateTime:'"/>
      <xsl:with-param name="value" select="$event/oldFileCreateTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/oldFileHash"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'oldFileHash:'"/>
      <xsl:with-param name="value" select="$event/oldFileHash"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/oldFileId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'oldFileId:'"/>
      <xsl:with-param name="value" select="$event/oldFileId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/oldFileModificationTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'oldFileModificationTime:'"/>
      <xsl:with-param name="value" select="$event/oldFileModificationTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/oldFileName"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'oldFileName:'"/>
      <xsl:with-param name="value" select="$event/oldFileName"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/oldFilePath"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'oldFilePath:'"/>
      <xsl:with-param name="value" select="$event/oldFilePath"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/oldFilePermission"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'oldFilePermission:'"/>
      <xsl:with-param name="value" select="$event/oldFilePermission"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/oldFileSize"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'oldFileSize:'"/>
      <xsl:with-param name="value" select="$event/oldFileSize"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/oldFileType"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'oldFileType:'"/>
      <xsl:with-param name="value" select="$event/oldFileSize"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="request-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/requestClientApplication"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'requestClientApplication:'"/>
      <xsl:with-param name="value" select="$event/requestClientApplication"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/requestContext"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'requestContext:'"/>
      <xsl:with-param name="value" select="$event/requestContext"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/requestCookies"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'requestCookies:'"/>
      <xsl:with-param name="value" select="$event/requestCookies"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/requestMethod"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'requestMethod:'"/>
      <xsl:with-param name="value" select="$event/requestMethod"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/requestUrl"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'requestUrl:'"/>
      <xsl:with-param name="value" select="$event/requestUrl"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="source-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/sourceAddress"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceAddress:'"/>
      <xsl:with-param name="value" select="$event/sourceAddress"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceAssetId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceAssetId:'"/>
      <xsl:with-param name="value" select="$event/sourceAssetId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceDnsDomain"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceDnsDomain:'"/>
      <xsl:with-param name="value" select="$event/sourceDnsDomain"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceGeoCountryCode"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceGeoCountryCode:'"/>
      <xsl:with-param name="value" select="$event/sourceGeoCountryCode"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceGeoDescriptorId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceGeoDescriptorId:'"/>
      <xsl:with-param name="value" select="$event/sourceGeoDescriptorId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceGeoLatitude"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceGeoLatitude:'"/>
      <xsl:with-param name="value" select="$event/sourceGeoLatitude"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceGeoLocationInfo"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceGeoLocationInfo:'"/>
      <xsl:with-param name="value" select="$event/sourceGeoLocationInfo"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceGeoLongitude"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceGeoLongitude:'"/>
      <xsl:with-param name="value" select="$event/sourceGeoLongitude"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceGeoPostalCode"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceGeoPostalCode:'"/>
      <xsl:with-param name="value" select="$event/sourceGeoPostalCode"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceGeoRegionCode"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceGeoRegionCode:'"/>
      <xsl:with-param name="value" select="$event/sourceGeoRegionCode"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceMacAddress"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceMacAddress:'"/>
      <xsl:with-param name="value" select="$event/sourceMacAddress"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceNtDomain"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceNtDomain:'"/>
      <xsl:with-param name="value" select="$event/sourceNtDomain"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceTranslatedAddress"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceTranslatedAddress:'"/>
      <xsl:with-param name="value" select="$event/sourceTranslatedAddress"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceTranslatedPort"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceTranslatedPort:'"/>
      <xsl:with-param name="value" select="$event/sourceTranslatedPort"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceTranslatedZoneExternalID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceTranslatedZoneExternalID:'"/>
      <xsl:with-param name="value" select="$event/sourceTranslatedZoneExternalID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceTranslatedZoneID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceTranslatedZoneID:'"/>
      <xsl:with-param name="value" select="$event/sourceTranslatedZoneID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceTranslatedZoneReferenceID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceTranslatedZoneReferenceID:'"/>
      <xsl:with-param name="value" select="$event/sourceTranslatedZoneReferenceID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceTranslatedZoneURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceTranslatedZoneURI:'"/>
      <xsl:with-param name="value" select="$event/sourceTranslatedZoneURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceUserName"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceUserName:'"/>
      <xsl:with-param name="value" select="$event/sourceUserName"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceUserPrivileges"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceUserPrivileges:'"/>
      <xsl:with-param name="value" select="$event/sourceUserPrivileges"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceZoneExternalID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceZoneExternalID:'"/>
      <xsl:with-param name="value" select="$event/sourceZoneExternalID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceZoneID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceZoneID:'"/>
      <xsl:with-param name="value" select="$event/sourceZoneID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceZoneReferenceID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceZoneReferenceID:'"/>
      <xsl:with-param name="value" select="$event/sourceZoneReferenceID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sourceZoneURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sourceZoneURI:'"/>
      <xsl:with-param name="value" select="$event/sourceZoneURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="device-custom-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/deviceCustomString1"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="$event/deviceCustom/map/string1Label/text()"/>
      <xsl:with-param name="value" select="$event/deviceCustomString1"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceCustomString2"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="$event/deviceCustom/map/string2Label/text()"/>
      <xsl:with-param name="value" select="$event/deviceCustomString2"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceCustomString3"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="$event/deviceCustom/map/string3Label/text()"/>
      <xsl:with-param name="value" select="$event/deviceCustomString3"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceCustomString4"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="$event/deviceCustom/map/string4Label/text()"/>
      <xsl:with-param name="value" select="$event/deviceCustomString4"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceCustomString5"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="$event/deviceCustom/map/string5Label/text()"/>
      <xsl:with-param name="value" select="$event/deviceCustomString5"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceCustomString6"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="$event/deviceCustom/map/string6Label/text()"/>
      <xsl:with-param name="value" select="$event/deviceCustomString6"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceCustomDate1"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="$event/deviceCustom/map/date1Label/text()"/>
      <xsl:with-param name="value" select="$event/deviceCustomDate1"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceCustomDate2"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="$event/deviceCustom/map/date2Label/text()"/>
      <xsl:with-param name="value" select="$event/deviceCustomDate2"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceCustomNumber1"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="$event/deviceCustom/map/number1Label/text()"/>
      <xsl:with-param name="value" select="$event/deviceCustomNumber1"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceCustomNumber2"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="$event/deviceCustom/map/number2Label/text()"/>
      <xsl:with-param name="value" select="$event/deviceCustomNumber2"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceCustomNumber3"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="$event/deviceCustom/map/number3Label/text()"/>
      <xsl:with-param name="value" select="$event/deviceCustomNumber3"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceCustomDescriptorId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="$event/deviceCustom/map/descriptorId/text()"/>
      <xsl:with-param name="value" select="$event/deviceCustomDescriptorId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="device-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/deviceAssetId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceAssetId:'"/>
      <xsl:with-param name="value" select="$event/deviceAssetId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceDescriptorId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceDescriptorId:'"/>
      <xsl:with-param name="value" select="$event/deviceDescriptorId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceDirection"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceDirection:'"/>
      <xsl:with-param name="value" select="$event/deviceDirection"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceDnsDomain"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceDnsDomain:'"/>
      <xsl:with-param name="value" select="$event/deviceDnsDomain"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceDomain"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceDomain:'"/>
      <xsl:with-param name="value" select="$event/deviceDomain"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceEventCategory"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceEventCategory:'"/>
      <xsl:with-param name="value" select="$event/deviceEventCategory"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceEventClassId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceEventClassId:'"/>
      <xsl:with-param name="value" select="$event/deviceEventClassId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceExternalId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceExternalId:'"/>
      <xsl:with-param name="value" select="$event/deviceExternalId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceFacility"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceFacility:'"/>
      <xsl:with-param name="value" select="$event/deviceFacility"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceMacAddress"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceMacAddress:'"/>
      <xsl:with-param name="value" select="$event/deviceMacAddress"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceNtDomain"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceNtDomain:'"/>
      <xsl:with-param name="value" select="$event/deviceNtDomain"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/devicePayloadId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'devicePayloadId:'"/>
      <xsl:with-param name="value" select="$event/devicePayloadId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceReceiptTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceReceiptTime:'"/>
      <xsl:with-param name="value" select="$event/deviceReceiptTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceSeverity"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceSeverity:'"/>
      <xsl:with-param name="value" select="$event/deviceSeverity"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceTimeZone"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceTimeZone:'"/>
      <xsl:with-param name="value" select="$event/deviceTimeZone"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceTranslatedAddress"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceTranslatedAddress:'"/>
      <xsl:with-param name="value" select="$event/deviceTranslatedAddress"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceTranslatedZoneExternalID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceTranslatedZoneExternalID:'"/>
      <xsl:with-param name="value" select="$event/deviceTranslatedZoneExternalID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceTranslatedZoneID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceTranslatedZoneID:'"/>
      <xsl:with-param name="value" select="$event/deviceTranslatedZoneID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceTranslatedZoneReferenceID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceTranslatedZoneReferenceID:'"/>
      <xsl:with-param name="value" select="$event/deviceTranslatedZoneReferenceID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceTranslatedZoneURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceTranslatedZoneURI:'"/>
      <xsl:with-param name="value" select="$event/deviceTranslatedZoneURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceZoneExternalID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceZoneExternalID:'"/>
      <xsl:with-param name="value" select="$event/deviceZoneExternalID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceZoneID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceZoneID:'"/>
      <xsl:with-param name="value" select="$event/deviceZoneID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceZoneReferenceID"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceZoneReferenceID:'"/>
      <xsl:with-param name="value" select="$event/deviceZoneReferenceID"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/deviceZoneURI"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'deviceZoneURI:'"/>
      <xsl:with-param name="value" select="$event/deviceZoneURI"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="generic-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/baseEventCount"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'baseEventCount:'"/>
      <xsl:with-param name="value" select="$event/baseEventCount"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/endTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'endTime:'"/>
      <xsl:with-param name="value" select="$event/endTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/startTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'startTime:'"/>
      <xsl:with-param name="value" select="$event/startTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/locality"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'locality:'"/>
      <xsl:with-param name="value" select="$event/locality"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/managerReceiptTime"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'managerReceiptTime:'"/>
      <xsl:with-param name="value" select="$event/managerReceiptTime"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/modelConfidence"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'modelConfidence:'"/>
      <xsl:with-param name="value" select="$event/modelConfidence"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/originator"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'originator:'"/>
      <xsl:with-param name="value" select="$event/originator"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/priority"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'priority:'"/>
      <xsl:with-param name="value" select="$event/priority"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/relevance"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'relevance:'"/>
      <xsl:with-param name="value" select="$event/relevance"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/ruleThreadId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'ruleThreadId:'"/>
      <xsl:with-param name="value" select="$event/ruleThreadId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/sessionId"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'sessionId:'"/>
      <xsl:with-param name="value" select="$event/sessionId"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/severity"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'severity:'"/>
      <xsl:with-param name="value" select="$event/severity"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
    <xsl:if test="$event/type"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'type:'"/>
      <xsl:with-param name="value" select="$event/type"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="boilerplate-event"><!--{{{-->
    <xsl:param name="event"/>
    <xsl:if test="$event/eventAnnotationAuditTrail"><!--{{{-->
    <xsl:call-template name="display_row">
      <xsl:with-param name="label" select="'eventAnnotationAuditTrail:'"/>
      <xsl:with-param name="value" select="$event/eventAnnotationAuditTrail"/>
    </xsl:call-template>
    </xsl:if><!--}}}-->
  </xsl:template><!--}}}-->
  <xsl:template name="display_row"><!--{{{-->
    <xsl:param name="label"/>
    <xsl:param name="value"/>
    <tr>
      <td style="vertical-align: text-top;" class="label"><xsl:value-of select="$label"/></td>
      <td colspan="2" class="value"><xsl:value-of select="$value"/></td>
    </tr>
  </xsl:template><!--}}}-->
</xsl:stylesheet>
