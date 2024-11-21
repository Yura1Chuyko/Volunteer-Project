import { LightningElement } from 'lwc';
import { getMinAmountForUah, getCurrencyCode } from 'c/donationUtils';

export default class DonationAmount extends LightningElement {

    currency = '₴';
    minAmount = 1;

    get donationOptions() {
        const amounts = [50, 100, 200, 500, 1000];
        return amounts.map((amount) => ({
            label: `${this.currency}${amount}`,
            value: amount,
        }));
    }

    get minAmountToPay() {
        return this.minAmount;
    }

    get amountInputLabel(){
        return `Enter Amount Of Money Min (${this.minAmount + this.currency})`
    }

    connectedCallback(){
        getMinAmountForUah()
            .then(rate => this.minAmount = rate)
    }

    // getCurrencyCode(){
    //     switch (this.currency){
    //         case '₴': {
    //             return 'UAH'
    //         }
    //         case '$': {
    //             return 'USD'
    //         }
    //         case '€': {
    //             return 'EUR'
    //         }
    //         case '£': {
    //             return 'GBP'
    //         }
    //     }
    // }


    async handleCurrencyChange(event){
        this.currency = event.target.label;
        const currencyCode = getCurrencyCode(this.currency);
        if(currencyCode === 'EUR' || currencyCode === 'GBP' || currencyCode === 'USD'){
            this.minAmount = 1;
        }else{
            this.minAmount = await getMinAmountForUah();
        }
        this.dispatchEvent(new CustomEvent('currencychange', {
            detail: {
                currency: currencyCode,
            }
        }))
    }


    handleStandardAmountToPay(event){
        const amount = +(event.target.label.slice(1));
        let amountToDonate;
        switch (amount) {
            case 50: {
                amountToDonate = 50;
                break;
            }
            case 100: {
                amountToDonate = 100;
                break;
            }
            case 200: {
                amountToDonate = 200;
                break;
            }
            case 500: {
                amountToDonate = 500;
                break;
            }
            case 1000: {
                amountToDonate = 1000;
            }
        }
        console.log(amountToDonate);
        this.dispatchEvent(new CustomEvent('amountchange', {
            detail: {
                amount: amountToDonate * 100
            }
        }));
    }

    handleCustomAmountChange(event){
        this.dispatchEvent(new CustomEvent('amountchange', {
            detail: {
                amount: +event.target.value * 100
            }
        }))
    }
}