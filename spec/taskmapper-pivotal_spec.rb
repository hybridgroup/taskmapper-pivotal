require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TaskMapperPivotal" do

  before(:each) do 
    headers = {'X-TrackerToken' => '000000'}
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/services/v3/projects.xml', headers, fixture_for('projects'), 200
    end
    @taskmapper = TaskMapper.new(:pivotal, {:token => '000000'})
  end

  it "should be able to instantiate a new instance" do
    @taskmapper.should be_an_instance_of(TaskMapper)
    @taskmapper.should be_a_kind_of(TaskMapper::Provider::Pivotal)
  end

  it "should return true with valid authentication" do 
    @taskmapper.valid?.should be_true
  end

end
