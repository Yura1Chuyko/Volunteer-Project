public class StripePaymentController {

    private String formatDateTime(Long timestamp){
        DateTime dt = DateTime.newInstance(timestamp * 1000);
        String formattedDateTime = dt.format('MMM dd, yyyy, hh:mm:ss a');
        return formattedDateTime;
    }

    private String getCurrencySignByIsoCode(String curIsoCode){
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
        String formattedDateTime = formatDateTime(timestamp);
        String curIsoCode = (String) chargeParameters.get('currency');
        String currencySign = getCurrencySignByIsoCode(curIsoCode);

        PageReference pageRef;
        if (status == 'succeeded') {
            String transactionId = (String) chargeParameters.get('balance_transaction');
            Integer amount = (Integer) chargeParameters.get('amount');
            String paymentType = (String) chargeParameters.get('paymentType');
            pageRef = new PageReference('/apex/PaymentSuccessful?transactionId=' + transactionId + '&amount=' + amount + '&paymentType=' + paymentType + '&date=' + formattedDateTime + '&currency=' + currencySign);
        }else {
            pageRef = new PageReference('/apex/PaymentFailedPage');            
        }
        return pageRef;
    }

    private Map<String,Object> getChargeDetailsByPaymentIntentId(String paymentIntentId) {
        Map<String,Object> chargeParameters = new Map<String,Object>();
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.stripe.com/v1' + '/charges?payment_intent=' + paymentIntentId);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + 'sk_test_51QLTecElvZyEGtYByIV2PTa0TYEiJ5v5SlNOKdniF4x1l6slniEAvybwrjmRkx9m6HPE4oOmY4OLLv8JVKCYmGhY00PDRsnDZ9');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if (responseMap.containsKey('data')) {
                    List<Object> chargeData = (List<Object>) responseMap.get('data');
                    for (Object chargeObj : chargeData) {
                        Map<String, Object> chargeMap = (Map<String, Object>) chargeObj;
                        System.debug(chargeMap);
                        String status = (String) chargeMap.get('status');
                        Integer amount = (Integer) chargeMap.get('amount');
                        String balanceTransaction = (String) chargeMap.get('id');
                        String paymentMethodType ='';
                        Long createdTime = (Long) chargeMap.get('created');
                        String cur = (String) chargeMap.get('currency');

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
}