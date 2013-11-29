require 'cgi'

module JIRA
  module Resource

    class IssueFactory < JIRA::BaseFactory # :nodoc:
    end

    class Issue < JIRA::Base

      has_one :reporter,  :class => JIRA::Resource::User,
                          :nested_under => 'fields'
      has_one :assignee,  :class => JIRA::Resource::User,
                          :nested_under => 'fields'
      has_one :project,   :nested_under => 'fields'

      has_one :issuetype, :nested_under => 'fields'

      has_one :priority,  :nested_under => 'fields'

      has_one :status,    :nested_under => 'fields'

      has_many :components, :nested_under => 'fields'

      has_many :comments, :nested_under => ['fields','comment']

      has_many :attachments, :nested_under => 'fields',
                          :attribute_key => 'attachment'

      has_many :versions, :nested_under => 'fields'

      def initialize(client, options = {})
        super(client, options)
        @linked_outward_isses = {}
        @linked_inward_issues = {}
      end

      def self.all(client)
        response = client.get(client.options[:rest_base_path] + "/search")
        json = parse_json(response.body)
        json['issues'].map do |issue|
          client.Issue.build(issue)
        end
      end

      def self.jql(client, jql, max_results = 50)
        url = client.options[:rest_base_path] + "/search?jql=" + CGI.escape(jql) + "&maxResults=#{max_results}"
        response = client.get(url)
        json = parse_json(response.body)
        json['issues'].map do |issue|
          client.Issue.build(issue)
        end
      end

      def parent
        @parent ||= if attrs.keys.include?('fields') && attrs['fields'].keys.include?('parent')
           client.Issue.find(attrs['fields']['parent']['key'])
        end
      end

      def subtasks
        @subtasks ||= if attrs.keys.include?('fields') && attrs['fields'].keys.include?('subtasks')
          attrs['fields']['subtasks'].map{|sub| client.Issue.find(sub['key']) }
        else
          []
        end
      end

      def linked_outward_isses(issue, outward_filter_type = nil)
        @linked_outward_isses[outward_filter_type] ||= issue.issuelinks.map do |issue_link|
          if issue_link['outwardIssue'] && (!inward_filter_type || issue_link['type']['outward'] == outward_filter_type)
            @client.Issue.find(issue_link['outwardIssue']['key'])
          end
        end.compact
      end

      def linked_inward_issues(issue, inward_filter_type = nil)
        @linked_inward_issues[inward_filter_type] ||= issue.issuelinks.map do |issue_link|
          if issue_link['inwardIssue'] && (!inward_filter_type || issue_link['type']['inward'] == inward_filter_type)
            @client.Issue.find(issue_link['inwardIssue']['key'])
          end
        end.compact
      end

      def worklogs
        @worklogs ||= @client.Worklog.all(key)
      end

      def respond_to?(method_name)
        if attrs.keys.include?('fields') && attrs['fields'].keys.include?(method_name.to_s)
          true
        else
          super(method_name)
        end
      end

      def method_missing(method_name, *args, &block)
        if attrs.keys.include?('fields') && attrs['fields'].keys.include?(method_name.to_s)
          attrs['fields'][method_name.to_s]
        else
          super(method_name)
        end
      end

    end

  end
end
