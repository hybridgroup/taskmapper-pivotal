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

  it "should be able to load all comments" do
    comments = ticket.comments
    comments.should be_an_instance_of(Array)
    comments.first.should be_an_instance_of(comment_class)
  end

  it "should be able to load all comments based on 'id's" do
    comments = ticket.comments([comment_id])
    comments.should be_an_instance_of(Array)
    comments.first.should be_an_instance_of(comment_class)
    comments.first.id.should == comment_id
  end

  it "should be able to load all comments based on attributes" do
    comments = ticket.comments(:id => comment_id)
    comments.should be_an_instance_of(Array)
    comments.first.should be_an_instance_of(comment_class)
  end

  it "should be able to load a comment based on id" do
    comment = ticket.comment(comment_id)
    comment.should be_an_instance_of(comment_class)
    comment.id.should == comment_id
  end

  it "should be able to load a comment based on attributes" do
    comment = ticket.comment(:id => comment_id)
    comment.should be_an_instance_of(comment_class)
  end

  it "should return the class" do
    ticket.comment.should == comment_class
  end

  it "should be able to create a comment" do # which as mentioned before is technically a ticket update
    comment = ticket.comment!(:body => 'hello there boys and girls')
    comment.should be_an_instance_of(comment_class)
  end
end
