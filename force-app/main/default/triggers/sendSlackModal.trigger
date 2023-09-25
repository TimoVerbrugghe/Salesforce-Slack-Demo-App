trigger sendSlackModal on Slack_Modal__c (after insert) {

    for(Slack_Modal__c slackModal : Trigger.New) {
        SlackActions.sendModalToSlackAsync(slackModal.Id);
    }

}