<cfcomponent output="false">
	<cfset variables.dsn = "">
	<cfset variables.modWeightTableQuery = "">
	<cfset variables.SCsubstitutionTableStruct =StructNew()>
	
	<cffunction name="init" access="public" returntype="Any" output="false">
		<cfargument name="dsn" required="false" type="string" default="#request.inbaseDSN#"/>
		<cfset variables.dsn = arguments.dsn>
		<cfset setModWeightTableQuery()>
		<cfset setSCsubstitutionTableStruct()>
		
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="setModWeightTableQuery" access="public" returntype="void" output="false">
		<cfset var qVALACDOS = "">
		<cfquery name="qVALACDOS" datasource="#variables.dsn#">
			SELECT [Id] AS sortOrder
			      ,CAST(StartSortCode as int) AS startRange
			      ,CAST(EndSortCode as int) AS endRange
			      ,[ModCheck] AS type
			      ,CAST(U as varchar)
			      	+'|'+CAST(V as varchar) 
					+'|'+CAST(W as varchar) 
					+'|'+CAST(X as varchar) 
					+'|'+CAST(Y as varchar) 
					+'|'+CAST(Z as varchar) 
					+'|'+CAST(A as varchar) 
					+'|'+CAST(B as varchar) 
					+'|'+CAST(C as varchar) 
					+'|'+CAST(D as varchar) 
					+'|'+CAST(E as varchar) 
					+'|'+CAST(F as varchar) 
					+'|'+CAST(G as varchar) 
					+'|'+CAST(H as varchar) AS weight
			      ,CAST(EX as int) AS exceptionRule
			FROM [VALACDOS]
			ORDER BY Id ASC
		</cfquery>
		<cfset variables.modWeightTableQuery = qVALACDOS>
		<cfreturn />
	</cffunction>
		
	<cffunction name="getModWeightTableQuery" access="public" returntype="query" output="false">
		<cfreturn variables.modWeightTableQuery />
	</cffunction>
		
	<cffunction name="setSCsubstitutionTableStruct" access="public" returntype="void" output="false">
		<cfset var qSCSUBTAB = "">
		<cfquery name="qSCSUBTAB" datasource="#variables.dsn#">
		  SELECT [Id]
		      ,[OriginalSortCode]
		      ,[SubstituteSortCode]
		  FROM [SCSUBTAB]
		</cfquery>
		
		<cfloop query="qSCSUBTAB">
			<cfset variables.SCsubstitutionTableStruct[Trim(OriginalSortCode)] = Trim(SubstituteSortCode)>
		</cfloop>

		<cfreturn />
	</cffunction>
		
	<cffunction name="getSCsubstitutionTableStruct" access="public" returntype="struct" output="false">
		<cfreturn variables.scsubstitutionTableStruct />
	</cffunction>
</cfcomponent>