@isTest
public class AddNewChannelController_Test {
   @isTest static void testAddNewChannelController() {
        SlackTestDataFactory.generateTestData();
        Test.startTest();
        Slack_App__c slackApp = AddNewChannelController.getSlackApp();
        Test.stopTest();
   }
}
