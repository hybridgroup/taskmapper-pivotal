require 'taskmapper-pivotal'
require 'active_resource/http_mock'
require 'rspec'

RSpec.configure do |config|
  config.color_enabled = true
end

def fixture_for(name)
  File.read(File.dirname(__FILE__) + '/fixtures/' + name + '.xml')
end

def headers
  { 'X-TrackerToken' => '000000' }
end

def wheaders
  headers.merge('Content-Type' => 'application/xml')
end
