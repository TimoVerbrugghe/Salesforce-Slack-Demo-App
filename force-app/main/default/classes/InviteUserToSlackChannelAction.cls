global class InviteUserToSlackChannelAction {
    @InvocableMethod(label='Invite User to Slack Channel')
    global static List<InviteUserToSlackChannelResult> inviteUserToSlackChannels(List<InviteUserToSlackChannelRequest> requests) {
        List<InviteUserToSlackChannelResult> results = new List<InviteUserToSlackChannelResult>();
        for (InviteUserToSlackChannelRequest request : requests) {
            results.add(InviteUserToSlackChannel(request));
        }
        return results;
    }

    public static InviteUserToSlackChannelResult InviteUserToSlackChannel(InviteUserToSlackChannelRequest request) {
        try {
            String channelId = SlackActions.inviteUserToChannelWithSalesforceChannelId(request.slackChannel);
            InviteUserToSlackChannelResult result = new InviteUserToSlackChannelResult();
            result.status = 'ok';
            result.channelId = channelId;
            return result;  
        } catch(CalloutException e) {
            throw new InviteUserToSlackChannelException('An error has occurred');
        }

    }

    global class InviteUserToSlackChannelRequest {
        @InvocableVariable(required=true)
        global Slack_Channel__c slackChannel;
    }  

    global class InviteUserToSlackChannelResult {
        @InvocableVariable
        global String status;

        @InvocableVariable
        global Id channelId;
    }

    class InviteUserToSlackChannelException extends Exception {}

}
