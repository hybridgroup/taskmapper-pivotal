module TicketMaster::Provider
  # This is the Pivotal Tracker Provider for ticketmaster
  module Pivotal
    include TicketMaster::Provider::Base
    TICKET_API = PivotalAPI::Story
    PROJECT_API = PivotalAPI::Project
    
    # This is for cases when you want to instantiate using TicketMaster::Provider::Lighthouse.new(auth)
    def self.new(auth = {})
      TicketMaster.new(:pivotal, auth)
    end
    
    # The authorize and initializer for this provider
    def authorize(auth = {})
      @authentication ||= TicketMaster::Authenticator.new(auth)
      auth = @authentication
      if auth.token
        PivotalAPI.token = auth.token
      elsif auth.username && auth.password
        PivotalAPI.authenticate(auth.username, auth.password)
      end
    end
    
  end
end
