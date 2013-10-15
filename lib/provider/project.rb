module TaskMapper::Provider
  module Pivotal
    # Project class for taskmapper-pivotal
    #
    #
    class Project < TaskMapper::Provider::Base::Project
      API = PivotalAPI::Project
      # The finder method
      #
      # It accepts all the find functionalities defined by taskmapper
      #
      # + find() and find(:all) - Returns all projects on the account
      # + find(<project_id>) - Returns the project based on the id
      # + find(:first, :name => <project_name>) - Returns the first project based on the attribute
      # + find(:name => <project name>) - Returns all projects based on the attribute
      attr_accessor :prefix_options
      alias_method :stories, :tickets
      alias_method :story, :ticket

      # Save this project
      def save
        warn 'Warning: Pivotal does not allow editing of project attributes. This method does nothing.'
        true
      end

      def initialize(*options)
        super(*options)
        self.id = self.id.to_i
      end

      # Delete this project
      def destroy
        result = self.system_data[:client].destroy
        result.is_a?(Net::HTTPOK)
      end

      def ticket!(*options)
        options.first.merge!(:project_id => self.id)
        Ticket.create(options.first)
      end

      # copy from
      def copy(project)
        project.tickets.each do |ticket|
          copy_ticket = self.ticket!(:name => ticket.title, :description => ticket.description)
          ticket.comments.each do |comment|
            copy_ticket.comment!(:text => comment.body)
            sleep 1
          end
        end
      end
    end
  end
end
