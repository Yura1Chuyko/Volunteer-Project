@isTest
public class StripePaymentControllerTest {
    
    @IsTest
    static void testHandleRedirectSuccess() {
        User volunteerUser = new User(
            Username = 'testuser@domain.com',
            LastName='testuser',
            Email = 'testuser@domain.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id, // Ensure a valid ProfileId is set
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
    StripePaymentMock mock = new StripePaymentMock();
    mock.setFundraisingId(fundraisingAction.Id);
        Test.setMock(HttpCalloutMock.class, mock);

        ApexPages.currentPage().getParameters().put('payment_intent', 'pi_12345');

        Test.startTest();
        PageReference result = new StripePaymentController().handleRedirect();
        Test.stopTest();

        System.assert(result.getUrl().contains('/apex/PaymentSuccessful'), 'The URL should redirect to the success page.');
        System.assert(result.getUrl().contains('transactionId=txn_123'), 'The transaction ID should match the mock response.');
    }

    @IsTest
    static void testHandleRedirectFailure() {
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        mock.setMockResponse(200, '{"data": [{"id": "txn_123", "status": "failed", "amount": 5000, "created": 1693276800, "currency": "uah", "metadata": {"donorEmail": "test@example.com", "donorFullName": "John Doe", "fundraisingId": "01IWV000000Ra93", "fundraisingName": "Charity Event"}, "payment_method_details": {"type": "card"}}]}');
        Test.setMock(HttpCalloutMock.class, mock);

        ApexPages.currentPage().getParameters().put('payment_intent', 'pi_12345');

        Test.startTest();
        PageReference result = new StripePaymentController().handleRedirect();
        Test.stopTest();

        System.assert(result.getUrl().contains('/apex/PaymentFailedPage'), 'The URL should redirect to the failure page.');
        System.assert(result.getUrl().contains('transactionId=txn_123'), 'The transaction ID should match the mock response.');
    }

    @isTest
    static void testGetCurrencySignByIsoCode() {
        StripePaymentController controller = new StripePaymentController();
        
        String usdSign = controller.getCurrencySignByIsoCode('usd');
        System.assertEquals('$', usdSign);
        
        String uahSign = controller.getCurrencySignByIsoCode('uah');
        System.assertEquals('₴', uahSign);
        
        String eurSign = controller.getCurrencySignByIsoCode('eur');
        System.assertEquals('€', eurSign);
        
        String gbpSign = controller.getCurrencySignByIsoCode('gbp');
        System.assertEquals('£', gbpSign);
        
        String unknownSign = controller.getCurrencySignByIsoCode('inr');
        System.assertEquals('', unknownSign); 
    }
   
}