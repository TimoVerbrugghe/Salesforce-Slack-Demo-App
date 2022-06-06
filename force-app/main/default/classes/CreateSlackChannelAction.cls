global class CreateSlackChannelAction {
    @InvocableMethod(label='Create Slack Channel')
    global static List<CreateSlackChannelResult> createSlackChannels(List<CreateSlackChannelRequest> requests) {
        List<CreateSlackChannelResult> results = new List<CreateSlackChannelResult>();
        for (CreateSlackChannelRequest request : requests) {
            results.add(createSlackChannel(request));
        }
        return results;
    }

    public static CreateSlackChannelResult createSlackChannel(CreateSlackChannelRequest request) {
        try {
            Id channelId = SlackActions.createSlackChannel(request.channelName);
            CreateSlackChannelResult result = new CreateSlackChannelResult();
            result.status = 'ok';
            result.channelId = channelId;
            return result;  
        } catch(CalloutException e) {
            throw new CreateSlackChannelException('An error has occurred');
        }

    }

    global class CreateSlackChannelRequest {
        @InvocableVariable(required=true)
        global String channelName;
    }  

    global class CreateSlackChannelResult {
        @InvocableVariable
        global String status;

        @InvocableVariable
        global Id channelId;
    }

    class CreateSlackChannelException extends Exception {}

}
