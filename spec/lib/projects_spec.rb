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

  describe "#projects" do
    context "without params" do
      let(:projects) { taskmapper.projects }

      it "returns an array of all projects" do
        expect(projects).to be_an Array
        expect(projects.first).to be_a project_class
      end
    end

    context "with an array of IDs" do
      let(:projects) { taskmapper.projects [project_id] }

      it "returns an array of matching projects" do
        expect(projects).to be_an Array
        expect(projects.first).to be_a project_class
        expect(projects.first.id).to eq project_id
      end
    end

    context "with a hash containing an ID" do
      let(:projects) { taskmapper.projects :id => project_id }

      it "returns an array containing the matching project" do
        expect(projects).to be_an Array
        expect(projects.first).to be_a project_class
        expect(projects.first.id).to eq project_id
      end
    end
  end

  describe "#project" do
    context "with a project ID" do
      let(:project)  { taskmapper.project project_id }

      it "returns the requested project" do
        expect(project).to be_a project_class
        expect(project.id).to eq project_id
      end
    end

    context "with a hash containing a project ID" do
      let(:project)  { taskmapper.project :id => project_id }

      it "returns the requested project" do
        expect(project).to be_a project_class
        expect(project.id).to eq project_id
      end
    end

  end

  describe "#find" do
    let(:project) { taskmapper.project }

    it "finds a project by it's ID" do
      expect(project).to eq project_class
      expect(project.find(project_id)).to be_a project_class
      expect(project.find(project_id).id).to eq project_id
    end
  end

  describe "#create" do
    let(:project) { taskmapper.project.create :name => 'Project #1' }

    context "with a project name" do
      it "creates a new project" do
        expect(project).to be_a project_class
      end
    end
  end
end
