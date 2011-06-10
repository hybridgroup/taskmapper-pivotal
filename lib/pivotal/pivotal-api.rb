require 'rubygems'
require 'active_support'
require 'active_resource'

module PivotalAPI
  class Error < StandardError; end
  class << self
    # Sets up basic authentication credentials for all the resources.
    def authenticate(user, password)
      Token.user = user
      Token.password = password
      self.token = Token.get(:active)['guid']
      Token.user = nil
      Token.password = nil
    end

    # Sets the API token for all the resources.
    def token=(value)
      resources.each do |klass|
        klass.headers['X-TrackerToken'] = value
      end
      @token = value
    end

    def resources
      @resources ||= []
    end
  end

  class Base < ActiveResource::Base
    self.site = 'https://www.pivotaltracker.com/services/v3/'
    def self.inherited(base)
      PivotalAPI.resources << base
      super
    end
  end

  class Project < Base
    def stories(options = {})
      Story.find(:all, :params => options.merge!(:project_id => self.id))
    end
  end
  
  class Token < Base
  end
  
  class Activity < Base
    self.site += 'projects/:project_id/'
  end

  class Membership < Base
    self.site += 'projects/:project_id/'
  end

  class Iteration < Base
    self.site += 'projects/:project_id/'
  end

  class Story < Base
    self.site += 'projects/:project_id/'
  end

  class Note < Base
    self.site += 'projects/:project_id/stories/:story_id/'
  end

  class Task < Base
    self.site += 'projects/:project_id/stories/:story_id/'
  end

  class AllActivity < Base
  end
end
