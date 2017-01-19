$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'loggie'
require 'rspec'
require 'timecop'
require 'vcr'
require 'pry'

Loggie.configure do |c|
  c.read_token = 'bf3b4d32'
  c.log_files = ['e20bd6af','c83c7cd7','6fb426fd','776dfea9']
  c.log_level = :debug
end

RSpec.configure do |config|
  config.expose_dsl_globally = false
end

VCR.configure do |c|
  c.default_cassette_options = { record: :new_episodes }
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.configure_rspec_metadata!
end
