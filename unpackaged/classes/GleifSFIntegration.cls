/**
* @File Name : GleifSFIntegration.cls
* @Description :  This class integrates with the GLEIF API to retrieve Legal Entity data based on LEI code.
* @Author :
* @Last Modified By :
* @Last Modified On : March 26, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | March 26, 2025 |   | Initial Version
**/

public class GleifSFIntegration {
    
    // Base URL of the GLEIF API
    private static final String GLEIF_API_BASE_URL = 'https://api.gleif.org/api/v1/lei-records?filter[lei]=';

    // Response classes to map the JSON response from the API
    public class GleifResponse {
        public List<DataWrapper> data;
    }
    
    public class DataWrapper {
        public String id;
        public Attributes attributes;
    }
    
    public class Attributes {
        public String lei;
        public String entityStatus;
        public LegalAddress legalAddress;
        public String name;
    }
    
    public class LegalAddress {
        public String country;
    }

    /**
     * @description Retrieves Legal Entity data from the GLEIF API based on the provided LEI code.
     * @param leiCode The LEI code to search for.
     * @return LegalEntity__c The Legal Entity object populated with data from the API.
     * @throws CalloutException If there's an issue with the API call.
     * @throws JSONException If there's an issue parsing the JSON response.
     */
    public static List<LegalEntity__c> getLegalEntityData(String leiCode) {
        
        String endpoint = GLEIF_API_BASE_URL + EncodingUtil.urlEncode(leiCode, 'UTF-8');
        List<LegalEntity__c> entityLst = new List<LegalEntity__c>();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                System.debug('results from api: ' + results);
                
                GleifResponse gleifResponse = (GleifResponse) JSON.deserialize(response.getBody(), GleifResponse.class);
                System.debug(' gleifResponse: ' + gleifResponse);
                if (gleifResponse != null && gleifResponse.data != null && !gleifResponse.data.isEmpty()) {
                
                   // get returned entity list
                    for(DataWrapper record : gleifResponse.data){
                        Attributes attributes = record.attributes;
                    
                        // Create a new LegalEntity__c record
                        LegalEntity__c entity = new LegalEntity__c();
                        entity.Name = attributes.name;
                        entity.lei__c = attributes.lei;
                        entity.status__c = attributes.entityStatus;
                        entity.country__c = attributes.legalAddress != null ? attributes.legalAddress.country : null;
                        
                        System.debug(' lei record received: ' + entity);
                        entityLst.add(entity);
                        
                    }
                    return entityLst;
                }
            } else {
                System.debug('Error calling GLEIF API: ' + response.getStatusCode() + ' - ' + response.getStatus());
                throw new CalloutException('GLEIF API call failed: ' + response.getStatusCode() + ' - ' + response.getStatus());
            }
        } catch (JSONException e) {
            System.debug('Error parsing JSON: ' + e.getMessage());
            throw new JSONException('Error parsing JSON: ' + e.getMessage());
        } catch (CalloutException e) {
            System.debug('Error calling GLEIF API: ' + e.getMessage());
            throw new CalloutException('GLEIF API call failed: ' + e.getMessage());
        }
        return null; // Return null if no data is found or an error occurs.
    }
}