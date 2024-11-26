public with sharing class DonationHandler {

    public static void createDonate(String donorFullName, String fundraisingId, Decimal amount){
        Donation__c newDonate = new Donation__c();
        newDonate.Donor_Name__c = donorFullName;
        newDonate.Associated_Fundraising_Action__c = fundraisingId;
        newDonate.Amount__c = amount;
        insert newDonate;

        Fundraising_Action__c fa = [SELECT Amount_Raised__c, Associated_Military_Request__c, Fundraising_Goal__c, Status__c FROM Fundraising_Action__c WHERE Id=:fundraisingId LIMIT 1];
        Decimal faAmountReached = fa.Amount_Raised__c + amount;
        if (faAmountReached >= fa.Fundraising_Goal__c) {
            fa.Status__c = 'Completed';
            Military_Request__c mr = [SELECT Status__c FROM Military_Request__c WHERE Id =: fa.Associated_Military_Request__c LIMIT 1];
            mr.Status__c = 'Fundraising Complete';
            update mr;
        }
        fa.Amount_Raised__c = faAmountReached;

        update fa;
    }

}