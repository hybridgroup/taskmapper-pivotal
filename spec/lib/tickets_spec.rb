require 'spec_helper'

describe "TaskMapper::Provider::Pivotal::Ticket" do
  let(:project_id) { 93790 }
  let(:ticket_id) { 4056827 }
  let(:taskmapper) { TaskMapper.new :pivotal, :token => '000000' }
  let(:project) { taskmapper.project project_id }
  let(:ticket_class) { TaskMapper::Provider::Pivotal::Ticket }

  before do
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
  end

  describe "#tickets" do
    context "with no arguments" do
      let(:tickets) { project.tickets }

      it "returns an array of all tickets" do
        expect(tickets).to be_an Array
        expect(tickets.first).to be_a ticket_class
      end
    end

    context "with an array of ticket IDs" do
      let(:tickets) { project.tickets [ticket_id] }

      it "returns an array containing the requested tickets" do
        expect(tickets).to be_an Array
        expect(tickets.first).to be_a ticket_class
        expect(tickets.first.id).to eq ticket_id
      end
    end

    context "with a hash containing a ticket ID" do
      let(:tickets) { project.tickets :id => ticket_id }

      it "returns an array containing the requested ticket" do
        expect(tickets).to be_an Array
        expect(tickets.first).to be_a ticket_class
        expect(tickets.first.id).to eq ticket_id
      end
    end
  end

  describe "#ticket" do
    context "with no arguments" do
      it "returns the ticket class" do
        expect(project.ticket).to eq ticket_class
      end
    end

    context "with a ticket ID" do
      let(:ticket) { project.ticket ticket_id }

      it "returns the requested ticket" do
        expect(ticket).to be_a ticket_class
        expect(ticket.id).to eq ticket_id
      end

      it "returns the requested_by field" do
        expect(ticket.requestor).to eq 'Hong Quach'
      end
    end
  end

  describe "#save" do
    let(:ticket) { project.ticket ticket_id }
    it "updates the ticket" do
      ticket.description = 'hello'
      ticket.labels = 'sample label'

      expect(ticket.save).to be_true

      expect(ticket.labels).to eq 'sample label'
      expect(ticket.description).to eq 'hello'
    end
  end

  describe "#ticket!" do
    context "with new ticket params" do
      let(:ticket) do
        project.ticket!(
          :title => "Ticket #12",
          :description => "Body"
        )
      end

      it "creates a new ticket" do
        expect(ticket).to be_a ticket_class
      end
    end
  end

  describe "fields" do
    let(:ticket) { project.ticket ticket_id }
    it "should match the contract" do
      expect(ticket).to respond_to(:title)
      expect(ticket).to respond_to(:description)
      expect(ticket).to respond_to(:status)
      expect(ticket).to respond_to(:priority)
      expect(ticket).to respond_to(:resolution)
      expect(ticket).to respond_to(:created_at)
      expect(ticket).to respond_to(:updated_at)
      expect(ticket).to respond_to(:assignee)
      expect(ticket).to respond_to(:requestor)
      expect(ticket).to respond_to(:project_id)
    end
  end
end
