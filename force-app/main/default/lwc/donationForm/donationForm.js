import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import STRIPE_JS from '@salesforce/resourceUrl/StripeJS';
import makeDonation from '@salesforce/apex/DonationController.makeDonation';
import cancelDonation from '@salesforce/apex/DonationController.cancelDonation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";



export default class DonationForm extends LightningElement {

    currentStep = '1';
    donationAmount = '';
    selectedPaymentMethod = 'card';
    stripe;
    elements;
    hasClientSecret;
    stripeFormRendered=false;
    errorMessage;
    initializingPayment = false;
    currency = 'UAH';
    paymentId;


    selectedFundraising = '';


    connectedCallback() {

        loadScript(this, STRIPE_JS)
            .then(() => {
                this.stripe = Stripe('pk_test_51QLTecElvZyEGtYBgUm1fWOlS61F5ZFTLpg0PLcunjFMmJi8gV1FKXQDYUa6A7KBb5TneC8bmaOz8xfy0MSsCgIR00WNcFOtFA');
                // this.stripe = Stripe('pk_test_51QNPbgITtcaPMXo81T8FNnubypLQia3Bo5BOQvZVc14IJ3Wdg6YlLTPQPFtpQ5f9FOzh6FlaufEzkUqV38kYg1Vp00eTPG2Nt9');

            })
            .catch((error) => {
                this.errorMessage = `Error loading Stripe: ${error}`;
            });
    }

    get isStepOne() {
        return this.currentStep === '1';
    }

    get isStepTwo() {
        return this.currentStep === '2';
    }

    get isStepThree() {
        return this.currentStep === '3';        
    }


    handleFundraisingSelected(event) {
        this.selectedFundraising = event.detail.fundraising;        
    }

    handleAmountChange(event){
        this.donationAmount = event.detail.amount;
        
    }

    handleCurrencyChange(event){
        this.currency = event.detail.currency;
    }

    handleBackClick(){
        this.currentStep = '1';
        this.selectedFundraising = '';
    }

    handleNextClick(){
        if(this.currentStep === '3'){
            return;
        }
        if(this.selectedFundraising !== ''){
            this.currentStep = (+this.currentStep + 1).toString();
        } else{
            this.showToast('Warning', 'Please, select fundraising you`d like to donate', 'warning');
        }
    }

    renderPaymentForm(clientSecret){
        const appearance = { theme: 'stripe' };
        const options = {
            layout: {
                type: 'tabs',
                defaultCollapsed: false,
            },
        };

        this.elements = this.stripe.elements({ clientSecret, appearance, loader: 'auto' });
        const paymentElementContainer = this.template.querySelector('[data-id="payment-element"]');
        const paymentElement = this.elements.create('payment', options);
        paymentElement.mount(paymentElementContainer);
        this.stripeFormRendered = true;
    }

    async handleDonation() {
        if(!this.donationAmount || this.donationAmount <= 0){
            this.showToast('Warning', 'Please, choose the amount of money you`d like to donate', 'warning');
            return;
        }
        this.currentStep = '3';
        this.initializingPayment = true;
        
        try{
            const clientSecret = await makeDonation({
                fundraisingId: this.selectedFundraising.id,
                fundraisingName: this.selectedFundraising.name,
                amount: this.donationAmount,
                cur: this.currency.toString(),
            });
            const parts = clientSecret.split('_');
            this.paymentId = parts[0] + '_' + parts[1];
            this.initializingPayment = false;
            this.renderPaymentForm(clientSecret);
        }catch(error){
            this.showToast('Error', error.message, 'error');
        }
    }

    async handleCancelPayment(){
        try{
            const message = await cancelDonation({
                paymentId: this.paymentId
            });
            this.showToast('Success', message, 'success');
            this.resetDonationForm();
        }catch(error){
            this.showToast('Error', error.message, 'error');
        }

    }

    resetDonationForm(){
        this.currentStep = '1';
        this.stripeFormRendered = false;
    }


    async handleConfirmPayment() {
        try {

            if(!this.stripe || !this.elements){
                return;
            }

            const {error: submitError} = await this.elements.submit();

            if (submitError) {
                this.showToast('Warning', submitError.message, 'warning');
                return;
            }

            const { error, paymentIntent } = await this.stripe.confirmPayment({
                elements: this.elements,
                confirmParams: {
                    return_url: 'https://flow-speed-8865.lightning.force.com/apex/ProcessingPayment'
                },
            });            
    
            if (error) {
                this.errorMessage = `Payment Error: ${error.message}`;
            } else if (paymentIntent.status === 'succeeded') {
                this.successMessage = 'Payment successful!';
                this.showToast('Success', 'Payment was completed successfully!', 'success');
            } else {
                this.errorMessage = 'Payment failed or is still processing.';
            }
        } catch (error) {
            this.errorMessage = `Unexpected Error: ${error.message}`;
        }
    }
    

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}