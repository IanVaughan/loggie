require 'logger'

module Logging
  LOG_LEVEL = ENV.fetch('LOG_LEVEL', :warn).to_sym

  class << self
    def logger
      @logger ||= ::Logger.new(STDOUT).tap { |l| l.level = LOG_LEVEL }
    end

    def logger=(logger)
      @logger = logger
    end
  end

  def self.included(base)
    class << base
      def logger
        Logging.logger
      end
    end
  end

  def logger
    Logging.logger
  end
end
