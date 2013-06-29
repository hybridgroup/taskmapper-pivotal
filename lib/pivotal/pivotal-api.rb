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
    self.format = ActiveResource::Formats::XmlFormat
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
    schema do
      attribute 'id', :integer
      attribute 'project_id', :integer
      attribute 'story_type', :string
      attribute 'url', :string
      attribute 'estimate', :integer
      attribute 'current_state', :string
      attribute 'description', :string
      attribute 'name', :string
      attribute 'requested_by', :string
      attribute 'owned_by', :string
      attribute 'labels', :string

      # Use string for unsupported types per ActiveResource documentation
      attribute 'created_at', :string
      attribute 'updated_at', :string
      attribute 'notes', :string
    end
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
