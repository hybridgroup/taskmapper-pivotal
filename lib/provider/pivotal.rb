module TaskMapper::Provider
  # This is the Pivotal Tracker Provider for taskmapper
  module Pivotal
    include TaskMapper::Provider::Base

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
        PivotalTracker::Client.token = auth.token
      elsif auth.username && auth.password
        PivotalTracker::Client.token(auth.username, auth.password)
      end
    end

    def valid?
      PivotalTracker::Project.find(:first).nil?
    end

  end
end
