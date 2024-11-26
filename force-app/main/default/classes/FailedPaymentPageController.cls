public with sharing class FailedPaymentPageController {
    public String transactionId { get; set; }
    public String amount { get; set; }
    public String paymentType { get; set; }
    public String failedPaymentDateTime { get; set; }
    public String currencySign { get; set; }
    public String fundraisingName { get; set; }
 
    public FailedPaymentPageController() {
        
     transactionId = ApexPages.currentPage().getParameters().get('transactionId');
     String amountParam = ApexPages.currentPage().getParameters().get('amount');
     amount = String.valueOf((Decimal.valueOf(amountParam)).setScale(2));

     String paymentTypeParam = ApexPages.currentPage().getParameters().get('paymentType');
     if (paymentTypeParam == 'card') {
         paymentType = '•••• •••• •••• 4242';
     }else {
         paymentType = paymentTypeParam;
     }

     failedPaymentDateTime = ApexPages.currentPage().getParameters().get('date');
     currencySign = ApexPages.currentPage().getParameters().get('currency');
     fundraisingName = ApexPages.currentPage().getParameters().get('fundraisingName');

    }
}