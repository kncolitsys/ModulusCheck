<!--- 
	<name></name>
	<description>
	</description>
	<version>
		<v1>
			<date>27/July/2008</date>
			<who>DW</who>
		  <change>
		  	new file - account validator.
		  	 - loads modulus & sort code substitution tables
		  	 - performs initial processing on sortcode / account number
		  	 - applies correct ruleProcessor modulus checks
		  </change>
		 </v1>
	</version>
	<parameters>
		<in>
	 		<var></var>
			<req></req>
	 		<use>
			</use>
		 </in>
		<out>
	 		<var></var>
	 		<use></use>
		</out>
	</parameters>
	<accessibility>
		<date>dd/mmm/yyyy</date>
		<comment>comment on last accessibility review</comment>
	</accessibility>
 --->
<cfcomponent output="false">
	<cfset variables.modulusData = "">
	<cfset variables.ruleProcessor = "">
	
	<cffunction name="init" access="public" returntype="accountValidator" output="false">
		<cfargument name="ModulusData" required="true" type="any" />
		<cfargument name="ruleProcessorPath" required="false" type="string" default="ruleProcessor" />
		
		<cfset setModulusData(arguments.ModulusData)>
		<cfset setRuleProcessor(arguments.ruleProcessorPath)>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="setModulusData" access="public" returntype="void" output="false">
		<cfargument name="ModulusData" required="true" type="any" />
		<cfset variables.ModulusData = arguments.ModulusData>
	</cffunction>
		
	<cffunction name="getModulusData" access="public" returntype="any" output="false">
		<cfreturn variables.ModulusData />
	</cffunction>
	
	<cffunction name="setRuleProcessor" access="public" returntype="void" output="false">
		<cfargument name="ruleProcessorPath" required="true" type="string" />
		<cfset variables.ruleProcessor = CreateObject("component", arguments.ruleProcessorPath)>
	</cffunction>
	
	<cffunction name="getRuleProcessor" access="public" returntype="any" output="false">
		<cfreturn variables.ruleProcessor />
	</cffunction>
	
	<cffunction name="validate" access="public" returntype="struct" output="false">
		<cfargument name="sortcode" required="true" type="numeric" />
		<cfargument name="accountnumber" required="true" type="numeric" />
		<cfset var rtn = StructNew()>
		<cfset var modulusQuery =  getModulusData().getModWeightTableQuery()>
		<cfset var scsubstitutionTable = getModulusData().getSCsubstitutionTableStruct()>
		<cfset var score = 0>
		<cfset var exceptionSix = StructNew()>
		<cfset var ruleProcessor = getRuleProcessor()>
		<cfset rtn.skipChecks = false>
		
		<!--- 1 The sorting code and account number must be numeric --->
		
		<!--- 
			2 Locate the row(s) for the sorting code in the modulus weight table 
			Find the row(s) in the modulus weight table where the sorting code is within the range defined by the sorting code range start and end. Up to two rows may be found.
		--->
		
		<cfquery dbtype="query" name="rtn.qModulusRows">
			SELECT
				startRange,endRange,type,weight,exceptionRule,sortOrder
			FROM
				modulusQuery
			WHERE
				startRange <= #arguments.sortcode#
			AND
				endRange >= #arguments.sortcode#
			ORDER BY sortOrder
		</cfquery>
		
		<cfset rtn.exceptionRules = ValueList(rtn.qModulusRows.exceptionRule, ",")>
		<cfset rtn.checkTypes = ValueList(rtn.qModulusRows.type, ",")>
		<cfset rtn.outof = ListLen(rtn.checkTypes, ",")>
		<cfset rtn.score = 0>
		<!--- If no rows are found, then the sorting code and account number are deemed to be valid. Set the valid flag to Y and end the procedure --->		
		<cfif rtn.qModulusRows.recordCount>
			
			<cfswitch expression="#rtn.qModulusRows.exceptionRule#">
				<cfcase value="6">
					<!--- If the exception rule = 6, and the first digit of the account number is 4, 5, 6, 7 or 8, and the last two digits of the account number are the same, then the sorting code and account number are deemed to be valid. Set the valid flag to Y and end the procedure --->
					<cfset exceptionSix.firstChar = ListFindNoCase("4,5,6,7,8", Left(arguments.accountNumber, 1))>
					<cfset exceptionSix.lastTwoDigits = Right(arguments.accountNumber, 2)>
					<cfset exceptionSix.lastTwoDigitsSame = NOT (exceptionSix.lastTwoDigits MOD 11)>
					<cfif exceptionSix.firstChar AND exceptionSix.lastTwoDigitsSame>
						<cfset rtn.skipChecks = true>
					</cfif>
				</cfcase>
				<cfcase value="5">
					<!--- If the exception rule = 5, search the sorting code substitution table Scsubtab.txt file. If the sorting code is found in the table, replace it with the substitute with sorting code and continue with the checking process. If no entry is found, continue using the original sorting code. Note that the substitute sorting code is used for modulus checking purposes only. --->
					<cfif StructKeyExists(scsubstitutionTable, arguments.sortcode)>
						<cfset arguments.sortcode = scsubstitutionTable[arguments.sortcode]>
					</cfif>
				</cfcase>
			</cfswitch>
			
			<cfif not rtn.skipChecks>
				<cfloop query="rtn.qModulusRows">
						<cfinvoke component="ruleProcessor" 
						    method="#type#"
						    returnVariable="score">
						    <cfinvokeargument name="sortcode" value="#arguments.sortcode#">
						    <cfinvokeargument name="accountnumber" value="#arguments.accountnumber#">
					    	<cfinvokeargument name="weight" value="#weight#">
				    		<cfinvokeargument name="exceptionRule" value="#exceptionRule#">
						</cfinvoke>
						<cfif ListFindNoCase("2,9,10,11,12,13", exceptionRule, ",") AND score EQ 1>
							<!--- If the exception rule = 2, 9, 10, 11, 12 or 13, and the check with that exception rule has shown the sorting code and account number to be valid, ignore any remaining rows. Set the valid flag to Y and end the procedure. --->
							<cfset rtn.score = rtn.score + 1>
						</cfif>
					<!--- adjust the total score for the account --->
					<cfset rtn.score = rtn.score + score>
				</cfloop>
			</cfif>
			
		</cfif>
		
		<cfif rtn.score GTE rtn.outof>
			<cfset rtn.isAccountValid = true>
		<cfelseif rtn.skipChecks>
			<cfset rtn.isAccountValid = true>
		<cfelse>
			<cfset rtn.isAccountValid = false>
		</cfif>
		
		<cfreturn rtn>
		
	</cffunction>
			
</cfcomponent>