/**
* @File Name : GleifSearchController.cls
* @Description :  Retrieves Legal Entity data using the GleifSFIntegration class.
* @Author :
* @Last Modified By :
* @Last Modified On : March 26, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | March 26, 2025 |   | Initial Version
**/

public with sharing class GleifSearchController {

    /**
     * @description Retrieves Legal Entity data based on the provided LEI code.
     * @param lei The LEI code to search for.
     * @return LegalEntity__c The Legal Entity object populated with data from the API.
     */
    @AuraEnabled(cacheable=true)
    public static LegalEntity__c getLegalEntity(String lei) {
         // return [SELECT Id, Name, lei__c,status__c, country__c FROM LegalEntity__c WHERE lei__c =: lei];
        System.debug('print lei : ' + lei);
        
        try{
             List<LegalEntity__c> ls = GleifSFIntegration.getLegalEntityData(lei);
             return ls.get(0); // return only searching entity
        }catch(Exception e){
            throw new AuraHandledException('Error getting entity');
        }
       
    }

}