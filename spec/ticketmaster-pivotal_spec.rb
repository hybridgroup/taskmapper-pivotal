require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TicketmasterPivotal" do

  before(:each) do 
    headers = {'X-TrackerToken' => '000000'}
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/services/v3/projects.xml', headers, fixture_for('projects'), 200
    end
    @ticketmaster = TicketMaster.new(:pivotal, {:token => '000000'})
  end

  it "should be able to instantiate a new instance" do
    @ticketmaster.should be_an_instance_of(TicketMaster)
    @ticketmaster.should be_a_kind_of(TicketMaster::Provider::Pivotal)
  end

  it "should return true with valid authentication" do 
    @ticketmaster.valid?.should be_true
  end

end
