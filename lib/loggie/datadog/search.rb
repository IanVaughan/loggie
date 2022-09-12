require 'pry'

module Loggie
  module Datadog
    class Search
      include Logging
      BASE_URI = "https://api.datadoghq.eu/api/v2/logs"
      QUERY_PATH = "events/search"

      ##
      # @param [String] query: to perform
      # @param [DateTime] from: query from date
      # @param [DateTime] to: query to date
      # @param [Array] log_files: list of log id files to search. default ENV['LOG_FILES']
      #
      def initialize(query: nil, from: nil, to: nil, log_files: nil, block: nil)
        @query, @from, @to = query, from, to
        @log_files = log_files || Loggie.configuration.log_files
        @request = Request.new
        @extracts = []
        @request_delay_seconds = Loggie.configuration.sleep_before_retry_seconds
      end

      def call(query: nil, from: nil, to: nil)
        options = parsed_post_params(query || @query, from || @from, to || @to)
        make_request(url, method: :post, options: options)
        extracts.flat_map(&:messages)
      end

      private

      attr_reader :request, :extracts, :request_delay_seconds

      def make_request(url, method: :get, options: nil)
        response = Retry.new.call(url, method, options) do
          logger.debug "#{self.class} options:#{options}, url:#{url}, sleep:#{request_delay_seconds}"
          request.call(url, method: method, options: options)
        end
        extract = Extract.new(response)
        extract.parse
        extracts << extract
        sleep request_delay_seconds
        make_request(extract.next_url) if extract.next_url
      end

      def url
        [BASE_URI, QUERY_PATH].join('/')
      end

      def parsed_post_params(query, from, to)
        {
          "filter": {
            "from": convert(from),
            "to": convert(to),
            "query": query
          }
        }
      end

      def convert(time)
        (time.to_f * 1000).floor
      end
    end
  end
end
