global class GetSalesforceURL {
    @InvocableMethod(label='Get Salesforce URL' description='Gives you the URL to your salesforce org, in the format https://xxxx.lightning.force.com, so you can use it to build actions in Slack Messages')
    global static List<String> getSalesforceURLFlowAction() {
        List<String> results = new List<String>();
        String SalesforceURL = URL.getSalesforceBaseUrl().toExternalForm();
        results.add(SalesforceURL);
        return results;
    }

    @AuraEnabled(cacheable=true)
    global static String getSalesforceURL() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
}
