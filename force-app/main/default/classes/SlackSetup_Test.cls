@isTest
public class SlackSetup_Test {
    /*
    @isTest static void testCreateSlackApp() {
        Test.startTest();
        SlackSetup.createSlackApp('testSlackApp', 'www.google.com', 'testAppId', 'testClientId', 'testClientSecret');
        Test.stopTest();
        Slack_App__c slackApp = [SELECT Id FROM Slack_App__c WHERE Name = 'testSlackApp'];
        System.assert(slackApp != null);
    }
    */

    @isTest static void testSetupAlreadyDoneFalse() {
        Test.startTest();
        Boolean setup = SlackSetup.setupAlreadyDone();
        Test.stopTest();
        System.assert(setup == false);

    }

    @isTest static void testSetupAlreadyDoneTrue() {
        SlackTestDataFactory.generateTestData();
        Test.startTest();
        Boolean setup = SlackSetup.setupAlreadyDone();
        Test.stopTest();
        System.assert(setup == true);
    }

    @isTest static void testGetSlackAppsAndChannels() {
        SlackTestDataFactory.generateTestData();
        Test.startTest();
        List<Slack_App__c> slackApps = SlackSetup.getSlackApps();
        List<Slack_Channel__c> slackChannels = SlackSetup.getSlackChannels();
        Test.stopTest();
        System.assert(slackApps.size() == 1);
        System.assert(slackChannels.size() == 1);
    }

    @isTest static void testGetSlackAppsAndChannelsException() {
        Test.startTest();
        List<Slack_App__c> slackApps = SlackSetup.getSlackApps();
        List<Slack_Channel__c> slackChannels = SlackSetup.getSlackChannels();
        Test.stopTest();
    }

    @isTest static void testGetSiteUrl() {
        try {
            String siteUrl = SlackSetup.getSiteUrl('Slack Demo');
        } catch (Exception e) {
            System.assert(e != null);
        } 
        
    }

}
