@isTest
global with sharing class StripePaymentMock implements HttpCalloutMock {

    private String fundraisingId;

    global void setFundraisingId(String fundraisingId) {
        this.fundraisingId = fundraisingId;
    }

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        
        if (req.getEndpoint().contains('/charges')) {
            res.setStatusCode(200);
            res.setBody('{"data": [{"id": "txn_123", "status": "succeeded", "amount": 5000, "created": 1693276800, "currency": "usd", "metadata": {"donorEmail": "test@example.com", "donorFullName": "John Doe", "fundraisingId": "' + fundraisingId + '", "fundraisingName": "Charity Event"}, "payment_method_details": {"type": "card"}}]}');
        } else if (req.getEndpoint().contains('/v1/currencies/usd.json')) {
            res.setStatusCode(200);
            res.setBody('{"usd": {"uah": 36.5}}');
        } else {
            res.setStatusCode(400);
            res.setBody('{"error": "Bad request"}');
        }
        return res;
    }
}