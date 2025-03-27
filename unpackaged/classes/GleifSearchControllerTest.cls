/**
* @File Name : GleifSearchControllerTest.cls
* @Description :  Test class for GleifSearchController
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
private class GleifSearchControllerTest {

    @isTest
    static void testGetLegalEntity() {  
        String mockResponse = '{"data": [{"attributes": {"entity": {"legalName": {"name": "Test Company"}, "legalAddress": {"country": "LU"}}, "lei": "222100EG1QRYPH6C8D53", "registration": {"status": "ISSUED"}}}]}';
        Test.setMock(HttpCalloutMock.class, new GleifSFIntegrationTest.MockHttpResponseGenerator(200, 'OK', mockResponse));

        LegalEntity__c legalEntity = GleifSearchController.getLegalEntity('222100EG1QRYPH6C8D53');
        System.assertEquals('Test Company', legalEntity.Name);
        System.assertEquals('222100EG1QRYPH6C8D53', legalEntity.lei__c);
        System.assertEquals('LU', legalEntity.country__c);
        System.assertEquals('ISSUED', legalEntity.status__c);
    }
}