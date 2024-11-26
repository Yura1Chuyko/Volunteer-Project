public with sharing class FundraisingActionController {
    @AuraEnabled
    public static List<Fundraising_Action__c> getFundraisingActionsByStatus(String status){
            return [SELECT Id, Name, 
                    Amount_Raised__c, 
                    Associated_Military_Request__r.Description__c, 
                    Associated_Military_Request__r.Category__c, 
                    Fundraising_Goal__c, 
                    Volunteer__r.FirstName,
                    Volunteer__r.LastName
                    FROM Fundraising_Action__c 
                    WHERE Status__c=:status];
        
    }
}