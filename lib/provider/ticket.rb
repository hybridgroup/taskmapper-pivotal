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

      def self.find(project_id, *options)
        if options[0].first.is_a? Array
          self.find_by_attributes(project_id, {}, options[0].first)
        elsif options[0].first.is_a? Hash
          self.find_by_attributes(project_id, options[0].first)
        else
          self.find_by_attributes(project_id)
        end
      end

      def self.find_by_attributes(project_id, attributes = {}, ids = [])
        filter = ""
        unless ids.empty?
          filter = ids.join(",")
        end
        unless filter.empty?
          attributes.each_pair do |key, value|
            key = "name" if key == "title" 
            key = "text" if key == "description"
            filter << " #{key}:#{value}"
          end
        end
        API.find(:all, :params => {:project_id => project_id, :filter => "#{filter}"}).map { |xticket| self.new xticket }
      end

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

      def title
        self.name
      end

      def title=(title)
        self.name=title
      end

      # The closer
      def close(resolution = 'resolved')
        resolution = 'resolved' unless @@allowed_states.include?(resolution)
        ticket = PivotalAPI::Ticket.find(self.id, :params => {:project_id => self.prefix_options[:project_id]})
        ticket.state = resolution
        ticket.save
      end
    end
  end
end
