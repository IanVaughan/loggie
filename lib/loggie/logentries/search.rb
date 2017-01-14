module Loggie
  module Logentries
    class Search
      include Logging
      BASE_URI = "https://rest.logentries.com"
      QUERY_PATH = "query/logs"
      LOG_FILES = ENV['LOG_FILES'].split(",")

      def initialize(query:, from:, to:)
        @query, @from, @to = query, from, to
      end

      def call(query: nil, from: nil, to: nil)
        options = parsed_post_params(LOG_FILES, query || @query, from || @from, to || @to)
        logger.debug "#{self.class} options:#{options}, url:#{url}"

        Extract.(Request.(url, method: :post, options: options))
      end

      private

      def url
        [BASE_URI, QUERY_PATH].join('/')
      end

      # https://docs.logentries.com/docs/post-query
      def parsed_post_params(log_keys, query, from, to)
        {
          # Array of Logentries log keys
          logs: log_keys,
          leql: {
            during: {
              from: (from.to_f * 1000).floor,
              to: (to.to_f * 1000).floor
            },
            statement: "where(#{query})"
          }
        }
      end
    end
  end
end
