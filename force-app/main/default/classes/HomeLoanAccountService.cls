/**
 * @description       : Service class for Home loan account
 * @author            : Udhaya
 * @TestClass		  : HomeLoanAccountServiceTest
 * @group             : 
 * @last modified on  : 05-Feb-2021
 * @last modified by  : Udhaya
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   04-Feb-2021   Udhaya   						Initial Version
 * 2.0   05-Feb-2021   Udhaya   						Task Method 
**/
public class HomeLoanAccountService {
    /**
    * @description : 1. Send homeloan welcome email if name contains 'Home Loan'
    * 					OR
    * 				 2. Send homeloan welcome email when manually trigged by field Send_HL_Welcome_Email__c. 
    * 					Manual option is added to resend email when there is an error sending first welcome email.
    * @author : Udhaya | 04-Feb-2021 
    * @param : Trigger.newMap, Trigger.oldMap
    **/
    public static void sendWelcomeEmail(Map<Id, Account> mapAccounts , Map<Id, Account> mapOldAccounts){
        Map<Id, Account> newMapAccounts    = (Map<Id, Account>)mapAccounts;
        Map<Id, Account> oldMapAccounts    = (Map<Id, Account>)mapOldAccounts;
        API_Configuration__mdt apiConfigRec = getAPIConfig();
        HomeLoan_Email_Configuration__mdt emailConfigRec = getEmailConfig();
        Map<ID, Account> accsWithContacts  = new Map<ID, Account>([SELECT Id, Name , OwnerId, Send_HL_Welcome_Email__c, (SELECT Id, Email FROM Contacts) 
                                                                   FROM Account
                                                                   WHERE Id IN :newMapAccounts.keySet()]);
            for(Id newAccId : newMapAccounts.keySet()){           
                if((newMapAccounts.get(newAccId).Name != oldMapAccounts.get(newAccId).Name && (newMapAccounts.get(newAccId).Name).contains(UTIL_Constants.LOAN_TYPE)) || 
                   (newMapAccounts.get(newAccId).Send_HL_Welcome_Email__c != oldMapAccounts.get(newAccId).Send_HL_Welcome_Email__c && newMapAccounts.get(newAccId).Send_HL_Welcome_Email__c == TRUE)){
                       System.enqueuejob(new sendWelcomeEmailQueueable(accsWithContacts.get(newAccId), apiConfigRec, emailConfigRec));    
                   }
            }
    } 
    
    /**
    * @description : 1. Create task when welcome email is sent successfully. Status is 'Completed'.
    * 					OR
    * 				 2. Create task when there is an error sending email and assign it to account owner to rectify 
    * 					and resend the welcome email by selecting Send_HL_Welcome_Email__c in Account.
    * @author : Udhaya | 05-Feb-2021 
    * @param : Error message, Account Record
    **/
    public static void createTask(String errorMessage, Account accRec){
        Task taskRec     	= new Task();
        taskRec.Priority 	= 'Normal';
        taskRec.WhatId 		= accRec.ID;
        taskRec.OwnerId 	= accRec.OwnerId;                
        if(String.isBlank(errorMessage)){
            taskRec.Subject = UTIL_Constants.SUCCESS_WELCOMEEMAIL;
            taskRec.Status 	= 'Completed';
        }else{
            taskRec.Subject = UTIL_Constants.ERROR_WELCOMEEMAIL;
            taskRec.Status 	= 'Not Started';
            taskRec.Description = errorMessage;
        }
        insert taskRec;
    }
    
    /**
    * @description : Get mailgun Endpoint url, API Key from metadata				
    * @author : Udhaya | 04-Feb-2021 
    * @param : 
    **/
    public static API_Configuration__mdt getAPIConfig() {
        List<API_Configuration__mdt> listApiConfig =  [SELECT Id,End_Point_URL__c,API_Key__c,Host_Name__c FROM API_Configuration__mdt WHERE DeveloperName = :UTIL_Constants.MDT_CONFIG_MAILGUNAPI LIMIT 1];        
        if (listApiConfig.size() == 0){
            return null;
        } else {
            return listApiConfig[0];
        }
    }
    
    /**
    * @description : Get Mailgun Email Template, Subject, From email address  from metadata				
    * @author : Udhaya | 04-Feb-2021 
    * @param : 
    **/
    public static HomeLoan_Email_Configuration__mdt getEmailConfig() {
        List<HomeLoan_Email_Configuration__mdt> listEmailConfig = [SELECT Id,Mailgun_Email_Template_API_Name__c,From_Email_Address__c ,Email_subject__c  FROM HomeLoan_Email_Configuration__mdt WHERE DeveloperName = :UTIL_Constants.MDT_CONFIG_WELCOMEEMAIL LIMIT 1];
        if (listEmailConfig.size() == 0){
            return null;
        } else {
            return listEmailConfig[0];
        }
    }
    
}