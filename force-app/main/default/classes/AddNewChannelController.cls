public with sharing class AddNewChannelController {

    @AuraEnabled(cacheable=true)
    public static Slack_App__c getSlackApp(){
        try {
            return [SELECT Authentication_URL__c FROM Slack_App__c LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}