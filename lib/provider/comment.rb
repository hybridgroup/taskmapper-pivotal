module TaskMapper::Provider
  module Pivotal
    class Comment < TaskMapper::Provider::Base::Comment
      API = PivotalAPI::Note

      def initialize(*object)
        super *object
      end

      def body
        self.text
      end

      def body=(string)
        self.text = string
      end

      class << self
        def find_by_id(project_id, ticket_id, id)
          find_by_attributes(project_id, ticket_id, :id => id).first
        end

        def find_by_attributes(project_id, ticket_id, attributes = {})
          search_by_attribute(find_all(project_id, ticket_id), attributes)
        end

        def find_all(project_id, ticket_id)
          PivotalAPI::Note.find(
            :all,
            :params => { :project_id => project_id, :story_id => ticket_id }
          ).collect { |note| self.new note, project_id, ticket_id }
        end

        def create(project_id, ticket_id, attrs = {})
          attrs[:story_id] ||= ticket_id
          attrs[:project_id] ||= project_id
          attrs[:text] ||= (attrs.delete(:body) || attrs.delete('body'))

          note = PivotalAPI::Note.new(attrs)
          note.save

          self.new note, project_id, ticket_id
        end
      end

      private
      def convert_to_comment(note, project_id, story_id)
        attrs = note.attributes.merge({
          :project_id => project_id,
          :story_id => ticket_id
        })
      end
    end
  end
end
