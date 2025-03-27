/**
* @File Name : GleifBatch.cls
* @Description :  This batch class retrieves and updates Legal Entity data from the GLEIF API for records with a non-empty LEI.
* @Author :
* @Last Modified By :
* @Last Modified On : March 26, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | March 26, 2025 |   | Initial Version
**/

// GleifBatch.cls
/**
 * @description This batch class retrieves and updates Legal Entity data from the GLEIF API for records with a non-empty LEI.
 */
public class GleifBatch implements Database.Batchable<sObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, lei__c, name, country__c, status__c FROM LegalEntity__c WHERE lei__c != null AND lei__c != '']);
    }

    public void execute(Database.BatchableContext BC, List<LegalEntity__c> scope) {
        List<LegalEntity__c> entitiesToUpdate = new List<LegalEntity__c>();
        String[] leiLst = new String[]{''};
        
        for (LegalEntity__c e : scope) {
            leiLst.add(e.lei__c);
        }
        
        String leiString = '[' + String.join(leiLst, ', ') + ']';
        entitiesToUpdate = GleifSFIntegration.getLegalEntityData(leiString);
        
        if (!entitiesToUpdate.isEmpty()) {
            update entitiesToUpdate;
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch finished!!!');
    }

    
}