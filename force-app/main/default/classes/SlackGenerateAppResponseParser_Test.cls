//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

@IsTest
public class SlackGenerateAppResponseParser_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"ok\": true,'+
		'    \"app_id\": \"A012ABCD0A0\",'+
		'    \"credentials\": {'+
		'        \"client_id\": \"...\",'+
		'        \"client_secret\": \"...\",'+
		'        \"verification_token\": \"...\",'+
		'        \"signing_secret\": \"...\"'+
		'    },'+
		'    \"oauth_authorize_url\": \"https://slack.com/oauth/v2/authorize?client_id=...&scope=commands,workflow.steps:execute\"'+
		'}';
		SlackGenerateAppResponseParser obj = SlackGenerateAppResponseParser.parse(json);
		System.assert(obj != null);
	}
}