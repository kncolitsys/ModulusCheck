<cfcomponent output="false">
	<cfset variables.newline = Chr( 10 )>
	<cfset variables.tab = Chr( 9 )>
	<cfset variables.modWeightTableQuery = "">
	<cfset variables.SCsubstitutionTableStruct =StructNew()>
	
	<cffunction name="init" access="public" returntype="Any" output="false">
		<cfargument name="modWeightFile" required="false" type="string" default="VALACDOS.txt"/>
		<cfargument name="scSubTableFile" required="false" type="string" default="SCSUBTAB.txt"/>
		
		<cfset setModWeightTableQuery(arguments.modWeightFile)>
				
		<cfset setSCsubstitutionTableStruct(arguments.scSubTableFile)>
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="setModWeightTableQuery" access="public" returntype="void" output="false">
		<cfargument name="modWeightFile" required="true" type="string" />
			<cfset var modWeightTableText = "">
			<!--- load modulus weight table (from file) --->
			<cfsaveContent variable="modWeightTableText">
				<cfoutput><cfinclude template="#arguments.modWeightFile#"></cfoutput>
			</cfsaveContent>
			<!--- convert modulus weight table to CF query  --->
			<cfset variables.modWeightTableQuery = CSVToModulusWeightQuery(Trim(modWeightTableText), variables.newline, " ")>
			<cfreturn />
	</cffunction>
		
	<cffunction name="getModWeightTableQuery" access="public" returntype="query" output="false">
		<cfreturn variables.modWeightTableQuery />
	</cffunction>
		
	<cffunction name="setSCsubstitutionTableStruct" access="public" returntype="void" output="false">
		<cfargument name="scSubTableFile" required="true" type="string" />
		<cfset var scsubstitutionTableText = "">
		<cfsaveContent variable="scsubstitutionTableText">
			<cfoutput><cfinclude template="#arguments.scSubTableFile#"></cfoutput>
		</cfsaveContent>
		<cfset variables.scsubstitutionTableStruct = CSVToSortCodeSubstitutionStruct(Trim(scsubstitutionTableText), variables.newline, " ")>
	</cffunction>
		
	<cffunction name="getSCsubstitutionTableStruct" access="public" returntype="struct" output="false">
		<cfreturn variables.scsubstitutionTableStruct />
	</cffunction>
	
	<cffunction name="CSVToModulusWeightQuery" access="public" returntype="query" output="false" hint="Converts the given CSV string to a query.">
		<cfargument name="CSV" type="string" required="true" />
		<cfargument name="newline" type="string" required="false" default="#variables.newline#" />
		<cfargument name="delimiter" type="string" 	required="false" default="," />
		
		<cfset var modulusQuery = QueryNew("startRange,endRange,type,weight,exceptionRule,sortOrder", "Integer,Integer,VarChar,VarChar,Integer,Integer")>
		<cfset var arRows = ListToArray(Trim(arguments.CSV), arguments.newline)>
		<cfset var numRows = ArrayLen(arRows)>
		<cfset var arRow = ArrayNew(1)>
		<cfset var numCols = ArrayLen(arRow)>
		<cfset var i = 0>
		<cfset var j = 0>
		<cfset var startVal = 0>
		<cfset var endVal = 0>
		<cfset var modCheckType = "">
		<cfset var modCheckWeight = "">
		<cfset var modCheckException = "">
		
		<cfloop from="1" to="#numRows#" index="i">
			<cfset arRow = ListToArray(arRows[i], arguments.delimiter)>
			<cfset arRows[i] = arRow>
		</cfloop>
		
		<cfloop from="1" to="#numRows#" index="i">
			<cfset arRow = arRows[i]>
			<cfset numCols = ArrayLen(arRow)>
			<cfset modCheckWeight = "">
			<cfif numCols GTE 17>
				<cfset startVal = arRow[1]>
				<cfset endVal = arRow[2]>
				<cfset modCheckType = arRow[3]>
				<cfloop from="4" to="17" index="j">
					<cfset modCheckWeight = "#modCheckWeight# #arRow[j]#">
				</cfloop>
				<cfif numCols GTE "18">
					<cfset modCheckException = arRow[18]>
					<cfif not IsNumeric(modCheckException)>
						<cfset modCheckException = "0">
					</cfif>
				<cfelse>
					<cfset modCheckException = "0">
				</cfif>
				
				<cfset tmp = QueryAddRow(modulusQuery)>
				<cfset tmp = QuerySetCell(modulusQuery, "startRange", startVal)>
				<cfset tmp = QuerySetCell(modulusQuery, "endRange", endVal)>
				<cfset tmp = QuerySetCell(modulusQuery, "type", modCheckType)>
				<cfset tmp = QuerySetCell(modulusQuery, "weight", modCheckWeight)>
				<cfset tmp = QuerySetCell(modulusQuery, "exceptionRule", modCheckException)>
				<cfset tmp = QuerySetCell(modulusQuery, "sortOrder", i)>
				
			</cfif>
			
		</cfloop>
		
		<cfreturn modulusQuery>
		
	</cffunction>
	
	<cffunction name="CSVToSortCodeSubstitutionStruct" access="public" returntype="struct" output="false" hint="Converts the given CSV string to a query.">
		<cfargument name="CSV" type="string" required="true" />
		<cfargument name="newline" type="string" required="false" default="#chr(10)#" />
		<cfargument name="delimiter" type="string" 	required="false" default="," />
		
		<cfset var stSortCodeSubstitutions = StructNew()>
		<cfset var arRows = ListToArray(Trim(arguments.CSV), arguments.newline)>
		<cfset var numRows = ArrayLen(arRows)>
		<cfset var sortcode = "">
		<cfset var substitution = "">
		<cfset var i = 0>
		
		<cfloop from="1" to="#numRows#" index="i">
			<cfset sortcode = ListFirst(arRows[i], arguments.delimiter)>
			<cfset substitution = ListLast(arRows[i], arguments.delimiter)>
			<cfset stSortCodeSubstitutions[sortcode] =  substitution />
		</cfloop>
				
		<cfreturn stSortCodeSubstitutions>
		
	</cffunction>
	
</cfcomponent>