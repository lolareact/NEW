/**
* @File Name : GleifBatchTest.cls
* @Description :  This is test class for GleifBatch class.
* @Author :
* @Last Modified By :
* @Last Modified On : March 26, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | March 26, 2025 |   | Initial Version
**/

// GleifBatchTest.cls
@isTest
private class GleifBatchTest {

    @isTest
    static void testBatchExecution() {
        List<LegalEntity__c> legalEntities = new List<LegalEntity__c>(); 
        legalEntities.add(new LegalEntity__c(lei__c = '222100EG1QRYPH6C8D53'));
        legalEntities.add(new LegalEntity__c(lei__c = '1234567890ABCDEF'));
        insert legalEntities;

        String mockResponse = '{"data": [{"attributes": {"entity": {"legalName": {"name": "Updated Company"}, "legalAddress": {"country": "LU"}}, "lei": "222100EG1QRYPH6C8D53", "registration": {"status": "ACTIVE"}}}]}';
        Test.setMock(HttpCalloutMock.class, new GleifSFIntegrationTest.MockHttpResponseGenerator(200, 'OK', mockResponse));

        Test.startTest();
        GleifBatch bt = new GleifBatch();
		Database.executeBatch(bt, 20);
        Test.stopTest();

        List<LegalEntity__c> updatedEntities = [SELECT Id, Name, country__c, status__c FROM LegalEntity__c WHERE lei__c = '222100EG1QRYPH6C8D53'];
        System.assertEquals(1, updatedEntities.size());
        System.assertEquals('Updated Company', updatedEntities[0].Name);
        System.assertEquals('LU', updatedEntities[0].country__c);
        System.assertEquals('ACTIVE', updatedEntities[0].status__c);

        List<LegalEntity__c> notUpdatedEntities = [SELECT Id, Name, country__c, status__c FROM LegalEntity__c WHERE lei__c = '1234567890ABCDEF'];
        System.assertEquals(1, notUpdatedEntities.size());
        System.assertEquals(null, notUpdatedEntities[0].Name);
    }
}