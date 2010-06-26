module TicketMaster::Provider
  module Pivotal
    # Ticket class for ticketmaster-pivotal
    class Ticket < TicketMaster::Provider::Base::Ticket
      @@allowed_states = ['new', 'open', 'resolved', 'hold', 'invalid']
      attr_accessor :prefix_options
      
      # The finder
      #
      # It tries to implement all the ticketmaster calls, but since the project id is required as the
      # parent key, it doesnt really make sense to call find(:all) or find(##)
      # 
      # * find(:all) - Returns an array of all tickets
      # * find(##, ##) - Returns a ticket based on that id or some other primary (unique) attribute
      # * find(:first, :summary => 'Ticket title') - Returns a ticket based on the ticket's attributes
      # * find(:summary => 'Test Ticket') - Returns all tickets based on the given attributes
      def self.find(*options)
        first = options.shift
        if first.nil? or first == :all
          tickets = []
          PivotalAPI::Project.find(:all).each do |p|
            tickets |= p.stories
          end
          tickets.collect { |t| self.new t }
        elsif first.is_a?(Fixnum)
          second = options.shift
          if second.is_a?(Fixnum)
            self.new PivotalAPI::Story.find(first, :params => { :project_id => second })
          elsif second.is_a?(Hash)
            self.new PivotalAPI::Story.find(first, :params => qize(second))
          end
        elsif first == :first
          self.new self.search(options.shift, 1).first
        elsif first.is_a?(Hash)
          self.search(first).collect do |t| self.new t end
        end
      end
      
      def self.qize(params)
        return params unless params[:filter] and params[:filter].is_a?(Hash)
        q = ''
        params[:filter].keys.each do |key|
          value = params[:q][key]
          value = "\"#{value}\"" if value.to_s.include?(' ')
          q += "#{key}:#{value} "
        end
        params[:filter] = q
        params
      end
      
      # The find helper
      def self.search(options, limit = 1000)
        tickets = PivotalAPI::Story.find(:all, :params => ({:project_id => (options.delete(:project_id) || options.delete('project_id')).to_i}.merge(qize(:filter => options))))
        tickets.find_all do |t|
          options.keys.reduce(true) do |memo, key|
            t.send(key) == options[key] and (limit-=1) > 0
          end
        end
      end
      
      # The initializer
      def initialize(*options)
        @system = :pivotal
        @system_data = {}
        first = options.shift
        if first.is_a?(PivotalAPI::Story)
          @system_data[:client] = first
          @prefix_options = first.prefix_options
          super(first.attributes)
        else
          super(first)
        end
      end
      
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
