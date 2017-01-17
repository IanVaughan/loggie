module Loggie
  module Logentries
    # Allows a block to be retried a number of times up until MAX_RETRY
    # Each retry will sleep RETRY_DELAY_SECONDS before requesting
    # It checks the response and extracts the polling URI for progress
    class Retry
      include Logging
      MAX_RETRY = ENV.fetch('MAX_RETRY', 5).to_i
      RETRY_DELAY_SECONDS = ENV.fetch('RETRY_DELAY_SECONDS', 0.2).to_f
      MAX_RETRY_DELEY_SECONDS = 20 # max 20 seconds, or it will expire

      def call(url, method, options, &block)
        # TODO: ensure retry_count is reset or if that matters
        @retry_count ||= 0
        response = block.call(url, method, options)
        logger.debug "#{self.class} retry:#{@retry_count}, response:#{response.body}"

        if response.code.to_i > 203
          log_and_raise "Failed request with:#{response.message}"
        end

        res = Response.new response
        return res.events if res.events?
        logger.info "Logentries returned progrss:#{res.progress}"

        @retry_count += 1
        if @retry_count > MAX_RETRY
          log_and_raise "Retry count of #{MAX_RETRY} reached"
        end

        sleep RETRY_DELAY_SECONDS

        self.call(res.next_url, :get, nil, &block)
      end

      private

      def log_and_raise(message)
        logger.error message
        raise message
      end
    end
  end
end
