import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import STRIPE_JS from '@salesforce/resourceUrl/StripeJS';
import makeDonation from '@salesforce/apex/DonationController.makeDonation';
import cancelDonation from '@salesforce/apex/DonationController.cancelDonation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// const STRIPE_JS = 'https://js.stripe.com/v3/';


export default class DonationForm extends LightningElement {

    currentStep = '1';
    selectedFundraising = '';
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

    connectedCallback() {

        loadScript(this, STRIPE_JS)
            .then(() => {
                this.stripe = Stripe('pk_test_51QLTecElvZyEGtYBgUm1fWOlS61F5ZFTLpg0PLcunjFMmJi8gV1FKXQDYUa6A7KBb5TneC8bmaOz8xfy0MSsCgIR00WNcFOtFA');

            })
            .catch((error) => {
                this.errorMessage = `Error loading Stripe: ${error}`;
            });
    }

    get isStepOne(){
        return this.currentStep === '1';
    }

    get isStepTwo(){
        return this.currentStep === '2';
    }

    get isStepThree(){
        return this.currentStep === '3';        
    }

    handleFundraisingSelected(event){
        this.selectedFundraising = event.detail.fundRaising;
    }

    handleAmountChange(event){
        this.donationAmount = event.detail.amount;
        console.log(this.donationAmount);
        
    }

    handleCurrencyChange(event){
        console.log(event.detail.currency);
        this.currency = event.detail.currency;
    }

    handleBackClick(){
        this.currentStep = '1';
    }

    handleNextClick(){
        if(this.currentStep === '3'){
            return;
        }
        this.currentStep = (+this.currentStep + 1).toString();
    }



    renderPaymentForm(clientSecret){
        const appearance = { theme: 'stripe' };
        const options = {
            layout: {
                type: 'tabs',
                defaultCollapsed: false,
            },
            paymentMethodTypes: ['card', 'google_pay'],

        };

        this.elements = this.stripe.elements({ clientSecret, appearance, loader: 'auto' });
        const paymentElementContainer = this.template.querySelector('[data-id="payment-element"]');
        const paymentElement = this.elements.create('payment', options);
        paymentElement.mount(paymentElementContainer);
        this.stripeFormRendered = true;
    }

    async handleDonation() {
        // TODO check if form is valid
        this.currentStep = '3';
        this.initializingPayment = true;
        try{
            const clientSecret = await makeDonation({
                fundraisingId: this.selectedFundraising,
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
                    return_url: 'https://flow-speed-8865--devivan.sandbox.my.salesforce-setup.com/apex/ProcessingPayment?hello=world'
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