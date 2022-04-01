import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Slack_App__c.Name';
import SITE_URL from '@salesforce/schema/Slack_App__c.Site_URL__c';
import { NavigationMixin } from "lightning/navigation";
const FIELDS = [NAME_FIELD, SITE_URL];

export default class AppManifestGenerator extends NavigationMixin(LightningElement) {
    @api recordId;
    slackApp;
    error;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({data, error}){
        if(data){
            this.slackApp = data;
            this.error = undefined;
        } else if(error) {
            this.slackApp = undefined;
            this.error = error;
        }
    }

    code;
    showManifest = false;
    url;
    appname;

    handleManifestGeneration() {
        this.url = getFieldValue(this.slackApp, SITE_URL);
        this.appname = getFieldValue(this.slackApp, NAME_FIELD);
        this.code = 'display_information:\n name: ' + this.appname + '\nfeatures:\n bot_user:\n  display_name: ' + this.appname + '\n  always_online: false\noauth_config:\n redirect_urls:\n  - '+ this.url +'/services/apexrest/slack/parseSlackAuthHttp\n scopes:\n  bot:\n   - incoming-webhook\n   - chat:write\nsettings:\n interactivity:\n  is_enabled: true\n  request_url: '+ this.url +'/services/apexrest/slack/parseSlackRequestHttp';
        this.showManifest = true;

    }

    handleSlackCreateAppClick() {
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: 'https://api.slack.com/apps?new_app=1'
            }
        };
        this[NavigationMixin.Navigate](config);
    }

}