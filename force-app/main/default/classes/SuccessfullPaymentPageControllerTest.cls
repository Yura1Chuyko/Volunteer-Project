@isTest
public class SuccessfullPaymentPageControllerTest {
    
    @isTest
    static void testSuccessfullPaymentPageController() {
        
        String transactionId = 'txn_123456';
        String amount = '150.50';
        String paymentType = 'card';
        String paymentDateTime = '2024-11-25T12:30:00Z';
        String cur = 'USD';
        String donorEmail = 'donor@example.com';
        String fundraisingName = 'Fundraising Campaign A';
        
        Test.setCurrentPage(Page.PaymentSuccessful);
        ApexPages.currentPage().getParameters().put('transactionId', transactionId);
        ApexPages.currentPage().getParameters().put('amount', amount);
        ApexPages.currentPage().getParameters().put('paymentType', paymentType);
        ApexPages.currentPage().getParameters().put('date', paymentDateTime);
        ApexPages.currentPage().getParameters().put('currency', cur);
        ApexPages.currentPage().getParameters().put('donorEmail', donorEmail);
        ApexPages.currentPage().getParameters().put('fundraisingName', fundraisingName);
        
        SuccessfullPaymentPageController controller = new SuccessfullPaymentPageController();
        
        System.assertEquals(transactionId, controller.transactionId, 'Transaction ID should match');
        System.assertEquals('150.50', controller.amount, 'Amount should match and be rounded to 2 decimal places');
        System.assertEquals('•••• •••• •••• 4242', controller.paymentType, 'Payment type should be masked for cards');
        System.assertEquals(paymentDateTime, controller.paymentDateTime, 'Payment date time should match');
        System.assertEquals(cur, controller.currencySign, 'Currency should match');
        System.assertEquals(donorEmail, controller.donorEmail, 'Donor email should match');
        System.assertEquals(fundraisingName, controller.fundraisingName, 'Fundraising name should match');
    }
    
    @isTest
    static void testSendReceiptToEmail() {
        
        String transactionId = 'txn_987654';
        String donorEmail = 'donor@example.com';
        String fundraisingName = 'Fundraising Campaign B';
        String currencySign = 'USD';
        String amount = '99.99';
        String paymentDateTime = '2024-11-25T14:45:00Z';
        String paymentType = 'paypal';
        
        Test.startTest();
        String result = SuccessfullPaymentPageController.sendReceiptToEmail(transactionId, donorEmail, fundraisingName, 
                                                                           currencySign, amount, paymentDateTime, paymentType);
        Test.stopTest();
        
        System.assertEquals('Email sent successfully!', result, 'The email should be sent successfully');

    }
    
    @isTest
    static void testSendReceiptToEmailException() {
        
        String transactionId = 'txn_987654';
        String donorEmail = 'invalid-email';  
        String fundraisingName = 'Fundraising Campaign C';
        String currencySign = 'USD';
        String amount = '50.00';
        String paymentDateTime = '2024-11-26T10:00:00Z';
        String paymentType = 'card';
        
        Test.startTest();
        String result = SuccessfullPaymentPageController.sendReceiptToEmail(transactionId, donorEmail, fundraisingName, 
                                                                           currencySign, amount, paymentDateTime, paymentType);
        Test.stopTest();
        
        System.assert(result.contains('Failed to send email'), 'The email sending should fail due to an invalid email address');
    }
}