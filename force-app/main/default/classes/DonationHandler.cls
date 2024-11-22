public with sharing class DonationHandler {

    public static void createDonate(String donorFullName, String fundraisingId, Decimal amount){
        Donation__c newDonate = new Donation__c();
        newDonate.Donor_Name__c = donorFullName;
        newDonate.Associated_Fundraising_Action__c = fundraisingId;
        newDonate.Amount__c = amount;
        insert newDonate;
    }

}