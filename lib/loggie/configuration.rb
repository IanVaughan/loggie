module Loggie
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    MAX_RETRY_DELEY_SECONDS = 20.0 # max 20 seconds, or it will expire

    attr_accessor :read_token
    attr_accessor :log_files
    attr_accessor :max_retry
    attr_accessor :log_level
    attr_accessor :sleep_before_retry_seconds
    attr_accessor :default_fields_included

    def initialize
      @max_retry = 50
      @log_level = :info
      @sleep_before_retry_seconds = 0.5
      @default_fields_included = [
        "request_method", "path_info", "query_string", "agent", 
        "authorization", "response_body", "request_params"
      ]
    end

    def valid?
      sleep_before_retry_seconds.to_f < MAX_RETRY_DELEY_SECONDS
    end
  end
end
