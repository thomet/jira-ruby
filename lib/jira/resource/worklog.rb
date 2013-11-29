module JIRA
  module Resource

    class WorklogFactory < JIRA::BaseFactory # :nodoc:
    end

    class Worklog < JIRA::Base
      has_one :author, :class => JIRA::Resource::User
      has_one :update_author, :class => JIRA::Resource::User,
                              :attribute_key => "updateAuthor"
      def self.all(client, issue_key)
        response = client.get(client.options[:rest_base_path] + "/issue/#{issue_key}/worklog")
        json = parse_json(response.body)
        json['worklogs'].map do |issue|
          client.Worklog.build(issue)
        end
      end

      def created
        Time.parse(@attrs['created'])
      end

      def updated
        Time.parse(@attrs['updated'])
      end

      def started
        Time.parse(@attrs['started'])
      end
    end

  end
end
