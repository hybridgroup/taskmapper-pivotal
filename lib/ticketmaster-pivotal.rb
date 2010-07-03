require File.dirname(__FILE__) + '/pivotal/pivotal-api'

%w{ pivotal ticket project comment }.each do |f|
  require File.dirname(__FILE__) + '/provider/' + f + '.rb';
end

