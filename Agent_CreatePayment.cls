public with sharing class Agent_CreatePayment {
    
    public class Result {
        @InvocableVariable(label='Payment Link URL')
        public String paymentLink;
    }

    @InvocableMethod(label='Create Payment Link for Opportunity (Agentforce)')
    public static List<Result> createPayment(List<Id> opportunityIds) {

        List<Result> outputs = new List<Result>();

        for (Id oppId : opportunityIds) {
            Result r = new Result();

            try {
                // Generate Stripe link
                String url = StripeDirectService.createPaymentLink(oppId);

                // Fetch created payment record
                Payment__c p = [
                    SELECT Id, Payment_Link_Full__c 
                    FROM Payment__c 
                    WHERE Opportunity__c = :oppId 
                    ORDER BY CreatedDate DESC 
                    LIMIT 1
                ];

                // Return ONLY URL
                r.paymentLink = p.Payment_Link_Full__c;

            } catch (Exception ex) {
                r.paymentLink = 'ERROR: ' + ex.getMessage();
            }

            outputs.add(r);
        }
        return outputs;
    }
}