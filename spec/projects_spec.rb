require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TaskMapper::Provider::Pivotal::Project" do
  before(:all) do
    headers = {'X-TrackerToken' => '000000'}
    wheaders = headers.merge('Content-Type' => 'application/xml')
    @project_id = 93790
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/services/v3/projects.xml', headers, fixture_for('projects'), 200
      mock.get '/services/v3/projects/93790.xml', headers, fixture_for('projects/93790'), 200
      mock.get '/projects/create.xml', headers, fixture_for('projects/93790'), 200
      mock.put '/services/v3/projects/93790.xml', wheaders, '', 200
      mock.post '/services/v3/projects.xml', wheaders, '', 201, 'Location' => '/projects/create.xml'
    end
  end
  
  before(:each) do
    @taskmapper = TaskMapper.new(:pivotal, :token => '000000')
    @klass = TaskMapper::Provider::Pivotal::Project
  end
  
  it "should be able to load all projects" do
    @taskmapper.projects.should be_an_instance_of(Array)
    @taskmapper.projects.first.should be_an_instance_of(@klass)
  end
  
  it "should be able to load projects from an array of ids" do
    @projects = @taskmapper.projects([@project_id])
    @projects.should be_an_instance_of(Array)
    @projects.first.should be_an_instance_of(@klass)
    @projects.first.id.should == @project_id
  end
  
  it "should be able to load all projects from attributes" do
    @projects = @taskmapper.projects(:id => @project_id)
    @projects.should be_an_instance_of(Array)
    @projects.first.should be_an_instance_of(@klass)
    @projects.first.id.should == @project_id
  end
  
  it "should be able to find a project" do
    @taskmapper.project.should == @klass
    @taskmapper.project.find(@project_id).should be_an_instance_of(@klass)
  end
  
  it "should be able to find a project by id" do
    @taskmapper.project(@project_id).should be_an_instance_of(@klass)
    @taskmapper.project(@project_id).id.should == @project_id
  end
  
  it "should be able to find a project by attributes" do
    @taskmapper.project(:id => @project_id).id.should == @project_id
    @taskmapper.project(:id => @project_id).should be_an_instance_of(@klass)
  end
  
  # always returns true, pivotal doesn't allow updating project attributes
  # (at least not the ones taskmapper cares about at the moment)
  it "should be able to update and save a project" do
    @project = @taskmapper.project(@project_id)
    @project.update!(:name => 'some new name').should == true
    @project.name = 'this is a change'
    @project.save.should == true
  end
  
  it "should be able to create a project" do
    @project = @taskmapper.project.create(:name => 'Project #1')
    @project.should be_an_instance_of(@klass)
  end

end
