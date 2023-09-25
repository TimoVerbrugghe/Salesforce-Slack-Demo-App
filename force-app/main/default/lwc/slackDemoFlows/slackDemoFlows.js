import { LightningElement, wire } from 'lwc';
import getSalesforceUrl from '@salesforce/apex/GetSalesforceURL.getSalesforceURL';
import getSlackDemoFlows from '@salesforce/apex/SlackDemoFlows.getSlackDemoFlows';
import { NavigationMixin } from "lightning/navigation";

export default class SlackDemoFlows extends NavigationMixin(LightningElement) {
    blockKitURL_SendingMessage = 'https://app.slack.com/block-kit-builder/T01GST6QY0G#%7B%22blocks%22:%5B%7B%22type%22:%22section%22,%22text%22:%7B%22type%22:%22mrkdwn%22,%22text%22:%22A%20new%20account%20has%20been%20assigned%20to%20you%20in%20Salesforce:%22%7D%7D,%7B%22type%22:%22section%22,%22fields%22:%5B%7B%22type%22:%22mrkdwn%22,%22text%22:%22*Name:*%5CnACCOUNT%20NAME%22%7D,%7B%22type%22:%22mrkdwn%22,%22text%22:%22*Date%20Created:*%5CnDATECREATED%22%7D,%7B%22type%22:%22mrkdwn%22,%22text%22:%22*Created%20By:*%5CnCREATEDBY%22%7D%5D%7D,%7B%22type%22:%22actions%22,%22elements%22:%5B%7B%22type%22:%22button%22,%22url%22:%22https://www.google.com%22,%22text%22:%7B%22type%22:%22plain_text%22,%22emoji%22:true,%22text%22:%22:salesforce:%20View%20in%20Salesforce%22%7D%7D,%7B%22type%22:%22button%22,%22text%22:%7B%22type%22:%22plain_text%22,%22emoji%22:true,%22text%22:%22:phone:%20Log%20Introduction%20Call%22%7D,%22action_id%22:%22LogIntroductionCall%22,%22value%22:%22click_me_123%22%7D%5D%7D%5D%7D';
    blockKitURL_SendingReply = '';

    orgUrl;
    error;
    slackDemoFlows;

    @wire(getSlackDemoFlows)
    wiredDemoFlows({error,data}) {
        if (data) {
            this.slackDemoFlows = data;
            this.error = undefined;
        } else if (error) {
            this.slackDemoFlows = error;
            this.orgUrl = undefined;
        }
    }
    
    @wire(getSalesforceUrl)
    wiredOrgUrl({error,data}) {
        if (data) {
            this.orgUrl = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.orgUrl = undefined;
        }
    }

    handleOpenFlow(event) {
        let flowId = event.target.value;
        console.log(event.target.value);
        let goToFlow = {
            type: 'standard__webPage',
            attributes: {
                url: this.orgUrl + '/builder_platform_interaction/flowBuilder.app?flowId=' + flowId
            }
        };
        this[NavigationMixin.Navigate](goToFlow);
    }
}
