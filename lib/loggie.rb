require 'active_support/all'
Time.zone = 'Europe/London'

require "version"
require "./lib/loggie/logging"
require './lib/loggie/configuration'

require "./lib/loggie/datadog/extract"
require "./lib/loggie/datadog/request"
require "./lib/loggie/datadog/search"
require "./lib/loggie/datadog/retry"
require "./lib/loggie/datadog/response"

module Loggie
  def self.search(query:, from: 1.week.ago, to: Time.zone.now, &block)
    configure
    Loggie.configuration.provider::Search.new(query: query, from: from, to: to, block: block).call
  end
end
