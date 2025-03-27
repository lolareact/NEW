/**
* @File Name : GleifSFIntegrationTest.cls
* @Description :  This is test class for GleifSFIntegration class.
* @Author :
* @Last Modified By :
* @Last Modified On : March 26, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | March 26, 2025 |   | Initial Version
**/

@isTest
public class GleifSFIntegrationTest {

    @isTest
    static void testGetLegalEntityData_Success() {
        // Mock HTTP response
        String jsonResponse = '{"data": [{"id": "123", "attributes": {"lei": "5493001KJTIIGC1Y0Y11", "entityStatus": "ACTIVE", "legalAddress": {"country": "LU"}, "name": "Test Company"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'OK', jsonResponse));

        // Call the method
        List<LegalEntity__c> ls = GleifSFIntegration.getLegalEntityData('5493001KJTIIGC1Y0Y11'); 
		LegalEntity__c entity = ls.get(0);
        
        // Assertions
        System.assertNotEquals(null, entity, 'Entity should not be null');
        System.assertEquals('Test Company', entity.Name, 'Name should match');
        System.assertEquals('5493001KJTIIGC1Y0Y11', entity.lei__c, 'LEI should match');
        System.assertEquals('ACTIVE', entity.status__c, 'Status should match');
        System.assertEquals('LU', entity.country__c, 'Country should match');
    }

    @isTest
    static void testGetLegalEntityData_EmptyResponse() {
        // Mock HTTP response with empty data
        String jsonResponse = '{"data": []}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'OK', jsonResponse));

        // Call the method
         List<LegalEntity__c> entity = GleifSFIntegration.getLegalEntityData('INVALID_LEI');

        // Assertion
        System.assertEquals(null, entity, 'Entity should be null for empty response');
    }

    @isTest
    static void testGetLegalEntityData_NullLegalAddress() {
        // Mock HTTP response with null legal address
        String jsonResponse = '{"data": [{"id": "123", "attributes": {"lei": "5493001KJTIIGC1Y0Y11", "entityStatus": "ACTIVE", "legalAddress": null, "name": "Test Company"}}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'OK', jsonResponse));

        // Call the method
         List<LegalEntity__c> entity = GleifSFIntegration.getLegalEntityData('5493001KJTIIGC1Y0Y11');

        // Assertion
       // System.assertEquals(null, entity.country__c, 'Country should be null when legalAddress is null');
    }

    @isTest
    static void testGetLegalEntityData_CalloutError() {
        // Mock HTTP response with an error status code
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(404, 'Not Found', ''));

        // Call the method and expect a CalloutException
        try {
             List<LegalEntity__c> entity = GleifSFIntegration.getLegalEntityData('INVALID_LEI');
            System.assert(false, 'Expected CalloutException was not thrown');
        } catch (CalloutException e) {
            System.assert(e.getMessage().contains('GLEIF API call failed'), 'Exception message should contain callout failure');
        }
    }

    @isTest
    static void testGetLegalEntityData_JsonParsingError() {
        // Mock HTTP response with invalid JSON
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'OK', 'invalid json'));

        // Call the method and expect a JSONException
        try {
             List<LegalEntity__c> entity = GleifSFIntegration.getLegalEntityData('INVALID_LEI');
            System.assert(false, 'Expected JSONException was not thrown');
        } catch (JSONException e) {
            System.assert(e.getMessage().contains('Error parsing JSON'), 'Exception message should contain JSON parsing error');
        }
    }

    // Mock HTTP response generator
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String status;
        private String body;

        public MockHttpResponseGenerator(Integer statusCode, String status, String body) {
            this.statusCode = statusCode;
            this.status = status;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(statusCode);
            res.setStatus(status);
            return res;
        }
    }
}