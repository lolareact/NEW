/**
 * @description GleifSearchComp is a Lightning Web Component that allows users to search for GLEIF records 
 * using a Legal Entity Identifier (LEI). It displays the search results in a datatable.
 */
import { LightningElement, track } from 'lwc';
import searchGleifRecords from '@salesforce/apex/GleifSearchController.fetchLei';

// Define the columns for the datatable.
const COLUMNS = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'LEI CODE', fieldName: 'LEI__c' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Country', fieldName: 'Country__c' } 
];

export default class GleifSearchComp extends LightningElement {
    // Track the search key entered by the user.
    @track searchKey = '';
    // Track the data retrieved from Apex.
    @track gleifData;
    // Track any errors that occur during the search.
    @track error;
    // Assign the defined columns to the datatable.
    columns = COLUMNS;

    // Handle input change event and update the search key.
    handleInputChange(event) {
        this.searchKey = event.target.value;
    }

    // Handle the search button click.
    handleSearch() {
        // Validate the length of the search key.
        if (this.searchKey.length > 20) {
            this.error = 'Input exceeds 20 characters. Please shorten it.';
            return; // Exit the function if validation fails.
        }
        
        // Clear any previous errors.
        this.error = null;
        // Call the Apex method to search for GLEIF records.
        searchGleifRecords({ lei: this.searchKey })
            .then(result => {
                // Assign the result to the gleifData property.
                this.gleifData = result;
            })
            .catch(error => {
                // Handle any errors that occur during the Apex call.
                this.error = 'Error retrieving data.';
                // Clear the gleifData property.
                this.gleifData = null;
            });
    }
}