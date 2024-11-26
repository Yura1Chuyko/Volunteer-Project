import { LightningElement, track } from 'lwc';

export default class RequestCreateParent extends LightningElement {
    @track showForm = false;

    // Handler to open the form
    handleOpenForm() {
        this.showForm = true;
    }

    // Handler to close the form (triggered by the child)
    handleCloseForm() {
        this.showForm = false;
    }
}
