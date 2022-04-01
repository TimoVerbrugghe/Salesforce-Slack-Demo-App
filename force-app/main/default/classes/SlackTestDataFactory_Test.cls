@isTest
public class SlackTestDataFactory_Test {
    @isTest static void testSlackTestDataFactory() {
        Test.startTest();
        SlackTestDataFactory.generateTestData();
        Slack_Channel__c slackChannel = SlackTestDataFactory.createSlackChannel();
        Slack_Message__c slackMessage = SlackTestDataFactory.createSlackMessage(slackChannel, false);
        Test.stopTest();
        System.assert(slackChannel != null);
        System.assert(slackMessage != null);
    }
}
