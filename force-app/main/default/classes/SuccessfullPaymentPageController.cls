public with sharing class SuccessfullPaymentPageController {
    public String transactionId { get; set; }
    public Decimal amount { get; set; }
    public String paymentType { get; set; }
    public String paymentDateTime { get; set; }
    public String currencySign { get; set; }
 
    public SuccessfullPaymentPageController() {
        
     transactionId = ApexPages.currentPage().getParameters().get('transactionId');
     String amountParam = ApexPages.currentPage().getParameters().get('amount');
     amount = Decimal.valueOf(Integer.valueOf(amountParam) / 100);
     String paymentTypeParam = ApexPages.currentPage().getParameters().get('paymentType');
     if (paymentTypeParam == 'card') {
         paymentType = '•••• •••• •••• 4242';
     }else {
         paymentType = paymentTypeParam;
     }
     paymentDateTime = ApexPages.currentPage().getParameters().get('date');
     currencySign = ApexPages.currentPage().getParameters().get('currency');

    }
 }