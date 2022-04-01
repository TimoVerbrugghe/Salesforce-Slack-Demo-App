public class SlackActions {
    
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
        Slack_Message__c slackMessage = [SELECT Message__c, Slack_Channel__c, Only_visible_to_you__c, Thread_ID__c FROM Slack_Message__c WHERE Id = :slackMessageId];
        Slack_Channel__c slackChannel = [SELECT Endpoint_URL__c, Access_Token__c, User_ID__c, Channel_ID__c FROM Slack_Channel__c WHERE Id = :slackMessage.Slack_Channel__c];
        String endpoint = slackChannel.Endpoint_URL__c;
        String message = slackMessage.Message__c;

        // Check if it's a reply to a threads
        if(slackMessage.Thread_ID__c != null) {
            String addToMessage = '"thread_ts" : "' + slackMessage.Thread_ID__c + '",';
            message = message.substring(0,1) + addToMessage + message.substring(1);
        }

        // Indien geen ephemeral message
        if(slackMessage.Only_visible_to_you__c == false) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(message);
            System.debug(message);

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

        // Indien wel ephemeral message
        } else {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://slack.com/api/chat.postEphemeral');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + slackChannel.Access_Token__c);
            String addToMessage = '"user": "' + slackChannel.User_ID__c + '", "channel" : "' + slackChannel.Channel_ID__c + '",';
            String newMessage = message.substring(0,1) + addToMessage + message.substring(1);

            request.setBody(newMessage);

            try {
                HttpResponse res = http.send(request);
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
}