import { LightningElement } from 'lwc';

export default class DonationAmount extends LightningElement {

    currency = '₴';

    get donationOptions() {
        const amounts = [50, 100, 200, 500, 1000];
        return amounts.map((amount) => ({
            label: `${this.currency}${amount}`,
            value: amount,
        }));
    }

    getCurrencyCode(){
        switch (this.currency){
            case '₴': {
                return 'UAH'
            }
            case '$': {
                return 'USD'
            }
            case '€': {
                return 'EUR'
            }
            case '£': {
                return 'GBP'
            }
        }
    }


    handleCurrencyChange(event){
        this.currency = event.target.label;
        const currencyCode = this.getCurrencyCode();
        this.dispatchEvent(new CustomEvent('currencychange', {
            detail: {
                currency: currencyCode
            }
        }))
    }


    handleStandardAmountToPay(event){
        const buttonLabel = event.target.label;
        let amountToDonate;
        if (buttonLabel.includes('50')) {
            amountToDonate = 50;
        } else if (buttonLabel.includes('1000')) {
            amountToDonate = 1000;
        } else if (buttonLabel.includes('100')) {
            amountToDonate = 100;
        } else if (buttonLabel.includes('200')) {
            amountToDonate = 200;
        } else if (buttonLabel.includes('500')) {
            amountToDonate = 500;
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