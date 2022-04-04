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
            Map<String, Object> firstAction = (Map<String, Object>)actions[0];
            
            // Create a new Slack Response object & Platform Event
            timoverbrugghe__Slack_Response__c slackResponse = new timoverbrugghe__Slack_Response__c(
                timoverbrugghe__Action_ID__c = (String) firstAction.get('action_id'),
                timoverbrugghe__Value__c = (String) firstAction.get('value'),
                timoverbrugghe__Trigger_ID__c = (String) parsedJson.get('trigger_id')
            );

            timoverbrugghe__Slack_Button_Clicked__e slackButtonClickedEvent = new timoverbrugghe__Slack_Button_Clicked__e(
                timoverbrugghe__Action_ID__c = (String) firstAction.get('action_id'),
                timoverbrugghe__Value__c = (String) firstAction.get('value'),
                timoverbrugghe__Trigger_ID__c = (String) parsedJson.get('trigger_id')          
            );

            // Try to add response URL (will only be there if action came from a message)
            if(parsedJson.containsKey('response_url')) {
                slackResponse.timoverbrugghe__Response_URL__c = (String) parsedJson.get('response_url');
                slackButtonClickedEvent.timoverbrugghe__Response_URL__c = (String) parsedJson.get('response_url');
            }

            // Try to add Thread ID (will only be there if action came from a message)
            if(parsedJson.containsKey('message')) {
                Map<String, Object> message = (Map<String, Object>)parsedJson.get('message');
                slackResponse.timoverbrugghe__Thread_ID__c = (String) message.get('ts');
                slackButtonClickedEvent.timoverbrugghe__Thread_ID__c = (String) message.get('ts');
            }

            // Insert slackResponse object and Platform Event
            insert slackResponse;
            Database.SaveResult sr = EventBus.publish(slackButtonClickedEvent);
        
        } catch (Exception e) {
            // Create Invalid Response Slack Response object
            timoverbrugghe__Slack_Response__c slackResponse = new timoverbrugghe__Slack_Response__c(
                timoverbrugghe__Action_ID__c = 'INVALID JSON - PARSE ERROR',
                timoverbrugghe__Response_URL__c = '',
                timoverbrugghe__Value__c = 'Could not figure out what Slack sent me (Could not parse the JSON)'
            );
            insert slackResponse;
        }
        
    }
    

    // Method to receive oauth code back from user who signs into Slack
    @httpGet
    global static void parseSlackAuthHttp() {
        RestRequest req = RestContext.request;
        String authCode = req.params.get('code');
        timoverbrugghe__Slack_App__c slackApp = [SELECT timoverbrugghe__Client_ID__c, timoverbrugghe__Client_Secret__c, timoverbrugghe__Site_Url__c FROM timoverbrugghe__Slack_App__c LIMIT 1];

        String clientId = slackApp.timoverbrugghe__Client_ID__c;
        String clientSecret = slackApp.timoverbrugghe__Client_Secret__c;
        String siteUrl = slackApp.timoverbrugghe__Site_Url__c;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndPoint('https://slack.com/api/oauth.v2.access');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('code=' + authCode + '&client_id=' + clientId + '&client_secret=' + clientSecret + '&redirect_uri=' + siteUrl + '/services/apexrest/timoverbrugghe/SlackDemoApp/parseSlackAuthHttp');
        HttpResponse response = http.send(request);

        // Parse JSON received from Slack
        String jsonInput = response.getBody();
        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);

        Map<String, Object> incomingwebhook = (Map<String, Object>)parsedJson.get('incoming_webhook');
        Map<String, Object> authedUser = (Map<String, Object>)parsedJson.get('authed_user');

        // Creating new Slack Channel Record
        timoverbrugghe__Slack_Channel__c slackChannel = new timoverbrugghe__Slack_Channel__c(
            timoverbrugghe__Endpoint_URL__c = (String) incomingwebhook.get('url'),
            Name = (String) incomingwebhook.get('channel'),
            timoverbrugghe__Access_Token__c = (String) parsedJson.get('access_token'),
            timoverbrugghe__Channel_ID__c = (String) incomingwebhook.get('channel_id'),
            timoverbrugghe__User_ID__c = (String) authedUser.get('id')
        );
        upsert slackChannel timoverbrugghe__Endpoint_URL__c;

        // Updating User ID & Access Token in the Slack App Record
        slackApp.timoverbrugghe__Access_Token__c = (String) parsedJson.get('access_token');
        slackApp.timoverbrugghe__User_ID__c = (String) authedUser.get('id');
        upsert slackApp;

        // Redirect back to homescreen
        String orgUrl = System.URL.getOrgDomainUrl().toExternalForm();

        RestContext.response.statusCode = 301;
        RestContext.response.addHeader('Location', orgUrl + '/lightning/n/timoverbrugghe__Slack_Demo_Home');
        RestContext.response.addHeader('http-equiv','refresh');

    }

}