/**
 * @description       : Callout class to send homeloan welcome email
 * @author            : Udhaya
 * @TestClass		  : HomeLoanAccountServiceTest
 * @group             : 
 * @last modified on  : 05-Feb-2021
 * @last modified by  : Udhaya
 * Modifications Log 
 * Ver   Date          Author                           Modification
 * 1.0   04-Feb-2021   Udhaya   						Initial Version
**/

public class SendWelcomeEmailQueueable implements Queueable, Database.AllowsCallouts{
    
    public Account accountWithContacts = new Account();
    public API_Configuration__mdt apiConfigRec = new API_Configuration__mdt();
    public HomeLoan_Email_Configuration__mdt emailConfigRec = new HomeLoan_Email_Configuration__mdt();    
    public static List<String> contactEmails = new List<String>();
    public static List<String> emailIds = new List<String>();
    
    /**
    * @description : Constructor method for queueable class.
    * @author : Udhaya | 04-Feb-2021 
    * @param : Account Record, End Point configuration metadata, Email configuration metadata
    **/
    public sendWelcomeEmailQueueable(Account accRecord,API_Configuration__mdt apiConfig, HomeLoan_Email_Configuration__mdt emailconfig ){
        this.accountWithContacts = accRecord;
        this.apiConfigRec = apiConfig;
        this.emailConfigRec = emailConfig;
    }
    
    /**
    * @description : 1. Send welcome email if contacts present for account and contants has Email.
    * 					OR
    * 				 2. Create Task to capture error when contact not present for account, when contant email is not available.
    * @author : Udhaya | 04-Feb-2021 
    * @param :
    **/
    public void execute(QueueableContext context) {
        try{
            if(accountWithContacts.contacts.size() > 0){
                for(Contact conRec : accountWithContacts.contacts){
                    if(String.isNotBlank(conRec.Email)){
                        emailIds.add(conRec.Email); 
                    }                
                }
                if(emailIds.size() > 0){
                    sendWelcomeEmail();
                }else{
                    HomeLoanAccountService.createTask(UTIL_Constants.ERROR_EMAILIDUNAVAILABLE,accountWithContacts);
                }                       
            }else{
                HomeLoanAccountService.createTask(UTIL_Constants.ERROR_CONTACTUNAVAILABLE,accountWithContacts);
            }
            if(accountWithContacts.Send_HL_Welcome_Email__c){
                accountWithContacts.Send_HL_Welcome_Email__c = FALSE;
                update accountWithContacts;
            } 
        }catch(Exception exp){
            HomeLoanAccountService.createTask(UTIL_Constants.ERROR_CLASSEXCEPTION + exp.getMessage() + ' , ' + exp.getStackTraceString(),accountWithContacts);            
        }
    }
    
    /**
    * @description : 1. Callout method to Mailgun to send email.
    * 				 2. Mailgun Template is used to send email.
    * 				 3. API Configuration, Email configuration are configured in metadata.
    * @author 	: Udhaya | 04-Feb-2021 
    * @param : 
    **/
    public void sendWelcomeEmail(){
        String reqBody = 'from=' + emailConfigRec.From_Email_Address__c + ' ' +
            '&to=' + String.join(emailIds, ',')  + ' &subject=' + emailConfigRec.Email_subject__c + ' &template=' + emailConfigRec.Mailgun_Email_Template_API_Name__c;
        
        Blob headerValue = Blob.valueOf('api'+ ':' + apiConfigRec.API_Key__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Host', apiConfigRec.Host_Name__c);
        req.setHeader('Content-Length', string.valueOf(reqBody.length()));
        req.setEndPoint(apiConfigRec.End_Point_URL__c);        
        req.setBody(reqBody);
        HttpResponse res = new Http().send(req);
        if( res.getStatusCode() == 200 ){   
            HomeLoanAccountService.createTask('',accountWithContacts);
        }else{
            HomeLoanAccountService.createTask(UTIL_Constants.ERROR_CLASSEXCEPTION + res.getStatusCode() + ' - ' + res.getBody(),accountWithContacts);
        }          
    }
}