@isTest
private class DonationControllerTest {

    @TestVisible
    private static Boolean forceException = false;

    @isTest
    static void testMakeDonationSuccess() {
        Test.startTest();
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        mock.setMockResponse(200, '{"client_secret": "mock_client_secret"}');
        Test.setMock(HttpCalloutMock.class, mock);

        String result = DonationController.makeDonation('fundraising123', 'Test Fundraising', 100.50, 'usd');

        System.assertEquals('mock_client_secret', result);
        Test.stopTest();
    }

    @isTest
    static void testMakeDonationFailure() {

        Test.startTest();

        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        mock.setMockResponse(400, '');
        Test.setMock(HttpCalloutMock.class, mock);

        try {
            DonationController.makeDonation('fundraising123', 'Test Fundraising', 5, 'uah');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error from Stripe: '), 'Bad Error');
        }    
        Test.stopTest();
    }

    @isTest
    static void testCancelDonationFailure() {

        Test.startTest();

        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        mock.setMockResponse(400, '');
        Test.setMock(HttpCalloutMock.class, mock);

        try {
            DonationController.cancelDonation('payment1');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Payment cancelation was unsuccessful'), 'Bad Error');
        }    
        Test.stopTest();
    }

    @isTest
    static void testCancelPaymentSuccess(){
        Test.startTest();
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        mock.setMockResponse(200, '{"status": "succeeded"}');
        Test.setMock(HttpCalloutMock.class, mock);

        String result = DonationController.cancelDonation('payment123');
        System.debug(result);
        System.assertEquals('Payment canceled successfully', result);
        Test.stopTest();
    }
}