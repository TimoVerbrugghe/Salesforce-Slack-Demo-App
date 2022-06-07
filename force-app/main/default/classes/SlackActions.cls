public class SlackActions {

    // Creating a channel
    @future(callout=true)
    public static void createSlackChannelAsync(String channelName) {
        createSlackChannel(channelName);
    }

    public static Id createSlackChannel(String channelName) {
        // Select the first (and presumably only SlackApp available)
        Slack_App__c slackApp = [SELECT Access_Token__c FROM Slack_App__c LIMIT 1];

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://slack.com/api/conversations.create');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + slackApp.Access_Token__c);
        String message = '{"name" : "' + channelName + '"}';
        request.setBody(message);

        try {
            HttpResponse res = http.send(request);
            System.debug(res.getBody());

            // Parse JSON received from Slack
            String jsonInput = res.getBody();
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
            Map<String, Object> channel = (Map<String, Object>)parsedJson.get('channel');
  
            // Creating new Slack Channel Record
            timoverbrugghe__Slack_Channel__c slackChannel = new timoverbrugghe__Slack_Channel__c(
                Name = (String) channel.get('name'),
                timoverbrugghe__Channel_ID__c = (String) channel.get('id'),
                timoverbrugghe__User_ID__c = (String) channel.get('creator')
            );

            // Invite user into the channel
            inviteUserToChannel(slackChannel.timoverbrugghe__Channel_ID__c);

            insert slackChannel;

            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                return slackChannel.Id;
            } else {
                return 'The request worked, but we got a bad status code back, the status code is ' + res.getStatusCode();
            }
        }
        catch (CalloutException e) {
            return e.getMessage();
        }
    }

    public static String inviteUserToChannel(String slackChannelId) {
        // Select the first (and presumably only SlackApp available)
        timoverbrugghe__Slack_App__c slackApp = [SELECT timoverbrugghe__Access_Token__c, timoverbrugghe__User_ID__c FROM timoverbrugghe__Slack_App__c LIMIT 1];

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://slack.com/api/conversations.invite');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + slackApp.timoverbrugghe__Access_Token__c);
        String message = '{"channel" : "' + slackChannelId + '", "users": ["' + slackApp.timoverbrugghe__User_ID__c + '"]}';
        request.setBody(message);

        try {
            HttpResponse res = http.send(request);
            System.debug(res.getBody());
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                return 'User added Succesfully';
            } else {
                return 'The request worked, but we got a bad status code back, the status code is ' + res.getStatusCode();
            }
        }
        catch (CalloutException e) {
            return e.getMessage();
        }
    }

    // Updating Home
    @future(callout=true)
    public static void sendHomeToSlackAsync(Id slackHomeId) {
        sendHomeToSlack(slackHomeId);
    }

    public static String sendHomeToSlack(Id slackHomeId) {
        Slack_Home__c slackHome = [SELECT Home__c FROM Slack_Home__c WHERE Id = :slackHomeId];

        // Select the first (and presumably only SlackApp available)
        Slack_App__c slackApp = [SELECT Access_Token__c, User_ID__c FROM Slack_App__c LIMIT 1];

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://slack.com/api/views.publish');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + slackApp.Access_Token__c);
        String message = '{"user_id" : "' + slackApp.User_ID__c + '", "view" : ' + slackHome.Home__c + '}';
        request.setBody(message);

        try {
            HttpResponse res = http.send(request);
            System.debug(res.getBody());
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                return 'Message Sent Succesfully';
            } else {
                return 'The request worked, but we got a bad status code back, the status code is ' + res.getStatusCode();
            }
        }
        catch (CalloutException e) {
            return e.getMessage();
        }

    }

    // Sending Modals
    @future(callout=true)
    public static void sendModalToSlackAsync(Id slackModalId) {
        sendModalToSlack(slackModalId);
    }


    public static String sendModalToSlack(Id slackModalId) {
        Slack_Modal__c slackModal = [SELECT Modal__c, Trigger_ID__c FROM Slack_Modal__c WHERE Id = :slackModalId];
        Slack_App__c slackApp = [SELECT Access_Token__c, User_ID__c FROM Slack_App__c LIMIT 1];
        String modal = slackModal.Modal__c;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://slack.com/api/views.open');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + slackApp.Access_Token__c);
        String message = '{"trigger_id" : "' + slackModal.Trigger_ID__c + '", "view" : ' + slackModal.Modal__c + '}';
        request.setBody(message);

        try {
            HttpResponse res = http.send(request);
            System.debug(res.getBody());
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                return 'Message Sent Succesfully';
            } else {
                return 'The request worked, but we got a bad status code back, the status code is ' + res.getStatusCode();
            }
        }
        catch (CalloutException e) {
            return e.getMessage();
        }

    }

    // Sending Messages

    @future(callout=true)
    public static void sendMessageToSlackAsync(Id slackMessageId) {
        sendMessageToSlack(slackMessageId);
    }

    public static String sendMessageToSlack(Id slackMessageId) {
        Slack_App__c slackApp = [SELECT Access_Token__c, User_ID__c FROM Slack_App__c LIMIT 1];
        Slack_Message__c slackMessage = [SELECT Message__c, Slack_Channel__c, Only_visible_to_you__c, Thread_ID__c FROM Slack_Message__c WHERE Id = :slackMessageId];
        Slack_Channel__c slackChannel = [SELECT Channel_ID__c FROM Slack_Channel__c WHERE Id = :slackMessage.Slack_Channel__c];
        // String endpoint = slackChannel.Endpoint_URL__c;

        String endpoint = 'https://slack.com/api/chat.postmessage';
        String newMessage = slackMessage.Message__c;

        String message = slackMessage.Message__c;

        // Check if it's a reply to a threads
        if(slackMessage.Thread_ID__c != null) {
            String addToMessage = '"thread_ts" : "' + slackMessage.Thread_ID__c + '",';
            message = message.substring(0,1) + addToMessage + message.substring(1);
        }

        // Set necessary message & endpoint based on whether it's ephemeral message or not
        if(slackMessage.Only_visible_to_you__c == false) {
            endpoint = 'https://slack.com/api/chat.postMessage';
            String addToMessage = '"channel" : "' + slackChannel.Channel_ID__c + '",';
            newMessage = message.substring(0,1) + addToMessage + message.substring(1);
        } else {
            endpoint = 'https://slack.com/api/chat.postEphemeral';
            String addToMessage = '"user": "' + slackApp.User_ID__c + '", "channel" : "' + slackChannel.Channel_ID__c + '",';
            newMessage = message.substring(0,1) + addToMessage + message.substring(1);
        }

        // Send Message
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + slackApp.Access_Token__c);
            request.setBody(newMessage);

            try {
                HttpResponse res = http.send(request);
                System.debug(res.getBody());
                if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                    return 'Message Sent Succesfully';
                } else {
                    return 'The request worked, but we got a bad status code back, the status code is ' + res.getStatusCode();
                }
            }
            catch (CalloutException e) {
                return e.getMessage();
            }
        }
}