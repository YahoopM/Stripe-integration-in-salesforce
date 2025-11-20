public with sharing class StripeDirectService {

    // Replace with your actual secret key from Stripe dashboard
    private static final String STRIPE_SECRET_KEY = 'sk_test_51SSwrpHQrSrrZxFAB94zZTU6kBQM91In8VZyGCjYEoCqCk83o7Q4eUxwC2r5rMnI4GtlAJliuT2sFAWu4dFRKjFM00uO9P4k9W';

     @AuraEnabled
    public static String createPaymentLink(Id opportunityId) {
        Opportunity opp = [SELECT Id, Name, Amount, Email__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];

        // Construct payment link request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'line_items' => new List<Object>{
                new Map<String, Object>{
                    'price_data' => new Map<String, Object>{
                        'currency' => 'usd',
                        'product_data' => new Map<String, Object>{'name' => opp.Name},
                        'unit_amount' => Integer.valueOf(opp.Amount * 100) // Stripe uses cents
                    },
                    'quantity' => 1
                }
            },
            'mode' => 'payment',
            'success_url' => 'https://yourdomain.com/success',
            'cancel_url' => 'https://yourdomain.com/cancel'
        };

        // Create HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.stripe.com/v1/checkout/sessions');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + STRIPE_SECRET_KEY);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = '';
        body += 'success_url=' + EncodingUtil.urlEncode((String)requestBody.get('success_url'), 'UTF-8');
        body += '&cancel_url=' + EncodingUtil.urlEncode((String)requestBody.get('cancel_url'), 'UTF-8');
        body += '&mode=payment';
        body += '&line_items[0][price_data][currency]=usd';
        body += '&line_items[0][price_data][product_data][name]=' + EncodingUtil.urlEncode(opp.Name, 'UTF-8');
        body += '&line_items[0][price_data][unit_amount]=' + Integer.valueOf(opp.Amount * 100);
        body += '&line_items[0][quantity]=1';

        req.setBody(body);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String url = (String)response.get('url');

            // Create Payment record
            Payment__c payment = new Payment__c(
                Opportunity__c = opp.Id,
                Payment_Link_Full__c = url,
                Amount__c = opp.Amount,
                Payment_Status__c = 'Pending'
            );
            insert payment;

            // Update Opportunity
            opp.Payment_Status__c = 'Pending';
            update opp;

            return url;
        } else {
            System.debug('Stripe Error: ' + res.getBody());
            throw new AuraHandledException('Failed to create payment link.');
        }
    }
}