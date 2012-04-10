require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Pivotal::Ticket" do
  before(:all) do
    headers = {'X-TrackerToken' => '000000'}
    wheaders = headers.merge('Content-Type' => 'application/xml')
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/services/v3/projects/93790.xml', headers, fixture_for('projects/93790'), 200
      mock.get '/services/v3/projects/93790/stories.xml', headers, fixture_for('stories'), 200
      mock.get '/services/v3/projects/93790/stories.xml?filter=', headers, fixture_for('stories'), 200
      mock.get '/services/v3/projects/93790/activities.xml?occurred_since_date=2010%2F06%2F26', headers, fixture_for('activities'), 200
      mock.get '/services/v3/projects/93790/stories.xml?filter=id%3A4056827', headers, fixture_for('stories'), 200
      mock.get '/services/v3/projects/93790/stories/4056827.xml', headers, fixture_for('stories/4056827'), 200
      mock.put '/services/v3/projects/93790/stories/4056827.xml', wheaders, '', 200
      mock.post '/services/v3/projects/93790/stories.xml', wheaders, fixture_for('stories/4056827'), 200

    end
    @project_id = 93790
    @ticket_id = 4056827
  end

  before(:each) do
    @ticketmaster = TicketMaster.new(:pivotal, :token => '000000')
    @project = @ticketmaster.project(@project_id)
    @klass = TicketMaster::Provider::Pivotal::Ticket
  end

  it "should be able to load all tickets" do
    @project.tickets.should be_an_instance_of(Array)
    @project.tickets.first.should be_an_instance_of(@klass)
  end

  it "should be able to load all tickets based on an array of ids" do
    @tickets = @project.tickets([@ticket_id])
    @tickets.should be_an_instance_of(Array)
    @tickets.first.should be_an_instance_of(@klass)
    @tickets.first.id.should == @ticket_id
  end

  it "should be able to load all tickets based on attributes" do
    @tickets = @project.tickets(:id => @ticket_id)
    @tickets.should be_an_instance_of(Array)
    @tickets.first.should be_an_instance_of(@klass)
    @tickets.first.id.should == @ticket_id
  end

  it "should return the ticket class" do
    @project.ticket.should == @klass
  end

  it "should be able to load a single ticket" do
    @ticket = @project.ticket(@ticket_id)
    @ticket.should be_an_instance_of(@klass)
    @ticket.id.should == @ticket_id
  end

  it "should be able to load a single ticket based on attributes" do
    @ticket = @project.ticket(:id => @ticket_id)
    @ticket.should be_an_instance_of(@klass)
    @ticket.id.should == @ticket_id
  end

  it "should be able to update and save a ticket" do
    @ticket = @project.ticket(@ticket_id)
    #@ticket.save.should == nil
    @ticket.description = 'hello'
    @ticket.save.should == true
  end

  it "should be able to create a ticket" do
    @ticket = @project.ticket!(:title => 'Ticket #12', :description => 'Body')
    @ticket.should be_an_instance_of(@klass)
  end

  it "should be able to load all tickets based on attributes using updated_at field" do
    @ticket = @project.ticket(@ticket_id)
    tickets = @project.tickets(:updated_at => @ticket.updated_at)
    tickets.should be_an_instance_of(Array)
    tickets.first.should be_an_instance_of(@klass)
  end

  it "shoule be able to load all tickets based on attributes using created_at field" do
    @ticket = @project.ticket(@ticket_id)
    tickets = @project.tickets(:created_at => @ticket.created_at)
    tickets.should be_an_instance_of(Array)
    tickets.first.should be_an_instance_of(@klass)
  end

  it "should return the requested_by field" do
    @ticket = @project.ticket(@ticket_id)
    @ticket.requestor.should == 'Hong Quach'
  end

  it "should be able to update a ticket" do
    @ticket = @project.ticket(@ticket_id)
    @ticket.title = "Hello World"
    @ticket.save.should be_true
  end

  it "should have all contract fields for tickets" do 
    @ticket = @project.ticket(@ticket_id)
    @ticket.title.should_not be_nil
    @ticket.description.should_not be_nil
    @ticket.status.should_not be_nil
    @ticket.priority.should_not be_nil
    @ticket.resolution.should_not be_nil
    @ticket.created_at.should_not be_nil
    @ticket.updated_at.should_not be_nil
    @ticket.assignee.should_not be_nil
    @ticket.requestor.should_not be_nil
    @ticket.project_id.should_not be_nil
  end

end
