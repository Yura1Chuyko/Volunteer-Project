import { LightningElement } from 'lwc';
import { generateData } from 'c/donationUtils';


const columns = [
    { label: 'Label', fieldName: 'name' },
    { label: 'Website', fieldName: 'website', type: 'url' },
    { label: 'Phone', fieldName: 'phone', type: 'phone' },
    { label: 'Balance', fieldName: 'amount', type: 'currency' },
    { label: 'CloseAt', fieldName: 'closeAt', type: 'date' },
];


export default class FundraisingProjectsDataTable extends LightningElement {
    data = [];
    columns = columns;

    connectedCallback() {
        const data = generateData({ amountOfRecords: 100 });
        this.data = data;
    }

    handleFundRaisingSelection(event){
        console.log(event.detail.selectedRows[0]);
        this.dispatchEvent(new CustomEvent('fundraisingselection', {
            detail: {
                fundRaising: event.detail.selectedRows[0]
            }
        }))
        this.selectedPA=event.detail.selectedRows[0];                
    }
}