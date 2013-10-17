module TaskMapper::Provider
  module Pivotal
    class Ticket < TaskMapper::Provider::Base::Ticket
      API = PivotalAPI::Story

      @@allowed_states = ['new', 'open', 'resolved', 'hold', 'invalid'].freeze

      def save(*options)
        story = @system_data[:client]
        self.keys.each do |key|
          if self.send(key) != story.send(key)
            story.send key + '=', self.send(key)
          end
        end
        story.save
      end

      def destroy(*options)
        @system_data[:client].destroy.is_a?(Net::HTTPOK)
      end

      def project_id
        self.prefix_options[:project_id]
      end

      def requestor
        self.requested_by
      end

      def title
        self.name
      end

      def title=(title)
        self.name=title
      end

      def status
        self.current_state
      end

      def priority
        self.estimate
      end

      def resolution
        self.current_state
      end

      def assignee
        self.owned_by
      end

      def comment!(*options)
        Comment.create self.project_id, self.id, options.first
      end

      def close(resolution = 'resolved')
        resolution = 'resolved' unless @@allowed_states.include?(resolution)
        ticket = PivotalAPI::Ticket.find(
          self.id,
          :params => { :project_id => self.prefix_options[:project_id] }
        )
        ticket.state = resolution
        ticket.save
      end

      class << self
        def find_by_attributes(project_id, attributes = {})
          date_to_search = attributes[:updated_at] || attributes[:created_at]
          tickets = []
          if !date_to_search.nil?
            tickets = search_by_datefields(project_id, date_to_search)
          else
            tickets += API.find(
              :all,
              :params => {
                :project_id => project_id,
                :filter => filter(attributes)
              }
            ).map { |t| self.new t }.flatten
          end

          tickets
        end

        def filter(attributes = {})
          filter = ""
          attributes.each_pair { |k, v| filter << "#{k}:#{v} " }
          filter.strip!
        end

        def create(options)
          super translate(options,
            {
              :title => :name,
              :requestor => :requested_by,
              :status => :current_state,
              :estimate => :priority,
              :assignee => :owned_by
            }
          )
        end

        private
        def search_by_datefields(project_id, date_to_search)
          date_to_search = date_to_search.strftime("%Y/%m/%d")
          activities = PivotalAPI::Activity.find(
            :all,
            :params => {
              :project_id => project_id,
              :occurred_since_date => date_to_search
            }
          )

          activies.collect do |activity|
            activity.stories.map { |story| self.new story }
          end.flatten
        end

        def translate(hash, mapping)
          Hash[hash.map { |k, v| [mapping[k] ||= k, v]}]
        end
      end
    end
  end
end
