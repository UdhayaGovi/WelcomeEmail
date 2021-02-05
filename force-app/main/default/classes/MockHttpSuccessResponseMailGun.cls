/**
 * @description       : Mock response for mailgun http callout. Class Name : sendWelcomeEmailQueueable
 * @author            : Udhaya
 * @group             : 
 * @last modified on  : 05-Feb-2021
 * @last modified by  : Udhaya
 * Modifications Log 
 * Ver   Date          Author                           Modification
 * 1.0   05-Feb-2021   Udhaya   						Initial Version
**/
@isTest
global class MockHttpSuccessResponseMailGun implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create test response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Email":"success"}');
        res.setStatusCode(200);
        return res;
    }
}