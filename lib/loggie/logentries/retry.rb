module Loggie
  module Logentries
    # Allows a block to be retried a number of times up until MAX_RETRY
    # Each retry will sleep RETRY_DELAY_SECONDS before requesting
    # It checks the response and extracts the polling URI for progress
    class Retry
      include Logging

      class RetryError < RuntimeError; end
      class RetryCountExceededError < RetryError; end
      class RetryResponseError < RetryError; end

      MIN_ACCEPTED_SUCCESS_STATUS_CODE = 203

      def initialize(block: nil)
        @retry_count = 0
        @max_retry = Loggie.configuration.max_retry
        @sleep_before_retry_seconds = Loggie.configuration.sleep_before_retry_seconds
        @user_block = block
      end

      def call(url, method, options, &block)
        @retry_count ||= 0
        response = block.call(url, method, options)
        logger.debug "#{self.class} retry:#{@retry_count}, response:#{response.body}"

        if response.code.to_i > MIN_ACCEPTED_SUCCESS_STATUS_CODE
          raise RetryCountExceededError, "Failed request with:#{response.message}"
        end

        res = Response.new response
        return res.events if res.events?
        logger.debug "Logentries returned progress:#{res.progress}"
        user_block.call(res.progress) if user_block

        @retry_count += 1
        if @retry_count > max_retry
          raise RetryCountExceededError, "Retry count of #{max_retry} reached"
        end

        sleep sleep_before_retry_seconds

        self.call(res.next_url, :get, nil, &block)

      rescue RetryError => e
        logger.error e.message
        nil
      end

      private

      attr_reader :max_retry, :sleep_before_retry_seconds, :user_block
    end
  end
end
