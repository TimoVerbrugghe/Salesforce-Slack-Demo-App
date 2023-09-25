trigger sendSlackHome on Slack_Home__c (after insert) {

    for(Slack_Home__c slackHome : Trigger.New) {
        SlackActions.sendHomeToSlackAsync(slackHome.Id);
    }

}