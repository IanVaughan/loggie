module Loggie
  class Extract
    # Extracts the payload from the response into a more manageable hash.
    # 1. Converts the JSON into a Hash
    # 2. Strips any empty
    # 3. Updates the timestamp from unix to DateTime
    # 4. Removes fields that are not interesting
    # The full log can contain many fields, most are not that great, so are excluded by default
    #
    # Full response hash includes :
    #  "remote_addr"=>"11.11.11.161",
    #  "request_method"=>"GET",
    #  "path_info"=>"/foo/user",
    #  "query_string"=>"device_id=00000000-0000-0000-0000-000000000000",
    #  "version"=>"HTTP/1.1",
    #  "host"=>"server.com",
    #  "origin"=>nil,
    #  "connection"=>nil,
    #  "proxy_connection"=>nil,
    #  "referer"=>nil,
    #  "x_forwared_for"=>"11.111.232.161",
    #  "x_forwared_proto"=>"https",
    #  "x_forwared_port"=>"443",
    #  "accept"=>"*/*",
    #  "accept_encoding"=>"gzip, deflate",
    #  "accept_language"=>"en-gb",
    #  "content_length"=>nil,
    #  "content_type"=>nil,
    #  "agent"=>"version",
    #  "user_agent"=>"app",
    #  "authorization"=>"bearer token",
    #  "api_version"=>"20161115",
    #  "response_status"=>200,
    #  "response_header"=>{"Content-Type"=>"application/json", "Content-Length"=>"819"},
    #  "response_body" ....
    #  "request_params" ....
    #  "duration"

    DEFAULT_FIELDS_INCLUDED = [
      "request_method", "path_info", "query_string", "agent", "authorization", "response_body", "request_params"
    ]

    def initialize
      @keep_fields = DEFAULT_FIELDS_INCLUDED
    end

    ##
    # @param [Array] results hash from the request
    def call(results)
      return if results.nil?

      results.map do |result|
        formatted_message = format(result["message"])
        next if formatted_message.empty?

        {
          timestamp: formatted_date(result["timestamp"]),
          message: formatted_message
        }
      end.compact
    end

    private

    attr_reader :keep_fields

    def formatted_date(timestamp)
      Time.at(timestamp / 1000).to_datetime
    end

    def format(m)
      m = remove_rails_timestamp(m)
      m = safe_parse(m)
      m = remove_empty_fields(m)
      m.except(*keep_fields)
    end

    def remove_rails_timestamp(message)
      message.sub(/.*-- : /, '')
    end

    def safe_parse(message, save: true)
      begin
        JSON.parse message
      rescue JSON::ParserError
        {}
      end
    end

    def remove_empty_fields(m)
      m.compact.reject { |m| m.empty? }
    end
  end
end
