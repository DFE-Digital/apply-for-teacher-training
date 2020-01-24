# Load the Rails application.
require_relative 'application'

# Avoid constant autoloading in initializers deprecation warnings
require './app/lib/logstash_logging'
require './app/warden/magic_link_strategy'

# Initialize the Rails application.
Rails.application.initialize!
