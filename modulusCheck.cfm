<cfset ModulusData = createObject('component', 'bankModulus.ModulusDataFile').init()>
<cfset validator = createObject('component', 'bankModulus.accountValidator').init(ModulusData=ModulusData)>

<!--- get test data and convert to array of structs --->
<cfset newline = chr(10)>
<cfset delim = ",">
<cfsaveContent variable="testData">
	<cfinclude template="bankModulus/testcases.csv">
</cfsaveContent>
<cfset arTestData = ArrayNew(1)>
<cfset arRows = ListToArray(Trim(testData), newline)>
<cfset numRows = ArrayLen(arRows)>
<cfloop from="2" to="#numRows#" index="i">
	<cfset testResult = StructNew()>	
	<cfset stTest = StructNew()>	
	<cfset stTest.description = ListGetAt(arRows[i], 1, delim)>
	<cfset stTest.sortcode = Trim(ListGetAt(arRows[i], 2, delim))>
	<cfset stTest.accountnumber = Trim(ListGetAt(arRows[i], 3, delim))>
	<cfset stTest.expectedResult = YesNoFormat(ListGetAt(arRows[i], 4, delim))>
	<cftry>
		<cfset testResult = validator.validate(stTest.sortcode, stTest.accountnumber) >
		<cfset stTest.actualresult = YesNoFormat(testResult.isAccountValid)>
		<cfset stTest.exceptionRules = Trim(testResult.exceptionRules)>
		<cfset stTest.checkTypes = Trim(testResult.checkTypes)>
		<cfset stTest.score = "#testResult.score#/#testResult.outof#">
		<!--- <cfset stTest.qModulus = testResult.qModulusRows> --->
		<cfcatch>
			<cfset stTest.exceptionRules = "error:">
			<cfset stTest.checkTypes = "error:">
			<cfset stTest.actualresult = "error: #cfcatch.message#">
		</cfcatch>
	</cftry>
	<cfif stTest.expectedResult EQ stTest.actualresult>
		<cfset stTest.passfail = "PASS">
	<cfelse>
		<cfset stTest.passfail = "FAIL">
	</cfif>
	<cfset arrayAppend(arTestData, stTest)>
</cfloop>


<table>
	<tr valign="top">
		<th>Test #)</th>
		<th>PASS or FAIL?</th>
		<th>Test Description</th>
		<th>Sorting Code</th>
		<th>Account Number</th>
		<th>Expected Result</th>
		<th>Actual Result</th>
		<th>Applied Exceptions</th>
		<th>Applied Checks</th>
	</tr>
<cfoutput>
<cfloop from="1" to="#numRows-1#" index="i">
	<tr valign="top">
		<td>#i#)</td>
		<td>#arTestData[i].passfail#</td>
		<td>#arTestData[i].description#</td>
		<td>#arTestData[i].sortcode#</td>
		<td>#arTestData[i].accountnumber#</td>
		<td>#arTestData[i].expectedResult#</td>
		<td>#arTestData[i].actualresult#-#arTestData[i].score# </td>
		<td>#arTestData[i].exceptionRules#</td>
		<td>#arTestData[i].checkTypes#</td>
	</tr>
	<cfif arTestData[i].passfail EQ "FAIL">
	<tr>
		<td colspan="9">
			<cfdump var="#arTestData[i]#">
		</td>
	</tr>
	</cfif>
</cfloop>
</cfoutput>	
</table>

