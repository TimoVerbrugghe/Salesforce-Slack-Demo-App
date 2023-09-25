import { LightningElement, wire } from 'lwc';
import getSlackApp from '@salesforce/apex/AddNewChannelController.getSlackApp';
import { NavigationMixin } from "lightning/navigation";
import setupAlreadyDone from '@salesforce/apex/SlackSetup.setupAlreadyDone';

export default class AddNewChannel extends NavigationMixin(LightningElement) {
    slackApp;
    slackUrl;
    showAddChannel = false;
    setup;

    @wire(getSlackApp)
    wiredSlackApp({ error, data }) {
        if (data) {
            this.slackApp = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.slackApp = undefined;
        }
    }

    connectedCallback() {
        setupAlreadyDone()
        .then((result) => {
            this.setup = result;
            if(this.setup == true) {
                this.showAddChannel = true;
            }
        })
        .catch((error) => {
            this.error = error;
            this.setup = undefined;
        });
    }

    handleAddToSlackClick() {
        const goToSlackAdd = {
            type: 'standard__webPage',
            attributes: {
                url: this.slackApp.Authentication_URL__c
            }
        };
        this[NavigationMixin.Navigate](goToSlackAdd);
    }
}