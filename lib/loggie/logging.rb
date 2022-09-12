require 'logger'

module Loggie
  module Logging
    class << self
      def logger
        @logger ||= ::Logger.new(STDOUT).tap { |l| l.level = Loggie.configuration.log_level }
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
end
