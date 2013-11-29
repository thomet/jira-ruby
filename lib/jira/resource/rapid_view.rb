module JIRA
  module Resource

    class RapidViewFactory < JIRA::BaseFactory # :nodoc:
    end

    class RapidView < JIRA::Base

      # Overrides collection path to use greenhopper_rest_path
      def self.collection_path(client, prefix = '/')
        client.options[:greenhopper_base_path] + prefix + self.endpoint_name
      end

      def self.all(client)
        response = client.get(client.options[:greenhopper_base_path] + '/rapidviews/list.json')
        json = parse_json(response.body)
        json['views'].map do |view|
          self.new(client, {:attrs => view})
        end
      end

      def self.find(client, key, options = {})
        instance = self.new(client, options)
        instance.attrs[key_attribute.to_s] = key
        instance.fetch
        instance
      end

      def sprints
        response = client.get(client.options[:greenhopper_base_path] + "/xboard/plan/backlog/data.json?rapidViewId=#{id}")
        json = self.class.parse_json(response.body)
        json['sprints'].map do |sprint|
          client.Sprint.build(sprint)
        end
      end
    end
  end
end
