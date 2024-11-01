<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>

			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson">
				<lxslt:script lang="javascript">
					<![CDATA[
					var debugFeed = [];
					var debugFlag = false;
					const symbolWinCounts = [12,11,10,9,8,7,6,5,4,3]; // S1 - S10
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, prizeTable, prizeValues, prizeNamesDesc)
					{
						var scenario = getScenario(jsonContext);
						//var outcomeNums = getOutcomeData(scenario);
						var outcomeDailyGame = getOutcomeData(scenario,0);
						var outcomeCollectionGame = getOutcomeData(scenario,1);
						var prizeNames = (prizeNamesDesc.substring(1)).split(',');
						var convertedPrizeValues = (prizeValues.substring(1)).split('|');

						// Output outcome numbers table.
						var r = [];
 						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
						r.push('<tr>');
 						r.push('<tr>');
 						r.push('<td class="tablehead" width="50%">');
 						r.push(getTranslationByName("game", translations));
 						r.push('</td>');
 						r.push('<td class="tablehead" width="50%">');
 						r.push(getTranslationByName("dailyGames", translations));
						r.push('</td>');
 						r.push('</tr>');
						prizeWon = [];
						prizeWonIndex = 0;
						for(var i = 0; i < outcomeDailyGame.length; ++i)
						{
							r.push('<tr>');
							r.push('<td class="tablebody" width="30%">');
							r.push(i+1);
							r.push('</td>');
							r.push('<td class="tablebody" width="30%">');
							var dayNums = [0,0,0,0,0,0,0,0,0,0,0];
							var symbs = outcomeDailyGame[i].split(",");
							for(var j = 0; j < symbs.length; ++j)
							{
								dayNums[parseInt(symbs[j].substring(1,3))-1]++;
							}
							var prizeWin = 0;
							for(var j = 0; j < dayNums.length; ++j)
							{
 								//r.push(dayNums[j]); // Debug
								if (dayNums[j] > 2)
								{
									prizeWin = j+1;
 									r.push(getTranslationByName("match3", translations) + ': ');
									prizeWon[prizeWonIndex] = "M"+prizeWin;
									prizeWonIndex++;
								}
							}							
							for(var j = 0; j < symbs.length; ++j)
							{
								if (j < (symbs.length-1))
								{
									r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, symbs[j])] + ", ");
								}
								else
								{
									r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, symbs[j])]);
								}
							}
							//r.push(outcomeDailyGame[i]);
 							r.push('</td>');
 							r.push('<td class="tablebody" width="30%">');
							if (prizeWin != 0)
							{
 								r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, "M"+prizeWin)]);
							}
							r.push('</td>');
 							r.push('</tr>');
						}

						// Symbol Game 
						var symbNums = [0,0,0,0,0,0,0,0,0,0];
						r.push('<tr>');
 						r.push('<td class="tablehead" width="50%">');
 						r.push(getTranslationByName("cumulativeGame", translations));
 						r.push('</td>');
						r.push('</tr>');
						r.push('<tr>');
 						r.push('<td class="tablebody" width="50%">');
 						r.push(outcomeCollectionGame);
						r.push('</td>');
						r.push('</tr>');
						r.push('<tr>');
 						r.push('<td class="tablebody" width="50%">');
						for(var i = 0; i< outcomeCollectionGame.length; ++i)
						{
							symbNums[parseInt(outcomeCollectionGame[i].substring(1,3))-1]++;
						}
						for(var i = 0; i < symbNums.length; ++i)
						{
							if (i < symbNums.length -1) 
							{
								r.push('S' + (i+1) + '=' + symbNums[i] + ',');
							}
							else
							{
								r.push('S' + (i+1) + '=' + symbNums[i]);
							}
						}
						r.push('</td>');
						for(var i = 0; i < symbNums.length; ++i)
						{
							prizeWin = 0;
							if (symbNums[i] == symbolWinCounts[i])
							{
								prizeWin = i+1;
								r.push('<tr>');
 								r.push('<td class="tablebody" width="50%">');
								r.push(getTranslationByName("youMatched", translations) + ": S"+prizeWin);
								r.push('</td>');
 								r.push('<td class="tablebody" width="50%">');
 								r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, "S"+prizeWin)]);
								r.push('</td>');
								r.push('</tr>');
								prizeWon[prizeWonIndex] = "S"+prizeWin;
								prizeWonIndex++;
							}
							//if (prizeWin != 0)
							//{
 							//	r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, "S"+prizeWin)]);
							//}
						}							
						r.push('</tr>');

						r.push('</table>');
						r.push('<br />');

						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
 							{
								if(debugFeed[idx] == "")
									continue;
								r.push('<tr>');
 								r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
 								r.push('</td>');
 								r.push('</tr>');
							}
							r.push('</table>');
						}
						return r.join('');
					}
					
					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: "M11,M7,M11,M8:S8|M6,M8,M9,M8:S6|..."
					// Output: ["M11,M7,M11,M8", "M6,M8,M9,M8", ...] or ["S8", "S6" ...]
					function getOutcomeData(scenario, index)
					{
						var outcomeDays = scenario.split("|");
						var result = [];
						for(var i = 0; i < outcomeDays.length; ++i)
						{
							result.push(outcomeDays[i].split(":")[index]);
						}	
						return result;
					}

					// Input: "A,B,C,D,..." and "A"
					// Output: index number
					function getPrizeNameIndex(prizeNames, currPrize)
					{
						
						for(var i = 0; i < prizeNames.length; ++i)
						{
							if(prizeNames[i] == currPrize)
							{
								return i;
							}
						}
					}
						
					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
							{
								registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							index += 1;
						}
					}			
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Wager.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<x:variable name="convertedPrizeValues">
					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>

				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>

				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
						<x:with-param name="value" select="text()" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
			</x:template>
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>