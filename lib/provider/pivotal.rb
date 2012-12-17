module TaskMapper::Provider
  # This is the Pivotal Tracker Provider for taskmapper
  module Pivotal
    include TaskMapper::Provider::Base
    TICKET_API = PivotalAPI::Story
    PROJECT_API = PivotalAPI::Project

    # This is for cases when you want to instantiate using TaskMapper::Provider::Lighthouse.new(auth)
    def self.new(auth = {})
      TaskMapper.new(:pivotal, auth)
    end

    # The authorize and initializer for this provider
    def authorize(auth = {})
      @authentication ||= TaskMapper::Authenticator.new(auth)
      auth = @authentication
      if auth.token.empty?
        raise "You should pass a token for authentication"
      end
      if auth.token
        PivotalAPI.token = auth.token
      elsif auth.username && auth.password
        PivotalAPI.authenticate(auth.username, auth.password)
      end
    end

    def valid?
      !PROJECT_API.find(:first).nil?
    rescue ActiveResource::UnauthorizedAccess
      false
    end

  end
end
