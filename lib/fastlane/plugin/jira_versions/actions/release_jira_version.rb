module Fastlane
  module Actions
    module SharedValues
      RELEASE_JIRA_VERSION_VERSION_ID = :RELEASE_JIRA_VERSION_VERSION_ID
    end

    class ReleaseJiraVersionAction < Action
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
        name         = params[:name]
        release_date = params[:release_date]
        released     = true

        options = {
          username:     username,
          password:     password,
          site:         site,
          context_path: context_path,
          auth_type:    auth_type,
          read_timeout: 120
        }

        client = JIRA::Client.new(options)

        unless project_name.nil?
          project = client.Project.find(project_name)
          project_id = project.id
        end

        version = project.versions.find { |version| version.name == name }
        if version.nil?
          raise "Version '#{name}' not found."
          return false
        end
        version.save!({
          "released" => released,
          "releaseDate" => release_date,
          "projectId" => project_id
        })
        version.fetch
        Actions.lane_context[SharedValues::RELEASE_JIRA_VERSION_VERSION_ID] = version.id
        version.id
      rescue RuntimeError
        UI.user_error!("#{$!}")
        false
      rescue JIRA::HTTPError
        UI.user_error!("Failed to release new JIRA version: #{$!.response.body}")
        false
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Releases a version in your JIRA project"
      end

      def self.details
        "Use this action to release a version in JIRA"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                      env_name: "FL_RELEASE_JIRA_VERSION_SITE",
                                      description: "URL for Jira instance",
                                      type: String,
                                      verify_block: proc do |value|
                                        UI.user_error!("No url for Jira given, pass using `url: 'url'`") unless value and !value.empty?
                                      end),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_RELEASE_JIRA_VERSION_USERNAME",
                                       description: "Username for JIRA instance",
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("No username given, pass using `username: 'jira_user'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_RELEASE_JIRA_VERSION_PASSWORD",
                                       description: "Password for Jira",
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("No password given, pass using `password: 'T0PS3CR3T'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :project_name,
                                       env_name: "FL_RELEASE_JIRA_VERSION_PROJECT_NAME",
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
                                       env_name: "FL_RELEASE_JIRA_VERSION_PROJECT_ID",
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
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "FL_RELEASE_JIRA_VERSION_NAME",
                                       description: "The name of the version. E.g. 1.0.0",
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("No version name given, pass using `name: '1.0.0'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :release_date,
                                       env_name: "FL_CREATE_JIRA_VERSION_RELEASE_DATE",
                                       description: "The date this version ended on",
                                       type: String,
                                       is_string: true,
                                       optional: true,
                                       default_value: Date.today.to_s)
        ]
      end

      def self.output
        [
          ['RELEASE_JIRA_VERSION_VERSION_ID', 'The versionId for the newly released JIRA project version']
        ]
      end

      def self.return_value
        'The versionId for the newly release JIRA project version'
      end

      def self.authors
        ["https://github.com/SandyChapman"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
