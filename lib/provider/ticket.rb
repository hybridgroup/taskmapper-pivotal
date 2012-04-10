module TicketMaster::Provider
  module Pivotal
    # Ticket class for ticketmaster-pivotal
    # * id
    # * status
    # * priority
    # * title => name
    # * resolution
    # * created_at
    # * updated_at
    # * description => text
    # * assignee
    # * requestor
    # * project_id (prefix_options[:project_id])
    class Ticket < TicketMaster::Provider::Base::Ticket
      @@allowed_states = ['new', 'open', 'resolved', 'hold', 'invalid']

      attr_accessor :prefix_options
      API = PivotalAPI::Story


      # The saver
      def save(*options)
        pt_ticket = @system_data[:client]
        self.keys.each do |key|
          pt_ticket.send(key + '=', self.send(key)) if self.send(key) != pt_ticket.send(key)
        end
        pt_ticket.save
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
        Comment.create(self.project_id, self.id, options.first)
      end
      # The closer
      def close(resolution = 'resolved')
        resolution = 'resolved' unless @@allowed_states.include?(resolution)
        ticket = PivotalAPI::Ticket.find(self.id, :params => {:project_id => self.prefix_options[:project_id]})
        ticket.state = resolution
        ticket.save
      end

      class << self

        def find_by_attributes(project_id, attributes = {})
          date_to_search = attributes[:updated_at] || attributes[:created_at]
          tickets = []
          unless date_to_search.nil?
            tickets = search_by_datefields(project_id, date_to_search)
          else
            tickets += API.find(:all, :params => {:project_id => project_id, :filter => filter(attributes)}).map { |xticket| self.new xticket }
          end
          tickets.flatten
        end

        def filter(attributes = {})
          filter = ""
          attributes.each_pair do |key, value|
            filter << "#{key}:#{value} "
          end
          filter.strip!
        end

        def create(options)
          super translate options, {:name => :title}
        end

        private
        def search_by_datefields(project_id, date_to_search)
          date_to_search = date_to_search.strftime("%Y/%m/%d")
          tickets = []
          PivotalAPI::Activity.find(:all, :params => {:project_id => project_id, :occurred_since_date => date_to_search}).each do |activity|
            tickets = activity.stories.map { |xstory| self.new xstory }
          end
          tickets
        end

        def translate(hash, mapping)
          Hash[hash.map { |k, v| [mapping[k] ||= k, v]}]
        end
      end
    end

  end
end
