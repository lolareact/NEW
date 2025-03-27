// gleifSearchComp.test.js
import { createElement } from 'lwc';
import GleifSearchComp from 'c/gleifSearchComp';
import searchGleifRecords from '@salesforce/apex/GleifSearchController.fetchLei';

// Mock Apex wire adapter
jest.mock(
    '@salesforce/apex/GleifSearchController.fetchLei',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

describe('c-gleif-search-comp', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('should update searchKey when input changes', () => {
        const element = createElement('c-gleif-search-comp', {
            is: GleifSearchComp
        });
        document.body.appendChild(element);

        const inputElement = element.shadowRoot.querySelector('lightning-input');
        inputElement.value = 'test';
        inputElement.dispatchEvent(new CustomEvent('change'));

        return Promise.resolve().then(() => {
            expect(element.searchKey).toBe('test');
        });
    });

    it('should call Apex method with correct searchKey on handleSearch', () => {
        const element = createElement('c-gleif-search-comp', {
            is: GleifSearchComp
        });
        document.body.appendChild(element);

        element.searchKey = 'testLei';
        element.handleSearch();

        return Promise.resolve().then(() => {
            expect(searchGleifRecords.mock.calls.length).toBe(1);
            expect(searchGleifRecords.mock.calls[0][0]).toEqual({ lei: 'testLei' });
        });
    });

    it('should set gleifData on successful Apex call', () => {
        const element = createElement('c-gleif-search-comp', {
            is: GleifSearchComp
        });
        document.body.appendChild(element);

        const mockData = [{ Name: 'Test Name', LEI__c: 'testLei', Status__c: 'Active', Country__c: 'US' }];
        searchGleifRecords.mockResolvedValue(mockData);

        element.searchKey = 'testLei';
        element.handleSearch();

        return Promise.resolve().then(() => {
            expect(element.gleifData).toEqual(mockData);
        });
    });

    it('should set error on failed Apex call', () => {
        const element = createElement('c-gleif-search-comp', {
            is: GleifSearchComp
        });
        document.body.appendChild(element);

        searchGleifRecords.mockRejectedValue(new Error('Test Error'));

        element.searchKey = 'testLei';
        element.handleSearch();

        return Promise.resolve().then(() => {
            expect(element.error).toBe('Error retrieving data.');
            expect(element.gleifData).toBeNull();
        });
    });

    it('should set error when searchKey length exceeds 20', () => {
        const element = createElement('c-gleif-search-comp', {
            is: GleifSearchComp
        });
        document.body.appendChild(element);

        element.searchKey = 'thisIsALongSearchKeyThatExceeds20Characters';
        element.handleSearch();

        return Promise.resolve().then(() => {
            expect(element.error).toBe('Input exceeds 20 characters. Please shorten it.');
        });
    });
});