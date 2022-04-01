trigger sendSlackMessage on Slack_Message__c (after insert) {

    for(Slack_Message__c slackMessage : Trigger.New) {
        SlackActions.sendMessageToSlackAsync(slackMessage.Id);
    }

}