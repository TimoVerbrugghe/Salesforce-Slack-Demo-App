public with sharing class SlackSetup {

    @AuraEnabled
    public static Slack_App__c generateSlackApp(String token, String siteName, String appName){
        try {
            // Getting Site URL
            String siteUrl = getSiteUrl(siteName);
            String redirectUrl = siteUrl + '/services/apexrest/timoverbrugghe/SlackDemoApp/parseSlackAuthHttp';
            String requestUrl = siteUrl + '/services/apexrest/timoverbrugghe/SlackDemoApp/parseSlackRequestHttp';

            // Generating manifest
            String manifest = '{ "display_information": { "name": "' + appName + '" }, "features": { "app_home": { "home_tab_enabled": true, "messages_tab_enabled": false, "messages_tab_read_only_enabled": true }, "bot_user": { "display_name": "' + appName + '", "always_online": false } }, "oauth_config": { "redirect_urls": [ "' + redirectUrl + '" ], "scopes": { "bot": [ "chat:write", "incoming-webhook", "channels:join", "channels:manage", "users:read.email" ] } }, "settings": { "interactivity": { "is_enabled": true, "request_url": "' + requestUrl + '" }, "org_deploy_enabled": false, "socket_mode_enabled": false, "token_rotation_enabled": false } }';


            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndPoint('https://slack.com/api/apps.manifest.create');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization', 'Bearer ' + token);
            request.setBody('manifest=' + manifest);
            HttpResponse response = http.send(request);
            System.debug(response.getBody());

            SlackGenerateAppResponseParser generatedApp = new SlackGenerateAppResponseParser();
            generatedApp = SlackGenerateAppResponseParser.parse(response.getBody());

            Slack_App__c slackApp = createSlackAppObject(appName, siteUrl, generatedApp.oauth_authorize_url + '&request_uri=' + redirectUrl, generatedApp.app_id, generatedApp.credentials.client_id, generatedApp.credentials.client_secret);

            return slackApp;            

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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

    @AuraEnabled
    public static List<Slack_Channel__c> getSlackChannels() {
        try {
            return [SELECT Id, Name FROM Slack_Channel__c];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String getSiteUrl(String siteName) {
        try {
            Site slackDemoSite = [select Id from Site where MasterLabel = :siteName];
            SiteDetail slackDemoSiteDetail = [select SecureURL from SiteDetail where DurableId = :slackDemoSite.Id];
            return slackDemoSiteDetail.SecureURL;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}