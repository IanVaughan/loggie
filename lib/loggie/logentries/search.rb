module Loggie
  module Logentries
    # Main entry point to query a specific log source
    class Search
      include Logging
      BASE_URI = "https://rest.logentries.com"
      QUERY_PATH = "query/logs"

      ##
      # @param [String] query: to perform
      # @param [DateTime] from: query from date
      # @param [DateTime] to: query to date
      # @param [Array] log_files: list of log id files to search. default ENV['LOG_FILES']
      #
      def initialize(query: nil, from: nil, to: nil, log_files: nil, block: nil)
        @query, @from, @to = query, from, to
        @log_files = log_files || Loggie.configuration.log_files
        @extract = Extract.new
        @request = Request.new(retry_mechanism: Retry.new(block: block))
      end

      def call(query: nil, from: nil, to: nil, log_files: nil)
        options = parsed_post_params(query || @query, from || @from, to || @to, log_files || @log_files)
        logger.debug "#{self.class} options:#{options}, url:#{url}"

        extract.call(request.call(url, method: :post, options: options))
      end

      private

      attr_reader :extract, :request

      def url
        [BASE_URI, QUERY_PATH].join('/')
      end

      # https://docs.logentries.com/docs/post-query
      def parsed_post_params(query, from, to, log_keys)
        {
          logs: log_keys,
          leql: {
            during: {
              from: convert(from),
              to: convert(to)
            },
            statement: "where(#{query})"
          }
        }
      end

      def convert(time)
        (time.to_f * 1000).floor
      end
    end
  end
end
