@IsTest
private class RequestApprovalControllerTest {
    @TestSetup
    static void setupTestData() {
        // Create a test user to act as the Owner
        User testUser = new User(
            FirstName = 'John123',
            LastName = 'Doe',
            Email = 'johndoe@example144.com',
            Username = 'johndoe@exampl53e.com.test',
            Alias = 'jdoe',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Insert a test Request_Approval__c record
        Request_Approval__c approvalRequest = new Request_Approval__c(
            Requested_Amount__c = 12345,
            Category__c = 'Supplies',
            Visibility__c = 'Visible to Volunteers',
            OwnerId = testUser.Id
        );
        insert approvalRequest;
    }

    @IsTest
    static void testGetPendingApprovals() {
        // Call the getPendingApprovals method
        Test.startTest();
        List<Request_Approval__c> pendingApprovals = RequestApprovalController.getPendingApprovals();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, pendingApprovals.size(), 'There should be at least one pending approval.');    }

    @IsTest
    static void testProcessApproval_Approve() {
        // Get the test Request_Approval__c record
        Request_Approval__c requestApproval = [SELECT Id FROM Request_Approval__c LIMIT 1];

        // Call the processApproval method to approve the request
        Test.startTest();
        RequestApprovalController.processApproval(requestApproval.Id, true);
        Test.stopTest();

        // Assertions
        // Verify that the Request_Approval__c record was deleted
        Integer approvalCount = [SELECT COUNT() FROM Request_Approval__c WHERE Id = :requestApproval.Id];
        System.assertEquals(0, approvalCount, 'The approval request record should be deleted.');

        // Verify that the Military_Request__c record was created
        Military_Request__c createdRequest = [SELECT Id, Requested_Amount__c, Category__c, Visibility__c FROM Military_Request__c LIMIT 1];
        System.assertNotEquals(null, createdRequest, 'A Military_Request__c record should have been created.');
        System.assertEquals(12345, createdRequest.Requested_Amount__c, 'The Requested Amount should match.');
        System.assertEquals('Supplies', createdRequest.Category__c, 'The Category should match.');
        System.assertEquals('Visible to Volunteers', createdRequest.Visibility__c, 'The Visibility should match.');
    }

    @IsTest
    static void testProcessApproval_Reject() {
        // Get the test Request_Approval__c record
        Request_Approval__c requestApproval = [SELECT Id FROM Request_Approval__c LIMIT 1];

        // Call the processApproval method to reject the request
        Test.startTest();
        RequestApprovalController.processApproval(requestApproval.Id, false);
        Test.stopTest();

        // Assertions
        // Verify that the Request_Approval__c record was deleted
        Integer approvalCount = [SELECT COUNT() FROM Request_Approval__c WHERE Id = :requestApproval.Id];
        System.assertEquals(0, approvalCount, 'The approval request record should be deleted.');

        // Verify that no Military_Request__c record was created
        Integer militaryRequestCount = [SELECT COUNT() FROM Military_Request__c];
        System.assertEquals(0, militaryRequestCount, 'No Military_Request__c record should have been created.');
    }

    @IsTest
    static void testSendApprovalEmail() {
        // Create a test Military_Request__c record
        Military_Request__c testRequest = new Military_Request__c(
            Requested_Amount__c = 10000,
            Category__c = 'Supplies',
            Visibility__c = 'Visible to Volunteers'
        );
        insert testRequest;
        // Call the sendApprovalEmail method
        Test.startTest();
        Integer emailInvocationsBefore = Limits.getEmailInvocations();
        RequestApprovalController.sendApprovalEmail('johndoe@example.com', testRequest.Id);
        Integer emailInvocationsAfter = Limits.getEmailInvocations();
        Test.stopTest();

        // Assertions
        // Verify that one email was sent
        System.assertEquals(emailInvocationsBefore + 1, emailInvocationsAfter, 'An email should have been sent.');
    }
}