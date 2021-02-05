/**
 * @description       : Test Service Utility
 * @author            : Udhaya
 * @group             : 
 * @last modified on  : 05-Feb-2021
 * @last modified by  : Udhaya
 * Modifications Log 
 * Ver   Date          Author                           Modification
 * 1.0   05-Feb-2021   Udhaya   						Initial Version
**/
@IsTest
public class TestService {
    /**
    * @description : Create bulk accounts
    * @author : Udhaya | 05-Feb-2021 
    * @param : Number of accounts to create
    **/
    public static List<Account> createAccounts(Integer numAccts){
        List<Account> accts = new List<Account>();
        for(Integer i=0; i< numAccts; i++){
            Account acc = new Account(Name = 'Test Acc' + i);
            accts.add(acc);
        }
        insert accts;
        return accts;
    }
    
    /**
    * @description : Create bulk contacts
    * @author : Udhaya | 05-Feb-2021 
    * @param : Number of contacts to create, Account Records
    **/
    public static List<Contact> createContacts(Integer numContacts , List<Account> accRecs){
        List<Contact> contactRecs = new List<Contact>();
        for(Account accrec : accRecs){
            for(Integer i=0; i< numContacts; i++){
                Contact con = new Contact(LastName = 'Test Last Name' + i , FirstName = 'Test Last Name' + i, Email = 'test' + i +'@test.com', AccountId = accrec.Id );
                contactRecs.add(con);
            } 
        }
        
        insert contactRecs;
        return contactRecs;
    }
    
    
}