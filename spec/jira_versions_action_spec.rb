describe Fastlane::Actions::JiraVersionsAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The jira_versions plugin is working!")

      Fastlane::Actions::JiraVersionsAction.run(nil)
    end
  end
end
