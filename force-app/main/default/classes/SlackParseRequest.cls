@RestResource(urlMapping='/SlackDemoApp/*')
global class SlackParseRequest {

    @httpPost
    global static void parseSlackRequestHttp() {

        String jsonInput = RestContext.request.params.get('payload');

        try {
        // Parse JSON received from Slack
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);

            // Get button press info
            List<Object> actions = (List<Object>)parsedJson.get('actions');
            Map<String, Object> container = (Map<String, Object>)parsedJson.container;
            Map<String, Object> user = (Map<String, Object>)parsedJson.user;
            Map<String, Object> firstAction = (Map<String, Object>)actions[0];
            
            // Create a new Slack Response object & Platform Event
            Slack_Response__c slackResponse = new Slack_Response__c(
                Action_ID__c = (String) firstAction.get('action_id'),
                Value__c = (String) firstAction.get('value'),
                Trigger_ID__c = (String) parsedJson.get('trigger_id'),
                Channel_ID__c = (String) container.get('channel_id'),
                User_ID__c = (String) user.get('id')
            );

            Slack_Button_Clicked__e slackButtonClickedEvent = new Slack_Button_Clicked__e(
                Action_ID__c = (String) firstAction.get('action_id'),
                Value__c = (String) firstAction.get('value'),
                Trigger_ID__c = (String) parsedJson.get('trigger_id'),
                Channel_ID__c = (String) container.get('channel_id'),
                User_ID__c = (String) user.get('id')          
            );

            // Try to add response URL (will only be there if action came from a message)
            if(parsedJson.containsKey('response_url')) {
                slackResponse.Response_URL__c = (String) parsedJson.get('response_url');
                slackButtonClickedEvent.Response_URL__c = (String) parsedJson.get('response_url');
            }

            // Try to add Thread ID (will only be there if action came from a message)
            if(parsedJson.containsKey('message')) {
                Map<String, Object> message = (Map<String, Object>)parsedJson.get('message');
                slackResponse.Thread_ID__c = (String) message.get('ts');
                slackButtonClickedEvent.Thread_ID__c = (String) message.get('ts');
            }

            // Try to add channel ID (will only be there if action came from a message)
            if(parsedJson.containsKey('message')) {
                Map<String, Object> message = (Map<String, Object>)parsedJson.get('message');
                slackResponse.Thread_ID__c = (String) message.get('ts');
                slackButtonClickedEvent.Thread_ID__c = (String) message.get('ts');
            }

            // Insert slackResponse object and Platform Event
            insert slackResponse;
            Database.SaveResult sr = EventBus.publish(slackButtonClickedEvent);
        
        } catch (Exception e) {
            // Create Invalid Response Slack Response object
            Slack_Response__c slackResponse = new Slack_Response__c(
                Action_ID__c = 'INVALID JSON - PARSE ERROR',
                Response_URL__c = '',
                Value__c = 'Could not figure out what Slack sent me (Could not parse the JSON)'
            );
            insert slackResponse;
        }
        
    }
    

    // Method to receive oauth code back from user who signs into Slack
    @httpGet
    global static void parseSlackAuthHttp() {
        RestRequest req = RestContext.request;
        String authCode = req.params.get('code');
        Slack_App__c slackApp = [SELECT Client_ID__c, Client_Secret__c, Site_Url__c FROM Slack_App__c LIMIT 1];

        String clientId = slackApp.Client_ID__c;
        String clientSecret = slackApp.Client_Secret__c;
        String siteUrl = slackApp.Site_Url__c;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndPoint('https://slack.com/api/oauth.v2.access');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('code=' + authCode + '&client_id=' + clientId + '&client_secret=' + clientSecret + '&redirect_uri=' + siteUrl + '/services/apexrest/SlackDemoApp/parseSlackAuthHttp');
        HttpResponse response = http.send(request);

        // Parse JSON received from Slack
        String jsonInput = response.getBody();
        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);

        Map<String, Object> incomingwebhook = (Map<String, Object>)parsedJson.get('incoming_webhook');
        Map<String, Object> authedUser = (Map<String, Object>)parsedJson.get('authed_user');

        // Creating new Slack Channel Record
        Slack_Channel__c slackChannel = new Slack_Channel__c(
            Endpoint_URL__c = (String) incomingwebhook.get('url'),
            Name = (String) incomingwebhook.get('channel'),
            Access_Token__c = (String) parsedJson.get('access_token'),
            Channel_ID__c = (String) incomingwebhook.get('channel_id'),
            User_ID__c = (String) authedUser.get('id')
        );

        // Updating User ID & Access Token in the Slack App Record
        slackApp.Access_Token__c = (String) parsedJson.get('access_token');
        slackApp.User_ID__c = (String) authedUser.get('id');

        // Invite bot to the channel so that ephemeral messages work
        Http http2 = new Http();
        HttpRequest request2 = new HttpRequest();
        request2.setEndPoint('https://slack.com/api/conversations.join');
        request2.setMethod('POST');
        request2.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request2.setHeader('Authorization', 'Bearer ' + slackChannel.Access_Token__c);
        request2.setBody('channel=' + slackChannel.Channel_ID__c);
        HttpResponse response2 = http2.send(request2);

        // Committing changes to the database
        upsert slackChannel Endpoint_URL__c;
        upsert slackApp;

        // Redirect back to homescreen
        String orgUrl = System.URL.getOrgDomainUrl().toExternalForm();

        RestContext.response.statusCode = 301;
        RestContext.response.addHeader('Location', orgUrl + '/lightning/n/Slack_Demo_Home');
        RestContext.response.addHeader('http-equiv','refresh');
    }

}