require 'dotenv'
Dotenv.load

require 'active_support/all'
Time.zone = 'Europe/London'

require "loggie/version"
require "loggie/logging"

require "loggie/extract"
require "loggie/request"

require "loggie/logentries/search"

require 'pry'

module Loggie
  def self.search(query:, from: 1.week.ago, to: Time.zone.now)
    Logentries::Search.new(query: query, from: from, to: to).call
  end
end
