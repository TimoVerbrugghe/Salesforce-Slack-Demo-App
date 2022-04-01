@RestResource(urlMapping='/SlackDemoApp/*')
global class SlackParseRequest {

    @httpPost
    global static void parseSlackRequestHttp() {
        // get payload parameter because I don't know what Slack is thinking anymore at this point, like wtf Slack, just post a simple json in a body.
        // This is because slack sends a x-www-form-urlencoded package instead of a json package. I thought that package would be part of the body, but it's not, it's in the HTTP parameters
        // So this isn't needed
        	// String jsonString = EncodingUtil.urlDecode(RestContext.request.requestBody.toString(), 'UTF-8');
        	// response = SlackResponseParser.parse(jsonString.substringAfter('='));

        String json = RestContext.request.params.get('payload');
        
        
        
        // Try to parse JSON received from Slack, if possible to parse, send platform & slack response event.
        try {
            timoverbrugghe.SlackButtonResponseParser response = new timoverbrugghe.SlackButtonResponseParser();
            response = timoverbrugghe.SlackButtonResponseParser.parse(json);

            // Create a new Slack Response object
            timoverbrugghe__Slack_Response__c slackResponse = new timoverbrugghe__Slack_Response__c(
                timoverbrugghe__Action_ID__c = response.actions[0].action_id,
                timoverbrugghe__Response_URL__c = response.response_url,
                timoverbrugghe__Value__c = response.actions[0].value,
                timoverbrugghe__Trigger_ID__c = response.trigger_id
            );

            // Create new platform event
            timoverbrugghe__Slack_Button_Clicked__e slackButtonClickedEvent = new timoverbrugghe__Slack_Button_Clicked__e(
                timoverbrugghe__Action_ID__c = response.actions[0].action_id,
                timoverbrugghe__Response_URL__c = response.response_url,
                timoverbrugghe__Value__c = response.actions[0].value,
                timoverbrugghe__Trigger_ID__c = response.trigger_id            
            );

            // If thread ID exists (because it doesn't if it's a reply on an ephemeral message) add it as well to the responses.
            if (response.message.ts != null) {
                slackResponse.timoverbrugghe__Thread_ID__c = response.message.ts;
                slackButtonClickedEvent.timoverbrugghe__Thread_ID__c = response.message.ts;
            }

            // Call method to publish event & create SlackResponse record
            insert slackResponse;
            Database.SaveResult sr = EventBus.publish(slackButtonClickedEvent);

        // If unable to parse, create slack response event with INVALID - PARSE_ERROR value
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

        // Parsing response for the access token and creating Slack Channel record in Salesforce
        timoverbrugghe.SlackAuthResponseParser slackResponse = new timoverbrugghe.SlackAuthResponseParser();
        slackResponse = SlackAuthResponseParser.parse(response.getBody());

        // Creating new Slack Channel Record
        timoverbrugghe__Slack_Channel__c slackChannel = new timoverbrugghe__Slack_Channel__c(
            timoverbrugghe__Endpoint_URL__c = slackResponse.incoming_webhook.url,
            Name = slackResponse.incoming_webhook.channel,
            timoverbrugghe__Access_Token__c = slackResponse.access_token,
            timoverbrugghe__Channel_ID__c = slackResponse.incoming_webhook.channel_id,
            timoverbrugghe__User_ID__c = slackResponse.authed_user.id
        );
        upsert slackChannel timoverbrugghe__Endpoint_URL__c;

        // Updating User ID & Access Token in the Slack App Record
        slackApp.timoverbrugghe__Access_Token__c = slackResponse.access_token;
        slackApp.timoverbrugghe__User_ID__c = slackResponse.authed_user.id;
        upsert slackApp;

        // Redirect back to homescreen
        String orgUrl = System.URL.getOrgDomainUrl().toExternalForm();

        RestContext.response.statusCode = 301;
        RestContext.response.addHeader('Location', orgUrl + '/lightning/n/timoverbrugghe__Slack_Demo_Home');
        RestContext.response.addHeader('http-equiv','refresh');


    }

}