import { LightningElement, track } from 'lwc';
import verifyPayment from '@salesforce/apex/StripeDirectService.verifyPayment';

export default class PaymentResult extends LightningElement {
    @track loading = true;
    @track verifiedSuccess = false;
    @track verifiedFailed = false;
    @track errorMsg = '';
    @track paymentLink = '';
    oppId = null;
    opportunityUrl = '';

    connectedCallback() {
        try {
            const params = new URLSearchParams(window.location.search);
            const sessionId = params.get('session_id');
            const oppId = params.get('oppId');
            const cancel = params.get('cancel');

            if (!sessionId) {
                this.loading = false;
                this.errorMsg = 'Missing session_id in URL.';
                return;
            }
            if (!oppId) {
                this.loading = false;
                this.errorMsg = 'Missing oppId in URL.';
                return;
            }

            // call Apex to verify
            verifyPayment({ sessionId: sessionId, opportunityId: oppId })
                .then(result => {
                    this.loading = false;
                    if (result === 'success') {
                        this.verifiedSuccess = true;
                        this.verifiedFailed = false;
                        // if you want to show the actual payment link, fetch last Payment__c record (optional)
                        // You'll need another Apex method to return Payment_Link_Full__c if required
                    } else {
                        this.verifiedSuccess = false;
                        this.verifiedFailed = true;
                    }
                })
                .catch(error => {
                    this.loading = false;
                    this.errorMsg = (error && error.body && error.body.message) ? error.body.message : JSON.stringify(error);
                });
        } catch (e) {
            this.loading = false;
            this.errorMsg = 'Unexpected error: ' + e.message;
        }
    }
}
