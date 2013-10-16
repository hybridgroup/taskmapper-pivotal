require 'spec_helper'

describe "TaskMapperPivotal" do
  let(:taskmapper) { TaskMapper.new :pivotal, {:token => '000000'} }

  describe "#new" do
    it "creates a new TaskMapper instance" do
      expect(taskmapper).to be_a TaskMapper
    end

    it "can be explicitly called as a provider" do
      taskmapper = TaskMapper::Provider::Pivotal.new(
        :token => '000000'
      )
      expect(taskmapper).to be_a TaskMapper
    end
  end

  describe "#valid?" do
    context "with a correctly authenticated Pivotal API account" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get '/services/v3/projects.xml', headers, fixture_for('projects'), 200
        end
      end

      it "returns true" do
        expect(taskmapper.valid?).to be_true
      end
    end
  end
end
