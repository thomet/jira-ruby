module JIRA
  module Resource

    class SprintFactory < JIRA::BaseFactory # :nodoc:
    end

    class Sprint < JIRA::Base

      # Overrides collection path to use greenhopper_rest_path
      def self.collection_path(client, prefix = '/')
        client.options[:greenhopper_base_path] + prefix + self.endpoint_name
      end

      def self.all(client, rapid_view_id)
        response = client.get(client.options[:greenhopper_base_path] + "/xboard/plan/backlog/data.json?rapidViewId=#{id}")
        json = parse_json(response.body)
        json['sprints'].map do |sprint|
          self.new(sprint)
        end
      end

      #def self.find(client, key, options = {})
      #  self.all(client).select{|sprint| sprint.id == key}.first
      #end

      # Returns all the issues for this project
      def issues
        response = client.get(client.options[:rest_base_path] + "/search?jql=id%20in%20(#{issuesIds.join(',')})&maxResults=#{issuesIds.count}")
        json = self.class.parse_json(response.body)
        json['issues'].map do |issue|
          client.Issue.build(issue)
        end
      end

      # attributes the attributes for the specified resource from JIRA unless
      # the resource is already expanded and the optional force reload flag
      # is not set
      def fetch(reload = false)
        return if expanded? && !reload
        response = client.get(url)
        set_attrs_from_response(response)
        @expanded = true
      end

      def startDate
        Time.parse(@attrs['startDate'])
      end

      def endDate
        Time.parse(@attrs['endDate'])
      end
    end
  end
end
