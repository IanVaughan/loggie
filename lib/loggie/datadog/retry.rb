module Loggie
  module Datadog
    class Retry
      include Logging

      MIN_ACCEPTED_SUCCESS_STATUS_CODE = 203

      def initialize(block: nil)
        @retry_count = 0
        @max_retry = Loggie.configuration.max_retry
        @sleep_before_retry_seconds = Loggie.configuration.sleep_before_retry_seconds
        @user_block = block
      end

      def call(url, method, options, &block)
        response = block.call(url, method, options)
        return response if response.code.to_i == 200

        logger.debug("#{self.class} url:#{url}, retry:#{@retry_count += 1}") #, response:#{response.body}"
        raise RetryCountExceededError, "Retry count of #{max_retry} reached" if @retry_count > max_retry

        sleep sleep_before_retry_seconds
        call(url, method, options, &block)
      end

      private

      attr_reader :max_retry, :sleep_before_retry_seconds, :user_block
    end
  end
end
