public with sharing class SuccessfullPaymentPageController {

    public String transactionId { get; set; }
    public String amount { get; set; }
    public String paymentType { get; set; }
    public String paymentDateTime { get; set; }
    public String currencySign { get; set; }
    public String donorEmail { get; set; }
    public String fundraisingName { get; set; }
 
    public SuccessfullPaymentPageController() {
        
     transactionId = ApexPages.currentPage().getParameters().get('transactionId');
     String amountParam = ApexPages.currentPage().getParameters().get('amount');
     amount = String.valueOf((Decimal.valueOf(amountParam)).setScale(2));

     String paymentTypeParam = ApexPages.currentPage().getParameters().get('paymentType');
     if (paymentTypeParam == 'card') {
         paymentType = '•••• •••• •••• 4242';
     }else {
         paymentType = paymentTypeParam;
     }

     paymentDateTime = ApexPages.currentPage().getParameters().get('date');
     currencySign = ApexPages.currentPage().getParameters().get('currency');
     donorEmail = ApexPages.currentPage().getParameters().get('donorEmail');
     fundraisingName = ApexPages.currentPage().getParameters().get('fundraisingName');

    }

    @RemoteAction
    public static String sendReceiptToEmail(String transactionId, String donorEmail, String fundraisingName, String currencySign, 
                                            String amount, String paymentDateTime, String paymentType) {
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { donorEmail });
            email.setSubject('Payment Receipt');
            String emailTemplate = EmailService.sendDonationReceipt(donorEmail, transactionId, fundraisingName, paymentType, currencySign, amount, paymentDateTime);
            email.setHtmlBody(emailTemplate);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            return 'Email sent successfully!';
        } catch (Exception ex) {
            return 'Failed to send email: ' + ex.getMessage();
        }
    }
 }