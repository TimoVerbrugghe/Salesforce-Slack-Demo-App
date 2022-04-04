public class SlackTestDataFactory {

    public static void generateTestData() {
        Slack_App__c slackApp = createSlackApp();
        Slack_Channel__c slackChannel = createSlackChannel();
        insert slackApp;
        insert slackChannel;
    }

    public static Slack_App__c createSlackApp() {
        Slack_App__c slackApp = new Slack_App__c(
            Name = 'testName',
            Site_URL__c = 'testUrl',
            App_ID__c = 'testAppId',
            Client_ID__c = 'clientId',
            Client_Secret__c = 'clientSecret'
        );
        
        return slackApp;
    }

    public static Slack_Channel__c createSlackChannel() {
        Slack_Channel__c slackChannel = new Slack_Channel__c(
         Name = 'testChannel',
         Endpoint_URL__c = 'testEndpoint',
         Access_Token__c = 'testAccessToken'   
        );

        return slackChannel;
    }

    public static Slack_Message__c createSlackMessage(Slack_Channel__c slackChannel, Boolean ephemeralMessage) {
        Slack_Message__c slackMessage = new Slack_Message__c(
            Message__c ='{ "blocks": [ { "type": "section", "text": { "type": "mrkdwn", "text": "Test Message" } } ] }',
            Slack_Channel__c = slackChannel.Id,
            Thread_ID__c = 'test',
            Only_visible_to_you__c = ephemeralMessage
        );
        return slackMessage;
    }

    public static Slack_Modal__c createSlackModal() {
        Slack_Modal__c slackModal = new Slack_Modal__c(
            Modal__c = '',
            Trigger_ID__c = 'test'
        );
        return slackModal;
    }

    public static Slack_Home__c createSlackHome() {
        Slack_Home__c slackHome = new Slack_Home__c(
            Home__c = ''
        );
        return slackHome;
    }

}
