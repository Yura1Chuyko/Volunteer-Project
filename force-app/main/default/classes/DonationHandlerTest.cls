@isTest
public with sharing class DonationHandlerTest {
    @isTest
    static void testCreateDonate() {

        Military_Request__c mr = new Military_Request__c();
        mr.Requested_Amount__c = 20000;
        mr.Status__c = 'New';
        mr.Visibility__c = 'Visible to Volunteers';

        insert mr;

        Fundraising_Action__c fundraisingAction = new Fundraising_Action__c(
            Amount_Raised__c = 500.00,
            Fundraising_Goal__c = 1000.00,
            Associated_Military_Request__c = mr.Id,
            Status__c = 'In Progress'
        );
        insert fundraisingAction;

        String donorFullName = 'John Doe';
        Decimal donationAmount = 200.00;
        Test.startTest();
        DonationHandler.createDonate(donorFullName, fundraisingAction.Id, donationAmount);
        Test.stopTest();

        Donation__c newDonation = [SELECT Donor_Name__c, Associated_Fundraising_Action__c, Amount__c FROM Donation__c WHERE Donor_Name__c = :donorFullName LIMIT 1];
        System.assertEquals(donorFullName, newDonation.Donor_Name__c, 'Donor name should match');
        System.assertEquals(fundraisingAction.Id, newDonation.Associated_Fundraising_Action__c, 'Fundraising Action ID should match');
        System.assertEquals(donationAmount, newDonation.Amount__c, 'Donation amount should match');

        Fundraising_Action__c updatedFundraisingAction = [SELECT Amount_Raised__c, Status__c, Fundraising_Goal__c FROM Fundraising_Action__c WHERE Id = :fundraisingAction.Id LIMIT 1];
        System.assertEquals(fundraisingAction.Amount_Raised__c + donationAmount, updatedFundraisingAction.Amount_Raised__c, 'Amount Raised should be updated correctly');
        
        if (updatedFundraisingAction.Amount_Raised__c >= updatedFundraisingAction.Fundraising_Goal__c) {
            System.assertEquals('Completed', updatedFundraisingAction.Status__c, 'Fundraising action status should be Completed');
        } else {
            System.assertEquals('In Progress', updatedFundraisingAction.Status__c, 'Fundraising action status should remain Ongoing');
        }
    }
}