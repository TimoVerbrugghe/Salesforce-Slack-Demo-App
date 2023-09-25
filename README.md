# Salesforce & Slack Demo App

This repo contains all the code (apex, LWC and other config files) to connect Salesforce orgs to Slack (using the Slack Web Api) for demonstration purposes.

You can compile this code into a Salesforce managed package which can be installed in any org that uses Platform, Sales or Service cloud licenses. The apex code is an implementation of the Slack web API so you can send messages, generate Slack app home screens or send replies in Slack.

This package also includes a Lightning app called "Slack Demos" with a wizard built in LWC to connect to your Slack org, deploy a new custom Slack app and to connect the app to your org.
