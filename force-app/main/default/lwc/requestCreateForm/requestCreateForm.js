import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RequestAssistanceForm extends LightningElement {
    @track fields = [
        'Description__c',
        'Requested_Amount__c',
        'Category__c',         
        'Visibility__c',
        'Due_Date__c'
    ];
    // Handle successful record creation
    handleSuccess(event) {
        const recordId = event.detail.id;
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Request submitted successfully!',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }
    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Failed to submit the request.',
                variant: 'error'
            })
        );
    }
}