// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

// Get site information
String siteName = 'Slack Demo 2';
Site slackDemoSite = [select Id from Site where MasterLabel = :siteName];
SiteDetail slackDemoDetail = [select SecureURL from SiteDetail where DurableId = :slackDemoSite.Id];
System.debug(slackDemoDetail.SecureURL);
String name = 'Slack Demo 2';
Profile profile = [SELECT Id FROM Profile WHERE Name= :name + ' Profile'];
System.debug(profile.Id);