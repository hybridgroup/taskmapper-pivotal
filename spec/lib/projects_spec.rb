require 'spec_helper'

describe "TaskMapper::Provider::Pivotal::Project" do
  let(:project_id) { 93790 }
  let(:taskmapper) { TaskMapper.new :pivotal, :token => '000000' }
  let(:project_class) { TaskMapper::Provider::Pivotal::Project }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/services/v3/projects.xml', headers, fixture_for('projects'), 200
      mock.get '/services/v3/projects/93790.xml', headers, fixture_for('projects/93790'), 200
      mock.get '/projects/create.xml', headers, fixture_for('projects/93790'), 200
      mock.put '/services/v3/projects/93790.xml', wheaders, '', 200
      mock.post '/services/v3/projects.xml', wheaders, '', 201, 'Location' => '/projects/create.xml'
    end
  end

  it "should be able to load all projects" do
    taskmapper.projects.should be_an_instance_of(Array)
    taskmapper.projects.first.should be_an_instance_of(project_class)
  end

  it "should be able to load projects from an array of ids" do
    projects = taskmapper.projects([project_id])
    projects.should be_an_instance_of(Array)
    projects.first.should be_an_instance_of(project_class)
    projects.first.id.should == project_id
  end

  it "should be able to load all projects from attributes" do
    projects = taskmapper.projects(:id => project_id)
    projects.should be_an_instance_of(Array)
    projects.first.should be_an_instance_of(project_class)
    projects.first.id.should == project_id
  end

  it "should be able to find a project" do
    taskmapper.project.should == project_class
    taskmapper.project.find(project_id).should be_an_instance_of(project_class)
  end

  it "should be able to find a project by id" do
    taskmapper.project(project_id).should be_an_instance_of(project_class)
    taskmapper.project(project_id).id.should == project_id
  end

  it "should be able to find a project by attributes" do
    taskmapper.project(:id => project_id).id.should == project_id
    taskmapper.project(:id => project_id).should be_an_instance_of(project_class)
  end

  # always returns true, pivotal doesn't allow updating project attributes
  # (at least not the ones taskmapper cares about at the moment)
  it "should be able to update and save a project" do
    project = taskmapper.project(project_id)
    project.update!(:name => 'some new name').should == true
    project.name = 'this is a change'
    project.save.should == true
  end

  it "should be able to create a project" do
    project = taskmapper.project.create(:name => 'Project #1')
    project.should be_an_instance_of(project_class)
  end
end
