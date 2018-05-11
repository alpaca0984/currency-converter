require 'net/http'
require 'json'
require 'date'

require 'active_model'
require 'active_support/core_ext'

module Config
  autoload :Secrets, './config/secrets'
end
