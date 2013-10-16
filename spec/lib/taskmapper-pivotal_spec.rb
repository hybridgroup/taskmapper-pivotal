require 'spec_helper'

describe "TaskMapperPivotal" do
  let(:taskmapper) { TaskMapper.new :pivotal, {:token => '000000'} }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/services/v3/projects.xml', headers, fixture_for('projects'), 200
    end
  end

  it "should be able to instantiate a new instance" do
    taskmapper.should be_an_instance_of(TaskMapper)
    taskmapper.should be_a_kind_of(TaskMapper::Provider::Pivotal)
  end

  it "should return true with valid authentication" do
    taskmapper.valid?.should be_true
  end
end
