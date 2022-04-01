@isTest
public class SlackParseRequest_Test {
    @isTest static void testParseSlackRequestHTTPBadResponse() {
        Slack_App__c slackApp = SlackTestDataFactory.createSlackApp();
        Slack_Channel__c slackChannel = SlackTestDataFactory.createSlackChannel();
        insert slackApp;
        insert slackChannel;

        RestRequest request = new RestRequest();
        String orgUrl = System.URL.getOrgDomainUrl().toExternalForm();
        request.requestUri = orgUrl + 'services/apexrest/slack/parseSlackRequestHttp';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.addParameter('payload', '{"test" : "BADJSON"}');
        RestContext.request = request;
        SlackParseRequest.parseSlackRequestHttp();
    }  

    @isTest static void testParseSlackRequestHTTPGoodResponse() {
        Slack_App__c slackApp = SlackTestDataFactory.createSlackApp();
        Slack_Channel__c slackChannel = SlackTestDataFactory.createSlackChannel();
        insert slackApp;
        insert slackChannel;

        RestRequest request = new RestRequest();
        String orgUrl = System.URL.getOrgDomainUrl().toExternalForm();
        request.requestUri = orgUrl + 'services/apexrest/slack/parseSlackRequestHttp';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.addParameter('payload', '{ "type": "block_actions", "team": { "id": "T9TK3CUKW", "domain": "example" }, "user": { "id": "UA8RXUSPL", "username": "jtorrance", "team_id": "T9TK3CUKW" }, "api_app_id": "AABA1ABCD", "token": "9s8d9as89d8as9d8as989", "container": { "type": "message_attachment", "message_ts": "1548261231.000200", "attachment_id": 1, "channel_id": "CBR2V3XEX", "is_ephemeral": false, "is_app_unfurl": false }, "trigger_id": "12321423423.333649436676.d8c1bb837935619ccad0f624c448ffb3", "channel": { "id": "CBR2V3XEX", "name": "review-updates" }, "message": { "bot_id": "BAH5CA16Z", "type": "message", "text": "This content cannot be displayed.", "user": "UAJ2RU415", "ts": "1548261231.000200", "blocks": [ { "type": "section", "block_id": "8ZG", "text": { "type": "mrkdwn", "text": "A stack of blocks for the simple sample Block Kit Home tab.", "verbatim": false } }, { "type": "actions", "block_id": "7fhg", "elements": [ { "type": "button", "action_id": "XRX", "text": { "type": "plain_text", "text": "Action A", "emoji": true } }, { "type": "button", "action_id": "GFBew", "text": { "type": "plain_text", "text": "Action B", "emoji": true } } ] }, { "type": "section", "block_id": "6evU", "text": { "type": "mrkdwn", "text": "And now its slightly more complex.", "verbatim": false } } ] }, "response_url": "https://hooks.slack.com/actions/AABA1ABCD/1232321423432/D09sSasdasdAS9091209", "actions": [ { "action_id": "WaXA", "block_id": "=qXel", "text": { "type": "plain_text", "text": "View", "emoji": true }, "value": "click_me_123", "type": "button", "action_ts": "1548426417.840180" } ] }');
        RestContext.request = request;
        SlackParseRequest.parseSlackRequestHttp();
    }  

    @isTest static void testParseSlackAuthHTTP() {
        Slack_App__c slackApp = SlackTestDataFactory.createSlackApp();
        Slack_Channel__c slackChannel = SlackTestDataFactory.createSlackChannel();
        insert slackApp;
        insert slackChannel;

        // Faking the response when parseSlackAuthHttp does its own HTTP request back
        Test.setMock(HttpCalloutMock.class, new SlackAuthResponseCalloutMock());

        Test.startTest();
            // faking the first request that comes in from slack, which has the access token
            RestRequest request = new RestRequest();
            String orgUrl = System.URL.getOrgDomainUrl().toExternalForm();
            request.requestUri = orgUrl + 'services/apexrest/slack/parseSlackAuthHttp';
            request.httpMethod = 'POST';
            request.addParameter('code', 'testcode');
            RestContext.request = request;

            RestResponse res = new RestResponse();
            RestContext.response = res;
            SlackParseRequest.parseSlackAuthHttp();
        Test.stopTest();
    }  

    public class SlackAuthResponseCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            String json = '{ "ok": true, "access_token": "xoxb-17653672481-19874698323-pdFZKVeTuE8sk7oOcBrzbqgy", "token_type": "bot", "scope": "commands,incoming-webhook", "bot_user_id": "U0KRQLJ9H", "app_id": "A0KRD7HC3", "team": { "name": "Slack Softball Team", "id": "T9TK3CUKW" }, "enterprise": { "name": "slack-sports", "id": "E12345678" }, "authed_user": { "id": "U1234", "scope": "chat:write", "access_token": "xoxp-1234", "token_type": "user" }, "incoming_webhook": { "channel": "#testchannel", "channel_id": "C05002EAE", "configuration_url": "https://workspacename.slack.com/services/BXXXXX", "url": "https://hooks.slack.com/TXXXXX/BXXXXX/XXXXXXXXXX" } }';
            response.setBody(json);
            response.setStatusCode(200);
            return response; 
        }
    }
}
