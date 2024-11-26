public with sharing class RequestApprovalController {
    @AuraEnabled(cacheable=true)
    public static List<Request_Approval__c> getPendingApprovals() {
        return [SELECT Id, Name, Requested_Amount__c, Category__c, Visibility__c FROM Request_Approval__c];
    }

    @AuraEnabled
    public static void processApproval(Id recordId, Boolean isApproved) {
        Request_Approval__c requestApproval = [
            SELECT Requested_Amount__c, Category__c, Visibility__c, Owner.Email 
            FROM Request_Approval__c 
            WHERE Id = :recordId
        ];

        if (requestApproval != null) {
            if (isApproved) {
       
                Military_Request__c newRequest = new Military_Request__c(
                    Requested_Amount__c = requestApproval.Requested_Amount__c,
                    Category__c = requestApproval.Category__c,
                    Visibility__c = requestApproval.Visibility__c
                );
                insert newRequest;
                If(String.isNotBlank(requestApproval.Owner.Email)) {
                    sendApprovalEmail(requestApproval.Owner.Email, newRequest.Id);
                }
            }

           
            delete requestApproval;
        } else {
            throw new AuraHandledException('The approval request record no longer exists.');
        }
    }
    public static void sendApprovalEmail(String recipientEmail, Id requestId) {
        Military_Request__c request = [
            SELECT Id, Name, Owner.Name 
            FROM Military_Request__c 
            WHERE Id = :requestId
            LIMIT 1
        ];
        String userName = request.Owner.Name;
       
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { recipientEmail });
        email.setSubject('Your Request Has Been Submitted');
        email.setPlainTextBody(
            'Dear ' + userName +',\n\n' +
            'Your request has been successfully submitted. Your request ID is: ' + requestId + '.\n\n' +
            'Thank you,\n' +
            'The Approval Team'
        );

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}
