import { LightningElement, wire, track } from 'lwc';
import getPendingApprovals from '@salesforce/apex/RequestApprovalController.getPendingApprovals';
import handleApproval from '@salesforce/apex/RequestApprovalController.processApproval';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class RequestApprovalAdmin extends LightningElement {
    @track pendingApprovals = [];
    wiredApprovals;

    @wire(getPendingApprovals)
    wiredGetPendingApprovals(result) {
        this.wiredApprovals = result;
        if (result.data) {
            console.log('Pending Approvals Data:', result.data); // Debugging
            this.pendingApprovals = result.data;
        } else if (result.error) {
            console.error('Error fetching pending approvals:', result.error); // Debugging
            this.showToast('Error', 'Error loading approvals.', 'error');
        }
    }

    approveRequest(event) {
        const recordId = event.target.dataset.id;
    
        handleApproval({ recordId: recordId, isApproved: true })
            .then(() => {
                // Success handler
                this.showToast('Success', 'Request approved successfully.', 'success');
                return refreshApex(this.pendingApprovals);
            })
            .catch((error) => {
                // Error handler
                this.showToast('Error', error.body.message, 'error');
            });
    }
    rejectRequest(event) {
        const recordId = event.target.dataset.id;
    
        handleApproval({ recordId: recordId, isApproved: false })
            .then(() => {
                // Success handler
                this.showToast('Success', 'Request rejected successfully.', 'success');
                return refreshApex(this.pendingApprovals);
            })
            .catch((error) => {
                // Error handler
                this.showToast('Error', error.body.message, 'error');
            });
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}