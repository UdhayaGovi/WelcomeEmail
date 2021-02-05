/**
 * @description       : Trigger for Account object
 * @author            : Udhaya
 * @group             : 
 * @last modified on  : 04-Feb-2021
 * @last modified by  : Udhaya
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   04-Feb-2021   Udhaya   						Initial Version
**/
trigger AccountTrigger on Account (after insert, after update) {
    if (Trigger.IsAfter)
    {	
        if (Trigger.IsUpdate){
           //Send homeloan welcome email to Account contacts
           HomeLoanAccountService.sendWelcomeEmail(Trigger.newMap , Trigger.oldMap);
        }
    }
}