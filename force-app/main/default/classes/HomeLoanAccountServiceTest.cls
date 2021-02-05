/**
 * @description       : Test class for HomeLoanAccountService
 * @author            : Udhaya
 * @group             : 
 * @last modified on  : 05-Feb-2021
 * @last modified by  : Udhaya
 * Modifications Log 
 * Ver   Date          Author                           Modification
 * 1.0   05-Feb-2021   Udhaya   						Initial Version
**/
@IsTest
public class HomeLoanAccountServiceTest {
   	/**
    * @description : Testsetup method
    * @author : Udhaya | 05-Feb-2021 
    * @param : 
    **/
    @testsetup
    public static void testDataSetup(){
        List<Account> accRecs = TestService.createAccounts(5);
        
    }
    
    /**
    * @description : To test account with Name contains 'Home Loan'
    * @author : Udhaya | 05-Feb-2021 
    * @param : 
    **/
    public static testmethod void updateAccountLoanTypeTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccessResponseMailGun());
        List<Account> accs = [SELECT Id, Name 
                              FROM Account 
                              WHERE Name LIKE 'Test%'];
        List<Contact> contRect= TestService.createContacts(2,accs);
        List<Account> accsToUpdate = new List<Account>();
        for(Account acc : accs){
            acc.Name = acc.Name + ' ' + UTIL_Constants.LOAN_TYPE;
            accsToUpdate.add(acc);
        }
        Test.startTest();
        update accsToUpdate;
        Test.stopTest();
        List<Task> taskRecs = [SELECT Id, Subject, Description 
                               FROM Task
                               WHERE WhatId = :accs[0].Id];
        
        System.assertEquals(taskRecs[0].Subject, UTIL_Constants.SUCCESS_WELCOMEEMAIL);
    }
    
    /**
    * @description : To test account with Name contains 'Home Loan'
    * 				 Account with no contacts and assert error Task. 
    * @author : Udhaya | 05-Feb-2021 
    * @param : 
    **/
    public static testmethod void accountWithNoContactTest(){
        List<Account> accs = [SELECT Id, Name 
                              FROM Account 
                              WHERE Name LIKE 'Test%'];
        List<Account> accsToUpdate = new List<Account>();
        for(Account acc : accs){
            acc.Name = acc.Name + ' ' + UTIL_Constants.LOAN_TYPE;
            accsToUpdate.add(acc);
        }
        Test.startTest();
        update accsToUpdate;
        Test.stopTest();
        List<Task> taskRecs = [SELECT Id, Subject, Description 
                               FROM Task
                               WHERE WhatId = :accs[0].Id];
        
        System.assertEquals(taskRecs[0].Subject, UTIL_Constants.ERROR_WELCOMEEMAIL);
    }
    
    /**
    * @description : To test manual welcome email when the original process resulted in error. 
    * @author : Udhaya | 05-Feb-2021 
    * @param : 
    **/
    public static testmethod void sendWelcomeEmailManualTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccessResponseMailGun());
        List<Account> accs = [SELECT Id, Name, Send_HL_Welcome_Email__c 
                              FROM Account 
                              WHERE Name LIKE 'Test%'];
        List<Contact> contRect= TestService.createContacts(2,accs);
        List<Account> accsToUpdate = new List<Account>();
        for(Account acc : accs){
            acc.Name = acc.Name + ' ' + UTIL_Constants.LOAN_TYPE;
            acc.Send_HL_Welcome_Email__c = TRUE;
            accsToUpdate.add(acc);
        }
        Test.startTest();
        update accsToUpdate;
        Test.stopTest();
        List<Task> taskRecs = [SELECT Id, Subject, Description 
                               FROM Task
                               WHERE WhatId = :accs[0].Id];
        
        System.assertEquals(taskRecs[0].Subject, UTIL_Constants.SUCCESS_WELCOMEEMAIL);
    }

}