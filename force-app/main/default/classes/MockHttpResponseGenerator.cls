@isTest
global with sharing class MockHttpResponseGenerator implements HttpCalloutMock {
    private Integer statusCode;
    private String responseBody;

    global void setMockResponse(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setBody(responseBody);
        return res;            
    }

}