public with sharing class FundraisingActionController {
    @AuraEnabled
    public static List<Fundraising_Action__c> getFundraisingActionsByStatus(String status){
        try {
            return [SELECT Id, Name, Amount_Raised__c, Associated_Military_Request__r.Description__c, Associated_Military_Request__r.Category__c, Fundraising_Goal__c, Volunteer__r.Username FROM Fundraising_Action__c WHERE Status__c=:status];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}