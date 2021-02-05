Problem Statement:
When the name of the Account has a specific criteria use mailgun to send email.

Criteria Used: 
Account Name contains 'Home Loan', send 'Home Loan Welcome Email' to all the contacts of the Account.

Scenario:
	1. Sales team captures the Lead.
	2. Lead is qualified and is converted to Account, Contact, Opportunity.
	3. Account is identified as type 'Home Loan'. (Picklist field: Loan_Type__c , Values : Home Loan, Refinance).
	4. When Loan_Type__c in Account is updated as 'Home Loan', update the account name to - Name + ' Home Loan'.
	5. Home Loan welcome email is sent to all contacts of the Account.
	6. Success, Error during email sending process are captured as task in Account.
	7. In case of error, welcome email can be sent again using Send_HL_Welcome_Email__c field in Account.

Mailgun configurations:
	1. Created Account.
	2. Created 'Home Loan Welcome Email' template to be used in Email.
	3. Authorized recipients  emails to use sandbox subdomains.

Salesforce configurations:
	1. Account Object - Custom Field : Loan_Type__c (Values : Home Loan, Refinance)
	2. Account Object - Custom Field : Send_HL_Welcome_Email__c (Boolean). To trigger sending welcome email when the original process resulted in error.
	3. Account Page Layout.
	4. Process Builder : Append account Name with 'Home Loan' when Loan_Type__c i= 'Home Loan'.
	5. API_Configuration__mdt - End point config metadata, metadata records, pagelayout
	6. HomeLoan_Email_Configuration__mdt - Email config metadata, metadata records, pagelayout
	7. Trigger : AccountTrigger - After update context to send welcome email.
	8. Apex Class: HomeLoanAccountService - To handle sending welcome email process. Capture success as Task with status Completed in Account. Capture error as Task with status Not Started and assigned to account owner.
	9. Apex Class: SendWelcomeEmailQueueable - Callout class to mail gun.
	10. Apex Class: HomeLoanAccountServiceTest - Test class for HomeLoanAccountService.
	11. Apex Class: TestService - Test Service Utility.
	12. Apex Class: UTIL_Constants - Constant Utility class.
	13. Apex Class: MockHttpSuccessResponseMailGun.
	14. Permission set: WelcomeEmail_PermissionSet
