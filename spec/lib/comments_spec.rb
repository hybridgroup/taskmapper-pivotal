require 'spec_helper'

describe "TaskMapper::Provider::Pivotal::Comment" do
  let(:project_id) { 93790 }
  let(:ticket_id) { 4056827 }
  let(:comment_id) { 1946635 }
  let(:taskmapper) { TaskMapper.new :pivotal, :token => '000000' }
  let(:project) { taskmapper.project project_id }
  let(:ticket) { project.ticket 4056827 }
  let(:comment_class) { TaskMapper::Provider::Pivotal::Comment }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/services/v3/projects/93790.xml', headers, fixture_for('projects/93790'), 200
      mock.get '/services/v3/projects/93790/stories.xml', headers, fixture_for('stories'), 200
      mock.get '/services/v3/projects/93790/stories.xml?filter=', headers, fixture_for('stories'), 200
      mock.get '/services/v3/projects/93790/stories/4056827.xml', headers, fixture_for('stories/4056827'), 200
      mock.get '/services/v3/projects/93790/stories/4056827/notes.xml', headers, fixture_for('notes'), 200
      mock.get '/services/v3/projects/93790/stories/4056827/notes/1946635.xml', headers, fixture_for('notes/1946635'), 200
      mock.post '/services/v3/projects/93790/stories/4056827/notes.xml', wheaders, fixture_for('notes/1946635'), 200
      mock.put '/services/v3/projects/93790/stories/4056827.xml', wheaders, '', 200
    end
  end

  describe "#comments" do
    context "with no arguments" do
      let(:comments) { ticket.comments }

      it "returns an array containing all comments" do
        expect(comments).to be_an Array
        expect(comments.first).to be_a comment_class
      end
    end

    context "with an array of comment IDs" do
      let(:comments) { ticket.comments [comment_id] }

      it "returns an array of the matching comments" do
        expect(comments).to be_an Array
        expect(comments.first).to be_a comment_class
        expect(comments.first.id).to eq comment_id
      end
    end

    context "with a hash containing a comment ID" do
      let(:comments) { ticket.comments :id => comment_id }

      it "returns an array containing the matching comment" do
        expect(comments).to be_an Array
        expect(comments.first).to be_a comment_class
        expect(comments.first.id).to eq comment_id
      end
    end
  end

  describe "#comment" do
    context "with a comment ID" do
      let(:comment) { ticket.comment comment_id }

      it "returns the requested comment" do
        expect(comment).to be_a comment_class
        expect(comment.id).to eq comment_id
      end
    end

    context "with a hash of comment attributes" do
      let(:comment) { ticket.comment :id => comment_id }

      it "returns the requested comment" do
        expect(comment).to be_a comment_class
        expect(comment.id).to eq comment_id
      end
    end

    context "without arguments" do
      it "returns the class" do
        expect(ticket.comment).to eq comment_class
      end
    end
  end

  describe "#comment!" do
    context "with a new comment body" do
      let(:comment) { ticket.comment! :body => "note" }

      it "creates a new comment" do
        expect(comment).to be_a comment_class
        expect(comment.body).to eq "note"
      end
    end
  end
end
