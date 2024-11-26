public class StripePaymentController {

    private String formatDateTime(Long timestamp){
        DateTime dt = DateTime.newInstance(timestamp * 1000);
        String formattedDateTime = dt.format('MMM dd, yyyy, hh:mm:ss a');
        return formattedDateTime;
    }

    public String getCurrencySignByIsoCode(String curIsoCode){
        switch on curIsoCode {
            when 'usd' {
                return '$';
            }
            when 'uah' {
                return '₴';
            }
            when 'eur' {
                return '€';
            }
            when 'gbp' {
                return '£';
            }
        }
        return '';
    }

    public PageReference handleRedirect() {

        String paymentIntentId = ApexPages.currentPage().getParameters().get('payment_intent');
        Map<String, Object> chargeParameters = getChargeDetailsByPaymentIntentId(paymentIntentId);
        
        String status = (String) chargeParameters.get('status');
        Long timestamp = (Long) chargeParameters.get('createdTime');
        String curIsoCode = (String) chargeParameters.get('currency');
        Decimal amount = ((Decimal) chargeParameters.get('amount')) / 100;

        String donorFullName = (String) chargeParameters.get('donorFullName');
        String donorEmail = (String) chargeParameters.get('donorEmail');
        String fundraisingId = (String) chargeParameters.get('fundraisingId');
        String fundraisingName = (String) chargeParameters.get('fundraisingName');

        String formattedDateTime = formatDateTime(timestamp);
        String currencySign = getCurrencySignByIsoCode(curIsoCode);

        Decimal amountInUah;

        if (curIsoCode != 'uah') {
            amountInUah = getAmountInUah(amount, curIsoCode);
        }else {
            amountInUah = amount;
        }


        PageReference pageRef;
        String transactionId = (String) chargeParameters.get('balance_transaction');
        String paymentType = (String) chargeParameters.get('paymentType');
        if (status == 'succeeded') {
            DonationHandler.createDonate(donorFullName, fundraisingId, amountInUah);
            pageRef = new PageReference('/apex/PaymentSuccessful?transactionId=' + transactionId + '&amount=' + 
                                        amount + '&paymentType=' + paymentType + '&date=' + formattedDateTime + 
                                        '&currency=' + currencySign + '&donorEmail=' + donorEmail + 
                                        '&fundraisingName=' + fundraisingName);
        }else {
            pageRef = new PageReference('/apex/PaymentFailedPage?transactionId=' + transactionId + '&amount=' + 
                                        amount + '&paymentType=' + paymentType + '&date=' + formattedDateTime + 
                                        '&currency=' + currencySign +
                                        '&fundraisingName=' + fundraisingName);          
        }
        return pageRef;
    }


    public Map<String,Object> getChargeDetailsByPaymentIntentId(String paymentIntentId) {
        Map<String,Object> chargeParameters = new Map<String,Object>();
        StripeSecret__mdt stripeSecret = StripeSecret__mdt.getInstance('StripeSecret');
        String stripeSecretKey = stripeSecret.StripeSecretKey__c;
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.stripe.com/v1' + '/charges?payment_intent=' + paymentIntentId);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + stripeSecretKey);
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if (responseMap.containsKey('data')) {
                    List<Object> chargeData = (List<Object>) responseMap.get('data');
                    for (Object chargeObj : chargeData) {

                        Map<String, Object> chargeMap = (Map<String, Object>) chargeObj;
                        Map<String,Object> metadata = (Map<String,Object>) chargeMap.get('metadata');

                        
                        String status = (String) chargeMap.get('status');
                        Decimal amount = (Decimal) chargeMap.get('amount');
                        String balanceTransaction = (String) chargeMap.get('id');
                        String paymentMethodType ='';
                        Long createdTime = (Long) chargeMap.get('created');
                        String cur = (String) chargeMap.get('currency');

                        String donorEmail = (String) metadata.get('donorEmail');
                        String donorFullName = (String) metadata.get('donorFullName');
                        String fundraisingId = (String) metadata.get('fundraisingId');
                        String fundraisingName = (String) metadata.get('fundraisingName');
                        


                        Map<String, Object> paymentMethodDetails = (Map<String, Object>) chargeMap.get('payment_method_details');
                        
                        if (paymentMethodDetails != null) {
                            paymentMethodType = (String) paymentMethodDetails.get('type');
                        }

                        chargeParameters.put('status', status);
                        chargeParameters.put('amount', amount);
                        chargeParameters.put('paymentType', paymentMethodType);
                        chargeParameters.put('balance_transaction', balanceTransaction);                            
                        chargeParameters.put('createdTime', createdTime);                            
                        chargeParameters.put('currency', cur);                            
                        chargeParameters.put('donorEmail', donorEmail);                            
                        chargeParameters.put('donorFullName', donorFullName);                            
                        chargeParameters.put('fundraisingId', fundraisingId);                            
                        chargeParameters.put('fundraisingName', fundraisingName);                            
                    }
                }
            } else {
                throw new CalloutException('Failed to fetch charges from Stripe');
            }
        } catch (Exception e) {
            throw e;
        }
        return chargeParameters;
    }


    public Decimal getAmountInUah(Decimal amount, String currencyIsoCode){
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://latest.currency-api.pages.dev/v1/currencies/' + currencyIsoCode + '.json');
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> exchangeRate = (Map<String, Object>) responseMap.get(currencyIsoCode);
                Decimal uahExchangeRate = (Decimal) exchangeRate.get('uah');
                return (amount * uahExchangeRate).setScale(2);
            }
        } catch (Exception e) {
            throw e;
        }
        return 0;
    }
}