$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'dotenv'
Dotenv.load

require 'loggie'
require 'rspec'
require 'timecop'
require 'vcr'
require 'pry'

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
