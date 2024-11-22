import { LightningElement, track } from 'lwc';
import { getFundraisingActions } from 'c/donationUtils';


const columns = [
    { label: 'Fundraising Name', fieldName: 'fundraisingUrl', type: 'url', typeAttributes: {label: { fieldName: 'Name' }},},
    { label: 'Amount Raised', fieldName: 'Amount_Raised__c', type: 'currency' },
    { label: 'Fundraising Goal', fieldName: 'Fundraising_Goal__c', type: 'currency' },
    { label: 'Description', fieldName: 'Description__c'},
    { label: 'Category', fieldName: 'Category__c'},
    { label: 'Volunteer', fieldName: 'VolunteerUrl', type: 'url', typeAttributes: {label: { fieldName: 'VolunteerName' }}},
];


export default class FundraisingProjectsDataTable extends LightningElement {
    @track data = [];
    columns = columns;

    connectedCallback() {
        getFundraisingActions('In Progress')
            .then(res => {
                this.data = res
            })
    }

    handleFundRaisingSelection(event){
        this.dispatchEvent(new CustomEvent('fundraisingselection', {
            detail: {
                fundraising: {
                    id: event.detail.selectedRows[0].Id,
                    name: event.detail.selectedRows[0].Name
                }
            }
        }))
    }
}