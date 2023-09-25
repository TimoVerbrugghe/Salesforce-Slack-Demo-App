import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import setupAlreadyDone from '@salesforce/apex/SlackSetup.setupAlreadyDone';
import getSlackApps from '@salesforce/apex/SlackSetup.getSlackApps';
import getSlackChannels from '@salesforce/apex/SlackSetup.getSlackChannels';
import generateSlackApp from '@salesforce/apex/SlackSetup.generateSlackApp';
import sendTestMessages from '@salesforce/apex/SlackSetup.sendTestMessages';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SLACKICON from '@salesforce/resourceUrl/SlackIcon';
import getSalesforceUrl from '@salesforce/apex/GetSalesforceURL.getSalesforceURL';
const SUCCESS_VARIANT = 'success';
const SUCCESS_TITLE = 'Message sent successfully';
const SUCCESS_MESSAGE = 'Your Slack message has been sent successfully';

const ERROR_VARIANT = 'error';

const columns = [
    {label : 'Name', fieldName : 'Name'}
]

export default class SlackSetup extends NavigationMixin(LightningElement) {
    // Generic Resources
    quipDocUrl = "https://salesforce.quip.com/y6d7AWHl0Fru";
    conciergeUrl = "https://concierge.it.salesforce.com/articles/en_US/Supportforce_Article/Slack-Sandbox-Request";
    slackSandboxUrl = "https://sfdc-sandbox.enterprise.slack.com/";
    slackBlockKitBuilder = "https://app.slack.com/block-kit-builder";
    slackIconUrl = `${SLACKICON}#slackicon`;
    

    columns = columns;
    slackApps;
    slackChannels;
    error;
    setup;

    @wire(getSlackApps)
    wiredSlackApps({ error, data }) {
        if (data) {
            this.slackApps = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.slackApps = undefined;
        }
    }

    @wire(getSlackChannels)
    wiredSlackChannels({ error, data }) {
        if (data) {
            this.slackChannels = data;
            this.error = undefined;
            console.log(data);
        } else if (error) {
            this.error = error;
            this.slackChannels = undefined;
        }
    }

    // Create Test Message resources

    orgUrl;
    testMessage;
    currentDate = new Date().toLocaleString();

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

    connectedCallback() {
        setupAlreadyDone()
        .then((result) => {
            this.setup = result;
            this.error = undefined;
                // If setup already done
                if(this.setup == true) {
                    this.resetPages();
                    this.currentStep = "4";
                    this.showPage4 = true;
                }
        })
        .catch((error) => {
            this.error = error;
            this.setup = undefined;
        });
    }

    handleSlackSandboxClick() {
        const goToSlackSandbox = {
            type: 'standard__webPage',
            attributes: {
                url: this.slackSandboxUrl
            }
        };
        this[NavigationMixin.Navigate](goToSlackSandbox);
    }

    handleQuipDocClick() {
        const goToQuipDoc = {
            type: 'standard__webPage',
            attributes: {
                url: this.quipDocUrl
            }
        };
        this[NavigationMixin.Navigate](goToQuipDoc);
    }

    // Progress indicator stuff
    currentStep = "1";
    showPage1 = true;
    showPage2 = false;
    showPage3 = false;
    showPage4 = false;

    resetPages() {
        this.showPage1 = false;
        this.showPage2 = false;
        this.showPage3 = false;
        this.showPage4 = false;
    }

    nextPage(event) {
        this.resetPages();

        let step = event.target.value;
        switch(step) {
            case "1":
                this.currentStep = "1";
                this.showPage1 = true;
                break;
            case "2":
                this.currentStep = "2";
                this.showPage2 = true;
                break;
            case "3":
                this.currentStep = "3";
                this.showPage3 = true;
                break;
            case "4":
                this.currentStep = "4";
                this.showPage4 = true;
                break;
        }
    }

    handleClick() {
        this.resetPages();
        switch(this.currentStep) {
            case "1":
                this.currentStep = "2";
                this.showPage2 = true;
                break;
            case "2":
                this.currentStep = "3";
                this.showPage3 = true;
                break;
            case "3":
                this.currentStep = "4";
                this.showPage4 = true;
                break;
        }
    }

    // Page 2 - Creating a site
    siteName;

    handleSiteNameChange(event) {
        this.siteName = event.detail.value;
    }

    // Page 3 - Getting app name, token & app installation
    appName;
    token;
    slackApp;
    appCreated = false;
    isLoading = false;
    createSlackAppDisabled = false;

    get disableButton() {
        return this.createSlackAppDisabled;
    }

    handleAppNameChange(event) {
        this.appName = event.detail.value;
    }

    handleTokenChange(event) {
        this.token = event.detail.value;
    }

    handleCreatingApp() {
        this.isLoading = true;
        setTimeout(() => {
            generateSlackApp({token : this.token, siteName : this.siteName, appName: this.appName})
            .then((result) => {
                this.slackApp = result;
                this.error = undefined;
                this.dispatchEvent(ShowToastEvent({
                    title: 'Slack App Created',
                    message: 'Your Slack App was created succesfully, you can now install it!',
                    variant: SUCCESS_VARIANT
                }));
                this.isLoading = false;
                this.appCreated = true;
                this.createSlackAppDisabled = true;
            })
            .catch((error) => {
                this.error = error;
                this.slackApp = undefined;
                this.dispatchEvent(ShowToastEvent({
                    title: "Couldn't create Slack App",
                    message: "Couldn't create the Slack App. An error was generated.",
                    variant: ERROR_VARIANT
                }));
                this.isLoading = false;
            });
        }, 0);
    }

    // Page 3 - Add app to channel Slack

    handleAddToSlackClick() {
        // Open adding to Slack in the same window as the setup screen
        window.open(this.slackApp.Authentication_URL__c, "_self")
    }

    // Page 4 - Finish (or showcase if app & channel already created)

    handleTestMessageSend() {
        this.isLoading = true;
        setTimeout(() => {
            sendTestMessages()
            .then((result) => {
                this.dispatchEvent(ShowToastEvent({
                    title: SUCCESS_TITLE,
                    message: SUCCESS_MESSAGE,
                    variant: SUCCESS_VARIANT
                }));
                this.isLoading = false;
            })
            .catch((error) => {
                this.error = error;
                this.dispatchEvent(ShowToastEvent({
                    title: "Couldn't send test message",
                    message: "Couldn't send a test message. An error was generated.",
                    variant: ERROR_VARIANT
                }));
            });
        }, 0);
    }
    
    activeSectionMessage = '';

    handleToggleSection(event) {
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }
}