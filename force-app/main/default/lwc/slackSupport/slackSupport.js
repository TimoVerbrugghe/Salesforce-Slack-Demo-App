import { LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class SlackSupport extends NavigationMixin(LightningElement) {
    chatUrl = 'https://salesforce-internal.slack.com/archives/D02KT4E617D';

    handleTimoChat() {
        let goToChat = {
            type: 'standard__webPage',
            attributes: {
                url: this.chatUrl
            }
        };
        this[NavigationMixin.Navigate](goToChat);
    }
}