module TaskMapper::Provider
  module Pivotal
    class Ticket < TaskMapper::Provider::Base::Ticket
      API = PivotalAPI::Story

      ALLOWED_STATES = ['new', 'open', 'resolved', 'hold', 'invalid'].freeze

      # Public: Saves a Ticket/Story to Pivotal Tracker
      #
      # Returns a boolean indicating whether or not the Story saved
      def save
        story = @system_data[:client]
        self.keys.each do |key|
          if self.send(key) != story.send(key)
            story.send key + '=', self.send(key)
          end
        end
        story.save
      end

      # Public: Destroys the Ticket/Story in Pivotal Tracker
      #
      # Returns whether or not the Story was destroyed
      def destroy
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

      def close(resolution = 'resolved')
        resolution = 'resolved' unless ALLOWED_STATES.include?(resolution)
        ticket = PivotalAPI::Ticket.find(
          self.id,
          :params => { :project_id => project_id }
        )
        ticket.state = resolution
        ticket.save
      end

      class << self
        def find_by_attributes(project_id, attributes = {})
          date_to_search = attributes[:updated_at] || attributes[:created_at]
          tickets = []
          if date_to_search
            tickets = search_by_datefields(project_id, date_to_search)
          else
            tickets += API.find(
              :all,
              :params => {
                :project_id => project_id,
                :filter => filter(attributes)
              }
            ).collect { |ticket|
              self.new ticket.attributes.merge(:project_id => project_id)
            }.flatten
          end

          tickets
        end

        def filter(attributes = {})
          attributes.collect { |k, v| filter << "#{k}:#{v}" }.join(' ')
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
          PivotalAPI::Activity.find(
            :all,
            :params => {
              :project_id => project_id,
              :occurred_since_date => date_to_search
            }
          ).collect do |activity|
            activity.stories.map do |story|
              self.new story.attributes.merge(:project_id => project_id)
            end
          end.flatten
        end

        def translate(hash, mapping)
          Hash[hash.map { |k, v| [mapping[k] ||= k, v]}]
        end
      end
    end
  end
end
