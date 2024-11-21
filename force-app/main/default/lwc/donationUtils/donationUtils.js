import getFundraisingActionsByStatus from '@salesforce/apex/FundraisingActionController.getFundraisingActionsByStatus';


export const getFundraisingActions = async (status) =>{
    try{
        const res = await getFundraisingActionsByStatus({status}); 

        const formattedFundraisingActions = res.map(fa => {
            return {
                ...fa,
                fundraisingUrl: '/lightning/r/Fundraising_Action__c/' + fa.Id + '/view',
                VolunteerUrl: '/lightning/r/User/' + fa.Volunteer__c + '/view',
                VolunteerName: fa.Volunteer__r.Username,
                Description__c: fa.Associated_Military_Request__r.Description__c,
                Category__c: fa.Associated_Military_Request__r.Category__c
            }
        })
        return formattedFundraisingActions;
    }catch(error){
        console.log(error.message);
    }
}

export const getMinAmountForUah = async () => {
    const currencyConverterUrl = 'https://latest.currency-api.pages.dev/v1/currencies/usd.json';
    const res = await fetch(currencyConverterUrl);
    const exchangeRate = await res.json();
    console.log(exchangeRate);
    
    const oneUsdInUah = (+exchangeRate.usd.uah).toFixed(2);
    console.log(oneUsdInUah);
    return oneUsdInUah;
}

export const getCurrencyCode = (currency) =>{
    switch (currency){
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