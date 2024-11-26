@isTest
global with sharing class ExceptionThrowingMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        throw new CalloutException('Simulated callout exception');
    }
}