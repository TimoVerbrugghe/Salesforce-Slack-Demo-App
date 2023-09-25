@isTest
public class SlackSetup_Test {
    @isTest static void testGenerateSlackApp() {

        Test.setMock(HttpCalloutMock.class, new GenerateAppHttpCalloutMock()); 
        Test.startTest();
        SlackSetup.generateSlackApp('testToken', 'testSiteName', 'testAppName');
        Test.stopTest();
        Slack_App__c slackApp = [SELECT Id FROM Slack_App__c WHERE Name = 'testAppName'];
        System.assert(slackApp != null);
    }

    public class GenerateAppHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setBody('{ "ok": true, "app_id": "A012ABCD0A0", "credentials": { "client_id": "...", "client_secret": "...", "verification_token": "...", "signing_secret": "..." }, "oauth_authorize_url": "https://slack.com/oauth/v2/authorize?client_id=...&scope=commands,workflow.steps:execute" }');
            response.setStatusCode(200);
            return response; 
        }
    }

    @isTest static void testCreateSlackAppObject() {
        Test.startTest();
        SlackSetup.createSlackAppObject('testAppName', 'https://test.com', 'https://testauth.com', 'testAppId', 'testClientId', 'testClientID');
        Test.stopTest();
    }

    @isTest static void testSendTestMessages() {
        Test.startTest();
        SlackSetup.sendTestMessages();
        Test.stopTest();
    }

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
