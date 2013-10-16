require 'taskmapper'

require 'pivotal/pivotal-api'

# Monkey patch for backward compatibility issue with type cast on xml response
class Hash
  class << self
    alias_method :from_xml_original, :from_xml

    def from_xml(xml)
      scrubbed = scrub_attributes(xml)
      from_xml_original(scrubbed)
    end

    def scrub_attributes(xml)
      xml.gsub(/<stories.*>/, "<stories type=\"array\">")
    end
  end
end

require 'provider/pivotal'
require 'provider/ticket'
require 'provider/project'
require 'provider/comment'
require 'provider/version'
