module TicketMaster::Provider
  module Pivotal
    # The comment class for ticketmaster-pivotal
    # * author
    # * body => text
    # * id => position in the versions array (set by the initializer)
    # * created_at => noted_at
    # * updated_at => noted_at
    # * ticket_id (actually the story id)
    # * project_id
    class Comment < TicketMaster::Provider::Base::Comment
      API = PivotalAPI::Note
      
      # A custom find_by_id
      # The "comment" id is it's index in the versions array. An id of 0 therefore exists and
      # should be the first ticket (original)
      def self.find_by_id(project_id, ticket_id, id)
        self.new PivotalAPI::Note.find(id, :params => {:project_id => project_id, :story_id => ticket_id})
      end
      
      # A custom find_by_attributes
      #
      def self.find_by_attributes(project_id, ticket_id, attributes = {})
        self.search(project_id, ticket_id, attributes).collect { |comment| self.new comment }
      end
      
      # A custom searcher
      #
      # It returns a custom result because we need the original story to make a comment.
      def self.search(project_id, ticket_id, options = {}, limit = 1000)
        comments = PivotalAPI::Note.find(:all, :params => {:project_id => project_id, :story_id => ticket_id})
        search_by_attribute(comments, options, limit)
      end
      
      def initialize(note, ticket = nil)
        @system_data ||= {}
        @system_data[:ticket] = @system_data[:client] = ticket if ticket
        if note.is_a?(PivotalAPI::Note)
          @system_data[:note] = note
          self.project_id = note.prefix_options[:project_id]
          self.project_id ||= ticket.prefix_options[:project_id] if ticket
          self.ticket_id = note.prefix_options[:story_id]
          self.ticket_id ||= ticket.id if ticket
          self.id = note.id
          self.prefix_options = note.prefix_options
        end
        super(@system_data[:note])
      end
      
      def body
        self.text
      end
      
      def body=(bod)
        self.text = bod
      end
      
      def created_at
        self.noted_at
      end
      
      def updated_at
        self.noted_at
      end
      
      def project_id
        self.project_id || @system_data[:client].prefix_options[:project_id]
      end
      
      def ticket_id
        self.ticket_id || @system_data[:client].prefix_options[:story_id]
      end
    end
  end
end
