@isTest
public class FailedPaymentPageControllerTest {
    
    @isTest
    static void testFailedPaymentPageController() {
        
        String transactionId = 'txn_123456';
        String amount = '150.50';
        String paymentType = 'card';
        String failedPaymentDateTime = '2024-11-25T12:30:00Z';
        String cur = 'USD';
        String fundraisingName = 'Fundraising Campaign A';
        
        Test.setCurrentPage(Page.PaymentFailedPage); 
        ApexPages.currentPage().getParameters().put('transactionId', transactionId);
        ApexPages.currentPage().getParameters().put('amount', amount);
        ApexPages.currentPage().getParameters().put('paymentType', paymentType);
        ApexPages.currentPage().getParameters().put('date', failedPaymentDateTime);
        ApexPages.currentPage().getParameters().put('currency', cur);
        ApexPages.currentPage().getParameters().put('fundraisingName', fundraisingName);
        
        FailedPaymentPageController controller = new FailedPaymentPageController();
        
        System.assertEquals(transactionId, controller.transactionId, 'Transaction ID should match');
        System.assertEquals('150.50', controller.amount, 'Amount should match and be rounded to 2 decimal places');
        System.assertEquals('•••• •••• •••• 4242', controller.paymentType, 'Payment type should be masked for cards');
        System.assertEquals(failedPaymentDateTime, controller.failedPaymentDateTime, 'Failed payment date time should match');
        System.assertEquals(cur, controller.currencySign, 'Currency should match');
        System.assertEquals(fundraisingName, controller.fundraisingName, 'Fundraising name should match');
    }
    
    @isTest
    static void testFailedPaymentPageControllerWithDifferentPaymentType() {
        
        String transactionId = 'txn_987654';
        String amount = '99.99';
        String paymentType = 'paypal';
        String failedPaymentDateTime = '2024-11-25T14:45:00Z';
        String cur = 'EUR';
        String fundraisingName = 'Fundraising Campaign B';
        
        Test.setCurrentPage(Page.PaymentFailedPage);
        ApexPages.currentPage().getParameters().put('transactionId', transactionId);
        ApexPages.currentPage().getParameters().put('amount', amount);
        ApexPages.currentPage().getParameters().put('paymentType', paymentType);
        ApexPages.currentPage().getParameters().put('date', failedPaymentDateTime);
        ApexPages.currentPage().getParameters().put('currency', cur);
        ApexPages.currentPage().getParameters().put('fundraisingName', fundraisingName);
        
        FailedPaymentPageController controller = new FailedPaymentPageController();
        
        System.assertEquals(transactionId, controller.transactionId, 'Transaction ID should match');
        System.assertEquals('99.99', controller.amount, 'Amount should match and be rounded to 2 decimal places');
        System.assertEquals(paymentType, controller.paymentType, 'Payment type should match');
        System.assertEquals(failedPaymentDateTime, controller.failedPaymentDateTime, 'Failed payment date time should match');
        System.assertEquals(cur, controller.currencySign, 'Currency should match');
        System.assertEquals(fundraisingName, controller.fundraisingName, 'Fundraising name should match');
    }
}