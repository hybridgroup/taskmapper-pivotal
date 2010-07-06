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
      
      # Delete this project
      def destroy
        result = self.system_data[:client].destroy
        result.is_a?(Net::HTTPOK)
      end
      
      # copy from
      def copy(project)
        project.tickets.each do |ticket|          copy_ticket= self.ticket!(:name => ticket.title, :description => ticket.body)          ticket.comments.each do |comment|            copy_ticket.comment!(:text => comment.body)            sleep 1          end        end
      end
      
    end
  end
end
