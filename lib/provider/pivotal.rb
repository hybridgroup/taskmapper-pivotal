module TaskMapper::Provider
  # This is the Pivotal Tracker Provider for taskmapper
  module Pivotal
    include TaskMapper::Provider::Base
    TICKET_API = PivotalAPI::Story
    PROJECT_API = PivotalAPI::Project

    class << self
      attr_accessor :token, :username, :password

      def new(auth = {})
        TaskMapper.new(:pivotal, auth)
      end
    end

    def authorize(auth = {})
      @authentication ||= TaskMapper::Authenticator.new(auth)
      auth = @authentication

      check_auth_params auth
      configure auth
    end

    def provider
      TaskMapper::Provider::Pivotal
    end

    def configure(auth)
      if auth.token
        PivotalAPI.token = auth.token
        provider.token = auth.token
      elsif auth.username && auth.password
        PivotalAPI.authenticate auth.username, auth.password
        provider.username = auth.username
        provider.password = auth.password
      end
    end

    def valid?
      PROJECT_API.find(:first)
      true
    rescue ActiveResource::UnauthorizedAccess
      false
    end

    private
    def check_auth_params(auth)
      unless auth.token || auth.username
        msg = "Please provide a token or username/password for authentication"
        raise TaskMapper::Exception.new msg
      end

      if auth.username && !auth.password
        msg = "Please provide a password for authentication"
        raise TaskMapper::Exception.new msg
      end
    end
  end
end
