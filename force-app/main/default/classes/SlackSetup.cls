public class SlackSetup {

    @AuraEnabled
    public static Slack_App__c generateSlackApp(String token, String siteName, String appName){
        try {
            // Getting Site URL
            String siteUrl = getSiteUrl(siteName);           
            String redirectUrl = siteUrl + '/services/apexrest/SlackDemoApp/parseSlackAuthHttp';
            String requestUrl = siteUrl + '/services/apexrest/SlackDemoApp/parseSlackRequestHttp';
            String botFeatures = '"chat:write", "incoming-webhook", "channels:join", "channels:manage", "users:read.email", "users:read"';

            // Generating manifest
            String manifest = '{ "display_information": { "name": "' + appName + '" }, "features": { "app_home": { "home_tab_enabled": true, "messages_tab_enabled": false, "messages_tab_read_only_enabled": true }, "bot_user": { "display_name": "' + appName + '", "always_online": false } }, "oauth_config": { "redirect_urls": [ "' + redirectUrl + '" ], "scopes": { "bot": [ ' + botFeatures + ' ] } }, "settings": { "interactivity": { "is_enabled": true, "request_url": "' + requestUrl + '" }, "org_deploy_enabled": false, "socket_mode_enabled": false, "token_rotation_enabled": false } }';

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndPoint('https://slack.com/api/apps.manifest.create');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization', 'Bearer ' + token);
            request.setBody('manifest=' + manifest);
            HttpResponse response = http.send(request);

            SlackGenerateAppResponseParser generatedApp = new SlackGenerateAppResponseParser();
            generatedApp = SlackGenerateAppResponseParser.parse(response.getBody());

            // Delete all previously created Slack Apps - This package currently only supports having 1 slack app at a time
            deleteAllSlackApps();

            Slack_App__c slackApp = createSlackAppObject(appName, siteUrl, generatedApp.oauth_authorize_url + '&request_uri=' + redirectUrl, generatedApp.app_id, generatedApp.credentials.client_id, generatedApp.credentials.client_secret);

            return slackApp;            

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void deleteAllSlackApps() {
        Slack_App__c[] appsToDelete = [select Id FROM Slack_App__c];
        delete appsToDelete;
    }

    public static Slack_App__c createSlackAppObject(String name, String siteUrl, String authUrl, String appId, String clientId, String clientSecret) {
        try {
            Slack_App__c slackApp = new Slack_App__c(
                Name = name,
                Authentication_URL__c = authUrl,
                Site_URL__c = siteUrl,
                App_ID__c = appId,
                Client_ID__c = clientId,
                Client_Secret__c = clientSecret
            );
            upsert slackApp App_ID__c;

            return slackApp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String sendTestMessages(){
        try {
            String orgUrl = URL.getSalesforceBaseUrl().toExternalForm();
            String currentDate = DateTime.now().format('yyyy-MM-dd');
            String testMessage = '{ "blocks": [ { "type": "section", "text": { "type": "mrkdwn", "text": "Hi :wave:! This is a test message coming from the Slack Demo App :slack:" } }, { "type": "section", "text": { "type": "mrkdwn", "text": "This means that you have succesfully linked :slack: and your :salesforce: org! You are ready to build some amazing demos now!" } }, { "type": "section", "text": { "type": "mrkdwn", "text": "Below is some information for your reference" } }, { "type": "section", "fields": [ { "type": "mrkdwn", "text": "*Date sent:*\n' + currentDate + '" }, { "type": "mrkdwn", "text": "*Org URL:*\n'+ orgUrl +'" } ] }, { "type": "section", "text": { "type": "mrkdwn", "text": "You can now also test out receiving responses from Slack by clicking on any of the buttons below :point_down:. When you click on the button below, a new tab will open with your :salesforce: org. This will also create a Platform event & Slack Response record." } }, { "type": "actions", "elements": [ { "type": "button", "url": "' + orgUrl + '", "text": { "type": "plain_text", "emoji": true, "text": ":salesforce: View Slack Demo App" }, "value": "GoToSlackDemoApp", "action_id": "GoToSlackDemoApp" } ] } ] }';
            
            List<Slack_Message__c> messages = new List<Slack_Message__c>();
            
            for (Slack_Channel__c channel : getSlackChannels()) {
                Slack_Message__c message = new Slack_Message__c(
                    Message__c = testMessage,
                    Slack_Channel__c = channel.Id
                );
                messages.add(message);
            }

            insert messages;
            return 'ok';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean setupAlreadyDone(){
        try {
            List<Slack_Channel__c> slackchannels = [SELECT Id FROM Slack_Channel__c];
            if(slackchannels.size() == 0) {
                return false;
            } else {
                return true;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Slack_App__c> getSlackApps() {
        try {
            return [SELECT Id, Name FROM Slack_App__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Slack_Channel__c> getSlackChannels() {
        try {
            return [SELECT Id, Name FROM Slack_Channel__c];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String getSiteUrl(String siteName) {
        try {
            if (Test.isRunningTest()) {
                return 'https://www.google.com';
            } else {
                Site slackDemoSite = [select Id from Site where MasterLabel = :siteName];
                System.debug(slackDemoSite);
                SiteDetail slackDemoSiteDetail = [select SecureURL from SiteDetail where DurableId = :slackDemoSite.Id];
                System.debug(slackDemoSiteDetail);
                return slackDemoSiteDetail.SecureURL;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}