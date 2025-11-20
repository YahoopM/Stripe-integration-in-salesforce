# **Stripe Payment Integration – Quick README**

A lightweight summary of the Stripe–Salesforce integration project.

---

## **1. Problem Summary**

The business needed a way to automatically generate and send payment links from Salesforce Opportunities and track payment status without manual work.

**Issues before:**

* No automatic payment link generation.
* Manual email handling.
* No real-time payment status updates.
* No branded success/cancel pages.

---

## **2. Solution Summary**

A streamlined integration between **Salesforce → Stripe → Experience Cloud** was implemented.

### **Key Features:**

* Generate Stripe Checkout links directly from Opportunity via Agentforce.
* Store link in **Payment__c** object.
* Show link directly inside Agent Chat.
* One-click email to customer.
* Success/Failure pages built using LWC + Experience Cloud.
* Stripe Webhook updates Opportunity and Payment status.

---

## **3. Components Used**

### **Apex:**

* `StripeDirectService` – creates Stripe payment session.
* `Agent_CreatePayment` – returns payment link to Agent.

### **Custom Object:**

**Payment__c** with fields:

* Payment_Link_Full__c
* Amount__c
* Payment_Status__c
* Opportunity__c

### **LWC:**

* `stripePaymentResult` (shared for success/cancel using URL parameters)

### **Experience Cloud Pages:**

* `/success`
* `/cancel`

### **Webhook:**

Stripe → Salesforce endpoint for updating payment status.

---

## **4. End-to-End Flow**

1. Agent clicks *Create Payment Link*.
2. Apex generates Stripe Checkout link.
3. Payment__c record created.
4. Link sent in Agent chat.
5. Agent emails the link to customer.
6. Customer pays → redirected to success/cancel page.
7. Stripe webhook updates status in Salesforce.

---

## **5. Benefits**

* Fully automated payment workflow.
* Real-time status tracking.
* Reduced manual effort.
* Better customer experience.
* Reusable and scalable architecture.

---

## **6. Future Enhancements**

* Refund automation.
* Subscription support.
* Payment reminders.
* Finance dashboards.

---

## **7. Conclusion**

A clean, fast, and automated Stripe–Salesforce integration improving payment operations and customer experience.
