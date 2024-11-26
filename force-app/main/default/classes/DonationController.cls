public with sharing class DonationController {
    @AuraEnabled
    public static String makeDonation(String fundraisingId, String fundraisingName, Decimal amount, String cur){
        try {
            return createStripePaymentIntent(fundraisingId,fundraisingName,amount,cur);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String cancelDonation(String paymentId){
        StripeSecret__mdt stripeSecret = StripeSecret__mdt.getInstance('StripeSecret');
        String stripeSecretKey = stripeSecret.StripeSecretKey__c;
        String endpointUrl = 'https://api.stripe.com/v1/payment_intents/' + paymentId + '/cancel';
         
         HttpRequest req = new HttpRequest();

         req.setEndpoint(endpointUrl);
         req.setMethod('POST');
         req.setHeader('Authorization', 'Bearer ' + stripeSecretKey);
         
         try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                return 'Payment canceled successfully';
            } else {
                return 'Payment cancelation was unsuccessful';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getDonorName(){
        String donorFirstName = UserInfo.getFirstName();
        String donorLastName = UserInfo.getLastName();
        String donorFullName = '';
        if (donorFirstName != null) {
            donorFullName = donorFirstName + ' ' + donorLastName;
        } else {
            donorFullName = donorLastName;
        }
        return donorFullName;
    }

    private static String createStripePaymentIntent(String fundraisingId, String fundraisingName, Decimal amount, String cur) {
        String stripeUrl = 'https://api.stripe.com/v1/payment_intents';
        StripeSecret__mdt stripeSecret = StripeSecret__mdt.getInstance('StripeSecret');
        String stripeSecretKey = stripeSecret.StripeSecretKey__c;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(stripeUrl);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + stripeSecretKey);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String donorFullName = getDonorName();
        String donorEmail = UserInfo.getUserEmail();

        String bodyParams = 'currency=' + cur + 
                            '&amount=' + amount + 
                            '&metadata[donorFullName]=' + donorFullName +
                            '&metadata[donorEmail]=' + donorEmail +
                            '&metadata[fundraisingId]=' + fundraisingId +
                            '&metadata[fundraisingName]=' + fundraisingName +
                            '&automatic_payment_methods[enabled]=true';   
        req.setBody(bodyParams);
        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                return (String) result.get('client_secret');
            } else {
                return 'Error from Stripe: ' + res.getBody();
            }
        } catch (Exception e) {
            throw e;
        }
    }
}