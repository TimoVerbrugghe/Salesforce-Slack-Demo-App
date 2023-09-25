// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
String jsonInput = '{'+
		'    \"ok\": true,'+
		'    \"app_id\": \"A034ZCK5Z24\",'+
		'    \"authed_user\": {'+
		'        \"id\": \"U034BV3KMRS\"'+
		'    },'+
		'    \"scope\": \"incoming-webhook\",'+
		'    \"token_type\": \"bot\",'+
		'    \"access_token\": \"xoxb-1814240140212-3131084172407-RtjMtMJj7z17XxZy1C3D5LBt\",'+
		'    \"bot_user_id\": \"U033V2G52BZ\",'+
		'    \"team\": {'+
		'        \"id\": \"T01PY724468\",'+
		'        \"name\": \"Internal_Sandbox\"'+
		'    },'+
		'    \"enterprise\": {'+
		'        \"id\": \"E013GKFQQTB\",'+
		'        \"name\": \"SFDC Sandbox\"'+
		'    },'+
		'    \"is_enterprise_install\": false,'+
		'    \"incoming_webhook\": {'+
		'        \"channel\": \"#timo-verbrugghe-test-channel\",'+
		'        \"channel_id\": \"C034C02NTE0\",'+
		'        \"configuration_url\": \"https://internal-sandbox.slack.com/services/B034XF27SB0\",'+
		'        \"url\": \"https://hooks.slack.com/services/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\"'+
		'    }'+
		'}';
Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);

System.debug(m.get('access_token'));
Map<String, Object> incomingwebhook = 
   (Map<String, Object>)m.get('incoming_webhook');

System.debug(incomingwebhook.get('channel'));
System.debug(incomingwebhook.get('channel_id'));
System.debug(incomingwebhook.get('url'));

Map<String, Object> authedUser = (Map<String, Object>)m.get('authed_user');
System.debug(authedUser.get('id'));