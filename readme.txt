COLDFUSION UK BANK MODULUS CHECKER
----------------------------------

CONTENTS OF THIS FILE
---------------------

 * Introduction
 * How to use the Bank Modulus Checker
 * Configuration
 * How it works
 

INTRODUCTION
------------

This ColdFusion code is an implementation of the UK Bank Modulus Check algorithm as descibed in the document found here:
http://www.vocalink.com/en/Documents/Technical%20docs/Mod%20check/Validating%20account%20numbers%20v1.80.pdf
Modulus Checking is a procedure for applying a mathematical algorithm to a number 
(such as an account number, sort code, reference or credit/debit card number) to check that it is valid.

The Modulus Check algorithm relies on 2 data tables, the latest versions of which can be found on this page:
http://www.vocalink.com/en/paymentprocessing/sterling%20services/modcheck/pages/moduluschecking.aspx

The data tables are tab delimited flat files. You can use the flat file data component, or I have provided an example
database data component if you want to store the data in a SQL database.

You can sign up to get email notification of when these data tables change at http://www.vocalink.com


HOW TO USE THE BANK MODULUS CHECKER
-----------------------------------

1) Create / Instantiate an ModulusData component via the init() method. 
You can choose between the ModulusDataDB or the ModulusDataFile components, depending on where your data is stored. 

<cfset ModulusData = createObject('component', 'bankModulus.ModulusDataFile').init()>

1) Create / Instantiate an accountValidator component via the init() method, and pass your Modulus Data object to it:

<cfset validator = CreateObject("component", "#pathToComponent#.accountValidator").init(ModulusData=ModulusData) />

2) Call the validate() method on the accountValidator component, passing in the sortcode and account number.
It is assumed that the sortcode and account number are 6 and 8 character strings respectively, and that the
characters can only be numeric. ColdFusion is dynamically typed so you can use this format:

<cfset result = validator.validate(123456, 12345678) />

3) The validate method will return a ColdFusion struct (hash table) with these elements:

isAccountValid
exceptionRules
checkTypes
score
outof
qModulusRows
skipChecks

Most of these elements are useful only for debugging, the result you are looking for is isAccountValid, which will be a boolean.

CONFIGURATION
-------------

When initialising the ModulusDataFile component, the init() method takes 2 optional parameters

1) 	string modWeightFile; this is the name of the file containing the modulus weight data and exceptions. 
	Change this if you want the validator to use a different weight table file.
	default = "VALACDOS.txt"

2) 	string scSubTableFile; this is the name of the file containing the sort code substitution data. 
	Change this if you want the validator to use a different sort code substitution data file.
	default = "SCSUBTAB.txt"
	
When initialising the ModulusDataDB component, the init() method takes 1 optional parameters	
	
1) 	string dsn; the name of your datasource where you might optionally store the data tables

When initialising the account validator component, the init() method takes 2 parameters

1) 	(required) "any" ModulusData component - see above for details

2) 	string ruleProcessorPath - change this if you want to try a different ruleProcessor component of your own devise.

HOW IT WORKS
------------

When the ModulusDataFile component is initialised, it reads the modulus weight file and the sortcode substitution file 
and loads them into data structures in memory. 

The accountValidator init method creates a ruleProcessor component. 

The ruleProcessor has methods for performing the MOD10, MOD11 and DBLAL calculations on the sortcode and account number.

validate() method
	The validate method takes 2 parameters, sortcode and accountnumber. The method then carries out these steps:
	
	1) Query the sortcode in the weighting table, which returns;
		a) weighting data (14 digits) 
		b) rules to apply (MOD10 or MOD11 or DBLAL)
		c) any exceptions to apply
	NB more than one row may be returned. This indicates that more than one rule should be applied when validating the account.
	The rules need to be performed in the correct order.
	
	2) Check any initial exceptions. These may remove the need to perform a check, or use the sortcode substitution table to replace 
	the sortcode used for checking.
	
	3) For each rule that is found in the mod weight table for the sortcode, call the relevant ruleProcessor method, 
	passing in the sortcode, account number, weighting data, and exceptions.
	Each method returns either 0 or 1 depending on whether the account is valid or not.
	These values are added up to produce a score. The total score (e.g. 1/1 or 1/2 or 2/2) determines the validity of the account.
	NB in some cases if there are 2 rules for a sortcode, only 1 needs to validate.
		
	
ruleProcessor
	There are 3 algorithms that can be applied. 
	Each rule (MOD10/MOD11/DBLAL) carries out these steps:
	
	1) split the sortcode / account into it's constituent digits and converts to a hashtable
	2) converts the weighting data to a hash table
	3) set the keys for both the hash tables to u v w x y z a b c d e f g h
	2) multiply each sortcode-accountnumber digit with its 'corresponding' weighting data digit
	3) add up the results of all these multiplications
	4) take the sum and divide by a number (10 or 11) and if there is a remainder then the rule has failed.
	5) for each algorithm there are a bunch of exceptions which are detailed in the "Validating Account Numbers" pdf.
	
	




 
