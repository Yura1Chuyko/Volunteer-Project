@isTest
public with sharing class FundraisingActionControllerTest {

    @isTest
    static void testGetFundraisingActionsByStatus() {
        
        User volunteerUser = new User(

            Username = 'testuser@domain.com',
            LastName='testuser',
            Email = 'testuser@domain.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            Alias = 'testuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CommunityNickname = 'testvolunteer'
        );
        insert volunteerUser;
        
        Military_Request__c mr = new Military_Request__c();
        mr.Requested_Amount__c = 20000;
        mr.Status__c = 'New';
        mr.Visibility__c = 'Visible to Volunteers';

        insert mr;
        
        Fundraising_Action__c fundraisingAction = new Fundraising_Action__c(
            Amount_Raised__c = 5000.00,
            Fundraising_Goal__c = 10000.00,
            Status__c = 'In Progress',
            Associated_Military_Request__c = mr.Id,
            Volunteer__c = volunteerUser.Id
        );
        insert fundraisingAction;
        
        Test.startTest();
        
        List<Fundraising_Action__c> actions = FundraisingActionController.getFundraisingActionsByStatus('In Progress');
        
        Test.stopTest();
        
        System.assertNotEquals(0, actions.size(), 'There should be at least one fundraising action returned.');
        
        Fundraising_Action__c returnedAction = actions[0];
        System.assertEquals(5000.00, returnedAction.Amount_Raised__c, 'Amount raised should match.');
        System.assertEquals(10000.00, returnedAction.Fundraising_Goal__c, 'Fundraising goal should match.');
        System.assertEquals('testuser', returnedAction.Volunteer__r.LastName, 'Volunteer last name should match.');
    }
    
    @isTest
    static void testGetFundraisingActionsByStatus_NoResults() {
        
        Military_Request__c mr = new Military_Request__c();
        mr.Requested_Amount__c = 20000;
        mr.Status__c = 'New';
        mr.Visibility__c = 'Visible to Volunteers';

        insert mr;

        Fundraising_Action__c fundraisingAction = new Fundraising_Action__c(
            Amount_Raised__c = 5000.00,
            Fundraising_Goal__c = 10000.00,
            Associated_Military_Request__c = mr.Id,
            Status__c = 'In Progress'
        );
        insert fundraisingAction;
        
        Test.startTest();
        
        List<Fundraising_Action__c> actions = FundraisingActionController.getFundraisingActionsByStatus('Completed');
        
        Test.stopTest();
        
        System.assertEquals(0, actions.size(), 'No fundraising actions should be returned for the "Completed" status.');
    }
    
    @isTest
    static void testGetFundraisingActionsByStatus_Exception() {
        try {
            Test.startTest();
            List<Fundraising_Action__c> actions = FundraisingActionController.getFundraisingActionsByStatus('NonExistingStatus');
            Test.stopTest();
            System.assertEquals(0, actions.size(), 'The query should return no records for a non-existing status.');
        } catch (AuraHandledException ex) {
            System.assert(ex.getMessage().contains('No records found'), 'The exception message should indicate no records found');
        }
    }

}