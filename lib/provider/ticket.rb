module TicketMaster::Provider
  module Pivotal
    # Ticket class for ticketmaster-pivotal
    class Ticket < TicketMaster::Provider::Base::Ticket
      @@allowed_states = ['new', 'open', 'resolved', 'hold', 'invalid']
      attr_accessor :prefix_options
      API = PivotalAPI::Story
      
      # The creator
      def self.create(*options)
        new_ticket = PivotalAPI::Story.new(:project_id => (options.first.delete(:project_id) || options.first.delete('project_id')).to_i)
        ticket_attr.each do |k, v|
          new_ticket.send(k + '=', v)
        end
        new_ticket.save
        self.new new_ticket
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
