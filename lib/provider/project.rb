module TaskMapper::Provider
  module Pivotal
    class Project < TaskMapper::Provider::Base::Project
      API = PivotalAPI::Project

      # Public: Creates a new Project based on passed arguments
      #
      # args - hash of Project values
      #
      # Returns a new Project
      def initialize(*args)
        super(*args)
        self.id = self.id.to_i
      end

      # Public: No-op since Pivotal doesn't allow editing of project attributes.
      #
      # Returns true
      def save
        warn 'Warning: Pivotal does not allow editing of project attributes.'
        true
      end

      # Public: Attempts to destroy the Project representation in Pivotal
      #
      # Returns boolean indicating whether or not the project was destroyed
      def destroy
        self.system_data[:client].destroy.is_a?(Net::HTTPOK)
      end

      # Public: Copies tickets/comments from one Project onto another.
      #
      # project - Project whose tickets/comments should be copied onto self
      #
      # Returns the updated project
      def copy(project)
        project.tickets.each do |ticket|
          copy_ticket = self.ticket!(
            :name => ticket.title,
            :description => ticket.description
          )
          ticket.comments.each do |comment|
            copy_ticket.comment!(:text => comment.body)
            sleep 1
          end
        end
      end
    end
  end
end
