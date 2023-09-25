public class SlackDemoFlows {
    @AuraEnabled(cacheable=true)
    public static List<FlowDefinitionView> getSlackDemoFlows() {
        return [SELECT Label, LatestVersionId, Description FROM FlowDefinitionView WHERE Label LIKE '%(Slack Example)' ORDER BY Label];
    }
}
