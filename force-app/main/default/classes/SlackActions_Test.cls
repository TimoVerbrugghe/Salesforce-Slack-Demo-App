@isTest
public class SlackActions_Test {

    @isTest static void testCreateSlackChannel() {
        Slack_App__c slackApp = SlackTestDataFactory.createSlackApp();
        Slack_Channel__c slackChannel = SlackTestDataFactory.createSlackChannel();
        insert slackApp;
        insert slackChannel;

        String slackChannelName = 'Test Channel Name';

        Test.setMock(HttpCalloutMock.class, new SlackHttpCalloutMockCreateChannel()); 
        Test.startTest();
            SlackActions.createSlackChannelAsync(slackChannelName);
        Test.stopTest();
    }

    @isTest static void testSendSlackModal() {
        Slack_App__c slackApp = SlackTestDataFactory.createSlackApp();
        Slack_Channel__c slackChannel = SlackTestDataFactory.createSlackChannel();
        insert slackApp;
        insert slackChannel;

        Test.setMock(HttpCalloutMock.class, new SlackHttpCalloutMock()); 
        Test.startTest();
            Slack_Modal__c slackModal = SlackTestDataFactory.createSlackModal();
            insert slackModal;
        Test.stopTest();
    }

    @isTest static void testSendSlackHome() {
        Slack_App__c slackApp = SlackTestDataFactory.createSlackApp();
        Slack_Channel__c slackChannel = SlackTestDataFactory.createSlackChannel();
        insert slackApp;
        insert slackChannel;

        Test.setMock(HttpCalloutMock.class, new SlackHttpCalloutMock()); 
        Test.startTest();
            Slack_Home__c slackHome = SlackTestDataFactory.createSlackHome();
            insert slackHome;
        Test.stopTest();
    }

   @isTest static void testSendSlackMessageEphemeral() {

    Slack_App__c slackApp = SlackTestDataFactory.createSlackApp();
    Slack_Channel__c slackChannel = SlackTestDataFactory.createSlackChannel();
    insert slackApp;
    insert slackChannel;

    Test.setMock(HttpCalloutMock.class, new SlackHttpCalloutMockEphemeral());   
    Test.startTest();
        Slack_Message__c slackMessage = SlackTestDataFactory.createSlackMessage(slackChannel, true);
        insert slackMessage;
    Test.stopTest();
   }

   @isTest static void testSendSlackMessageWebhook() {
    Slack_App__c slackApp = SlackTestDataFactory.createSlackApp();
    Slack_Channel__c slackChannel = SlackTestDataFactory.createSlackChannel();
    insert slackApp;
    insert slackChannel;

    Test.setMock(HttpCalloutMock.class, new SlackHttpCalloutMock()); 
    Test.startTest();
        Slack_Message__c slackMessage = SlackTestDataFactory.createSlackMessage(slackChannel, false);
        insert slackMessage;
    Test.stopTest();
   }

    public class SlackHttpCalloutMockEphemeral implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "ok": true, "message_ts": "1502210682.580145" }}');
            response.setStatusCode(200);
            return response; 
        }
    }

    public class SlackHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setBody('ok');
            response.setStatusCode(200);
            return response; 
        }
    }

    public class SlackHttpCalloutMockCreateChannel implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "channel": {"name" : "testName", "id" : "testId", "creator" : "creatorId"}, "ok" : true}');
            response.setStatusCode(200);
            return response; 
        }
    }
}