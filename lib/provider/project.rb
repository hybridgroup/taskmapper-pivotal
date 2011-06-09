module TicketMaster::Provider
  module Pivotal
    # Project class for ticketmaster-pivotal
    # 
    # 
    class Project < TicketMaster::Provider::Base::Project
      API = PivotalAPI::Project
      # The finder method
      # 
      # It accepts all the find functionalities defined by ticketmaster
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
        if options.first.is_a?(Hash)
          options[0].merge!(:project_id => id)
          title = options[0].delete('title') || options[0].delete(:title) || options[0].delete(:summary) || options[0].delete('summary')
          options[0][:name] = title
          warn("Pivotal Tracker requires a title or name for the story") if options[0][:name].blank? and options[0]['name'].blank?
        end
        provider_parent(self.class)::Ticket.create(*options)
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
