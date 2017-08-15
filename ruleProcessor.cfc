<!--- 
	<name></name>
	<description>
	</description>
	<version>
		<v1>
			<date>27/July/2008</date>
			<who>DW</who>
		  <change>
		  	new file - ruleProcessor.
			  	 - converts data (sortcode / account number / mod weights) to structs (hash tables)
			  	 - performs various modulus checks
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
	
	<cffunction name="MOD11" access="public" output="false" returntype="boolean">
		<cfargument name="sortcode" required="true" type="numeric" />
		<cfargument name="accountnumber" required="true" type="numeric" />
		<cfargument name="weight" required="true" type="string" />
		<cfargument name="exceptionRule" required="true" type="any" />
		<cfset var score = 0>
		<cfset var stNumbers = StructNew()>
		<cfset var stWeight = StructNew()>
		<cfset var arResults = ArrayNew(1)>
		<cfset var sumOfResults = 0>
		<cfset var modResult = 0>
		<cfset var zeroWeight = false>
		<cfset var ab = "">
		<cfset var rule5value = 0>
		<cfset var checkDigit = 0>
		<cfset stNumbers = sortCodeAccountToStruct(arguments.sortCode, arguments.accountnumber)>
		<cfset checkDigit = stNumbers.g>
		<!--- apply exceptions --->
		<cfswitch expression="#arguments.exceptionRule#">
			<cfcase value="2">
				<cfif stNumbers.a NEQ 0 AND checkDigit NEQ 9>
					<cfset arguments.weight = "0 0 1 2 5 3 6 4 8 7 10 9 3 1">
				<cfelseif stNumbers.a NEQ 0 AND stNumbers.g EQ 9>
					<cfset arguments.weight = "0 0 0 0 0 0 0 0 8 7 10 9 3 1">
				</cfif>
			</cfcase>
			<cfcase value="7">
				<cfif checkDigit EQ 9>
					<cfset zeroWeight = true>
				</cfif>
			</cfcase>
			<cfcase value="9">
				<cfset arguments.sortcode = "309634">
				<cfset stNumbers = sortCodeAccountToStruct(arguments.sortCode, arguments.accountnumber)>
			</cfcase>
			<cfcase value="10">
				<cfset ab = "#stNumbers.a##stNumbers.b#">
				<cfif checkDigit EQ 9>
					<cfif ab EQ "09" OR ab EQ "99">
						<cfset zeroWeight = true>
					</cfif>	
				</cfif>					
			</cfcase>
		</cfswitch>
		
		<cfset stWeight = weightToStruct(arguments.weight,zeroWeight)>
		<cfset arResults = multiplyDigitsAndWeights(stNumbers,stWeight)>
		<cfset sumOfResults = ArraySum(arResults)>
		<cfset modResult = sumofResults MOD 11>
		<!--- secondary exceptions --->
		
		<cfswitch expression="#arguments.exceptionRule#">
			<cfcase value="4">
				<!--- If the exception rule = 4, and remainder is equal to the concatenated value of g and h of the original account number, the sorting code and account number are deemed to be valid --->
				<cfif modResult eq "#stNumbers.g##stNumbers.h#">
					<cfset score = 1>
				</cfif>
			</cfcase>
			<cfcase value="5">
					<!--- 
					If the exception rule = 5, subtract the remainder from 11.
					If the result is the same as the checkdigit (g of the original account number) the sorting code and account number are valid, unless the remainder is 0 or 1. 
					- If the remainder is 0, and the checkdigit is 0, the account number and sorting code are valid
					- If the remainder is 1, the account number and sorting code are invalid
				 	--->
				 	<cfset rule5value = 11 - modResult>
				 	<cfif modResult EQ 1>
				 		<cfset score = 0>
				 	<cfelseif modResult EQ 0 AND checkDigit EQ 0>
						<cfset score = 1>
				 	<cfelseif rule5value EQ checkDigit>
						<cfset score = 1>
					</cfif>
			</cfcase>
			<cfdefaultcase>
				<cfif modResult EQ 0>
					<cfset score = 1>
				</cfif>	
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn score>
	</cffunction>
	
	<cffunction name="MOD10" access="public" output="false" returntype="boolean">
		<cfargument name="sortcode" required="true" type="numeric" />
		<cfargument name="accountnumber" required="true" type="numeric" />
		<cfargument name="weight" required="true" type="string" />
		<cfargument name="exceptionRule" required="true" type="any" />
		
		<cfset var score = 0>
		<cfset var stNumbers = StructNew()>
		<cfset var stWeight = StructNew()>
		<cfset var arResults = ArrayNew(1)>
		<cfset var sumOfResults = 0>
		<cfset var modResult = 0>
		
		<!--- apply exceptions --->
		<cfif arguments.exceptionRule EQ 8>
			<cfset arguments.sortcode = "090126">
		</cfif>

		<cfset stNumbers = sortCodeAccountToStruct(arguments.sortCode, arguments.accountnumber)>
		<cfset stWeight = weightToStruct(arguments.weight)>
		<cfset arResults = multiplyDigitsAndWeights(stNumbers,stWeight)>
		<cfset sumOfResults = ArraySum(arResults)>
		<cfset modResult = sumofResults MOD 10 >
		
		<cfif modResult EQ 0>
			<cfset score = 1>
		</cfif>
		
		<cfreturn score>
	</cffunction>
	
	<cffunction name="DBLAL" access="public" output="false" returntype="boolean">
		<cfargument name="sortcode" required="true" type="numeric" />
		<cfargument name="accountnumber" required="true" type="numeric" />
		<cfargument name="weight" required="true" type="string" />
		<cfargument name="exceptionRule" required="true" type="any" />
			<cfset var score = 0>
			<cfset var stNumbers = StructNew()>
			<cfset var stWeight = StructNew()>
			<cfset var arResults = ArrayNew(1)>
			<cfset var sumOfResults = 0>
			<cfset var modResult = 0>
			<cfset var rule5value = 0>
			<cfset var checkDigit = 0>
			
			<cfset stNumbers = sortCodeAccountToStruct(arguments.sortCode, arguments.accountnumber)>		
			<cfset checkDigit = stNumbers.h>
			
			<cfif arguments.exceptionRule EQ 3><!--- primary exception --->
				<cfif stNumbers.c EQ 6 OR stNumbers.c EQ 9>
					<cfset score = 1>
				</cfif>
			</cfif>
			
			<cfif not score>
				<cfset stWeight = weightToStruct(arguments.weight)>
				<cfset arResults = multiplyDigitsAndWeights(stNumbers,stWeight)>
				<cfset sumOfResults = ArraySumSpecial(arResults)>
				<cfif arguments.exceptionRule EQ 1>
					<cfset sumOfResults = sumOfResults + 27>
				</cfif>
				<cfset modResult = sumofResults MOD 10 >
				
				<cfif arguments.exceptionRule EQ 5>
					<cfset rule5value = 10 - modResult><!--- secondary exception --->
				 	<cfif rule5value EQ checkDigit>
				 		<cfset score = 1>
				 	<cfelseif modResult EQ 0 AND checkDigit EQ 0>
						<cfset score = 1>
					</cfif>
				<cfelseif modResult EQ 0><!--- no secondary exception --->
						<cfset score = 1>
				</cfif>
						
			</cfif>
		
			<cfreturn score>
	</cffunction>
	
	<cffunction name="ArraySumSpecial" output="false" returntype="numeric">
		<cfargument name="arResults" required="true" type="array">
		<cfset var num = ArrayLen(arguments.arResults)>
		<cfset var total =0>
		<cfset var i = 0>
		<cfset var result = 0>
		<cfloop from="1" to="#num#" index="i">
			<cfset result = arguments.arResults[i]>
			<cfif result GT 9>
				<cfset result = SubStr(result,1,1) + SubStr(result,2,1)>
			</cfif>
			<cfset total = total + result>
		</cfloop>
		
		<cfreturn total>
	</cffunction>
	
	<cffunction name="sortCodeAccountToStruct" output="false" returntype="struct">
		<cfargument name="sortcode" required="true" type="numeric" />
		<cfargument name="accountnumber" required="true" type="numeric" />
		
		<cfset var stNumbers = StructNew()>
		
		<cfset stNumbers.u = SubStr(arguments.sortCode, 1, 1)>
		<cfset stNumbers.v = SubStr(arguments.sortCode, 2, 1)>
		<cfset stNumbers.w = SubStr(arguments.sortCode, 3, 1)>
		<cfset stNumbers.x = SubStr(arguments.sortCode, 4, 1)>
		<cfset stNumbers.y = SubStr(arguments.sortCode, 5, 1)>
		<cfset stNumbers.z = SubStr(arguments.sortCode, 6, 1)>
		
		<cfset stNumbers.a = SubStr(arguments.accountnumber,1, 1)>
		<cfset stNumbers.b = SubStr(arguments.accountnumber,2, 1)>
		<cfset stNumbers.c = SubStr(arguments.accountnumber,3, 1)>
		<cfset stNumbers.d = SubStr(arguments.accountnumber,4, 1)>
		<cfset stNumbers.e = SubStr(arguments.accountnumber,5, 1)>
		<cfset stNumbers.f = SubStr(arguments.accountnumber,6, 1)>
		<cfset stNumbers.g = SubStr(arguments.accountnumber,7, 1)>
		<cfset stNumbers.h = SubStr(arguments.accountnumber,8, 1)>			
		
		<cfreturn stNumbers>
			
	</cffunction>
	
	<cffunction name="weightToStruct" output="false" returntype="struct">
		<cfargument name="weight" required="true" type="string" />
		<cfargument name="zeroWeight" required="false" type="boolean" default="false"/>
		<cfset var cleanWeight = ReplaceNoCase(arguments.weight, " ", "|", "ALL")>
		<cfset var stWeight = StructNew()>
		
		<cfif arguments.zeroWeight>
			<cfset stWeight.u = 0>
			<cfset stWeight.v = 0>
			<cfset stWeight.w = 0>
			<cfset stWeight.x = 0>
			<cfset stWeight.y = 0>
			<cfset stWeight.z = 0>
			<cfset stWeight.a = 0>
			<cfset stWeight.b = 0>
		<cfelse>
			<cfset stWeight.u = listGetAt(cleanWeight, 1, '|')>
			<cfset stWeight.v = listGetAt(cleanWeight, 2, '|')>
			<cfset stWeight.w = listGetAt(cleanWeight, 3, '|')>
			<cfset stWeight.x = listGetAt(cleanWeight, 4, '|')>
			<cfset stWeight.y = listGetAt(cleanWeight, 5, '|')>
			<cfset stWeight.z = listGetAt(cleanWeight, 6, '|')>
			<cfset stWeight.a = listGetAt(cleanWeight,7, '|')>
			<cfset stWeight.b = listGetAt(cleanWeight,8, '|')>
		</cfif>
		
		<cfset stWeight.c = listGetAt(cleanWeight,9, '|')>
		<cfset stWeight.d = listGetAt(cleanWeight,10, '|')>
		<cfset stWeight.e = listGetAt(cleanWeight,11, '|')>
		<cfset stWeight.f = listGetAt(cleanWeight,12, '|')>
		<cfset stWeight.g = listGetAt(cleanWeight,13, '|')>
		<cfset stWeight.h = listGetAt(cleanWeight,14, '|')>			
		
		<cfreturn stWeight>
			
	</cffunction>
	
	<cffunction name="multiplyDigitsAndWeights" output="false" returntype="array">
			<cfargument name="numbers" required="true" type="struct" />
			<cfargument name="weights" required="true" type="struct" />
			
			<cfset var chars = "u,v,w,x,y,z,a,b,c,d,e,f,g,h">
			<cfset var key = "">
			<cfset var arResults = ArrayNew(1)>
			<cfset var result = 0>
			
			<cfloop list="#chars#" index="key">
				<cftry>
					<cfset result = arguments.numbers[key] * arguments.weights[key]>
					<cfcatch>
						<cfdump var="#cfcatch.message#">
						<cfdump var="#arguments.numbers#">
						<cfdump var="#arguments.weights#">
						<cfdump var=" key: #key#">
						<cfabort />
					</cfcatch>
				</cftry>
				<cfset ArrayAppend(arResults, result)>
			</cfloop>"
					
			<cfreturn arResults>
	</cffunction>
	
	<cfscript>
		/**
		* Returns the substring of a string. It mimics the behaviour of the homonymous php function so it permits negative indexes too.
		* 
		* @param buf      The string to parse. (Required)
		* @param start      The start position index. If negative, counts from the right side. (Required)
		* @param length      Number of characters to return. If not passed, returns from start to end (if positive start value). (Optional)
		* @return Returns a string. 
		* @author Rudi Roselli Pettazzi (rhodion@tiscalinet.it) 
		* @version 2, July 2, 2002 
		*/
		function SubStr(buf, start) {
		// third argument (optional)
		var length = 0;
		var sz = 0;
		        
		sz = len(buf);
	
		if (arrayLen(arguments) EQ 2) {
	
		        if (start GT 0) {
		         length = sz;
		        } else if (start LT 0) {
		         length = sz + start;
		         start = 1;
		        }
		    
		} else {
	
		        length = Arguments[3];
		        if (start GT 0) {
		         if (length LT 0) length = 1+sz+length-start;
		        } else if (start LT 0) {
		         if (length LT 0) length = length-start;
		         start = 1+sz+start;
		         
		        }
		} 
	
		if (isNumeric(start) AND isNumeric(length) AND start GT 0 AND length GT 0) return mid(buf, start, length);
		else return "";
		}
	</cfscript>

</cfcomponent>