module TaskMapper::Provider
  module Pivotal
    # The comment class for taskmapper-pivotal
    # * author
    # * body => text
    # * id => position in the versions array (set by the initializer)
    # * created_at => noted_at
    # * updated_at => noted_at
    # * ticket_id (actually the story id)
    # * project_id
    class Comment < TaskMapper::Provider::Base::Comment
      # A custom find_by_id
      # The "comment" id is it's index in the versions array. An id of 0 therefore exists and
      # should be the first ticket (original)
      def self.find_by_id(project_id, ticket_id, id)
        self.new(project_id, ticket_id, PivotalTracker::Note.find(id, :params => {:project_id => project_id, :story_id => ticket_id}))
      end

      # A custom find_by_attributes
      #
      def self.find_by_attributes(project_id, ticket_id, attributes = {})
        self.search(project_id, ticket_id, attributes).collect { |comment| self.new(project_id, ticket_id, comment) }
      end

      # A custom searcher
      #
      # It returns a custom result because we need the original story to make a comment.
      def self.search(project_id, ticket_id, options = {}, limit = 1000)
        comments = PivotalTracker::Note.find(:all, :params => {:project_id => project_id, :story_id => ticket_id})
        search_by_attribute(comments, options, limit)
      end

      # A custom creator
      # We didn't really need to do much other than change the :ticket_id attribute to :story_id
      def self.create(project_id, ticket_id, *options)
        first = options.first
        first[:story_id] ||= ticket_id
        first[:project_id] ||= project_id
        first[:text] ||= first.delete(:body) || first.delete('body')
        note = PivotalTracker::Note.new(first)
        note.save
        self.new(project_id, ticket_id, note)
      end

      def initialize(project_id, ticket_id, *object)
        if object.first
          object = object.first
          unless object.is_a? Hash
            hash = {:id => object.id,
                    :body => object.text,
                    :update_at => object.noted_at,
                    :created_at => object.noted_at,
                    :project_id => project_id,
                    :ticket_id => ticket_id
                    }
          else
            hash = object
          end
          super hash
        end
      end

      def body=(bod)
        self.text = bod
      end
    end
  end
end
