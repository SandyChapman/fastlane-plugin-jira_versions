module Fastlane
  module Actions
    module SharedValues
      GET_JIRA_VERSION_NAMES = :GET_JIRA_VERSION_NAMES
    end

    class GetJiraVersionsAction < Action
      def self.run(params)
        Actions.verify_gem!('jira-ruby')
        require 'jira-ruby'

        site         = params[:url]
        context_path = ""
        auth_type    = :basic
        username     = params[:username]
        password     = params[:password]
        project_name = params[:project_name]
        project_id   = params[:project_id]
        use_ssl      = params[:use_ssl]

        options = {
          username:     username,
          password:     password,
          site:         site,
          context_path: context_path,
          auth_type:    auth_type,
          use_ssl:      use_ssl,
          read_timeout: 120
        }

        client = JIRA::Client.new(options)

        unless project_name.nil?
          project = client.Project.find(project_name)
        end

        version_names = project.versions.map { |version| version.name }
        Actions.lane_context[SharedValues::GET_JIRA_VERSION_NAMES] = version_names
        return version_names
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Gets a list of all versions for a JIRA project"
      end

      def self.details
        "Use this action to get a list of all version names for a JIRA project"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                      env_name: "FL_GET_JIRA_VERSIONS_SITE",
                                      description: "URL for Jira instance",
                                      type: String,
                                      verify_block: proc do |value|
                                        UI.user_error!("No url for Jira given, pass using `url: 'url'`") unless value and !value.empty?
                                      end),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_GET_JIRA_VERSIONS_USERNAME",
                                       description: "Username for JIRA instance",
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("No username given, pass using `username: 'jira_user'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_GET_JIRA_VERSIONS_PASSWORD",
                                       description: "Password for Jira",
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("No password given, pass using `password: 'T0PS3CR3T'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :project_name,
                                       env_name: "FL_GET_JIRA_VERSIONS_PROJECT_NAME",
                                       description: "Project ID for the JIRA project. E.g. the short abbreviation in the JIRA ticket tags",
                                       type: String,
                                       optional: true,
                                       conflicting_options: [:project_id],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'project_name' and '#{project_id}' options in one run")
                                       end,
                                       verify_block: proc do |value|
                                         UI.user_error!("No Project ID given, pass using `project_id: 'PROJID'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :project_id,
                                       env_name: "FL_GET_JIRA_VERSIONS_PROJECT_ID",
                                       description: "Project ID for the JIRA project. E.g. the short abbreviation in the JIRA ticket tags",
                                       type: String,
                                       optional: true,
                                       conflicting_options: [:project_name],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'project_id' and '#{project_name}' options in one run")
                                       end,
                                       verify_block: proc do |value|
                                         UI.user_error!("No Project ID given, pass using `project_id: 'PROJID'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :use_ssl,
                                       env_name: "FL_GET_JIRA_VERSIONS_USE_SSL",
                                       description: "If true communication with jira will be done by using https",
                                       is_string: false,
                                       optional: true,
                                       default_value: true)
        ]
      end

      def self.output
        [
          ['GET_JIRA_VERSION_NAMES', 'A collection of all available version names for the given project']
        ]
      end

      def self.return_value
        'A collection of all available version names for the given project'
      end

      def self.authors
        ["Sascha Held"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
