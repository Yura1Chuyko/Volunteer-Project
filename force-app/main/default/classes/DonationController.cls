public with sharing class DonationController {
    @AuraEnabled
    public static String makeDonation(String fundraisingId, Decimal amount, String cur){
        try {
            return createStripePaymentIntent(fundraisingId,amount,cur);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String cancelDonation(String paymentId){
        String stripeSecretKey = 'sk_test_51QLTecElvZyEGtYByIV2PTa0TYEiJ5v5SlNOKdniF4x1l6slniEAvybwrjmRkx9m6HPE4oOmY4OLLv8JVKCYmGhY00PDRsnDZ9';  // Alternatively, use Named Credential for secret key
        
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


    private static String createStripePaymentIntent(String fundraisingId, Decimal amount, String cur) {
        String stripeUrl = 'https://api.stripe.com/v1/payment_intents';
        String stripeSecretKey = 'sk_test_51QLTecElvZyEGtYByIV2PTa0TYEiJ5v5SlNOKdniF4x1l6slniEAvybwrjmRkx9m6HPE4oOmY4OLLv8JVKCYmGhY00PDRsnDZ9';  // Alternatively, use Named Credential for secret key
        HttpRequest req = new HttpRequest();
        req.setEndpoint(stripeUrl);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + stripeSecretKey);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String bodyParams = 'currency=' + cur + 
                            '&amount=' + amount + 
                            '&metadata[user]=Ivan Kozak' + 
                            '&expand[]=latest_charge' + 
                            '&automatic_payment_methods[enabled]=true';   
        req.setBody(bodyParams);
        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                System.debug((String) result.get('latest_charge'));
                return (String) result.get('client_secret');
            } else {
                throw new AuraHandledException('Error from Stripe: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return '';
    }
}