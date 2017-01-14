module Loggie
  class Extract
    # The full log contains many fields, most are excluded by default
    # "remote_addr"=>"85.255.232.161",
    # "request_method"=>"GET",
    # "path_info"=>"/customer/user",
    # "query_string"=>"device_id=00000000-0000-0000-0000-000000000000",
    # "version"=>"HTTP/1.1",
    # "host"=>"api.quiqup.com",
    # "origin"=>nil,
    # "connection"=>nil,
    # "proxy_connection"=>nil,
    # "referer"=>nil,
    # "x_forwared_for"=>"85.255.232.161",
    # "x_forwared_proto"=>"https",
    # "x_forwared_port"=>"443",
    # "accept"=>"*/*",
    # "accept_encoding"=>"gzip, deflate",
    # "accept_language"=>"en-gb",
    # "content_length"=>nil,
    # "content_type"=>nil,
    # "agent"=>"QU/IOS/Customer/1.7.2",
    # "user_agent"=>"QUVoila/1358 CFNetwork/808.2.16 Darwin/16.3.0",
    # "authorization"=>"bearer c0c1d3570376a936df3fd5dfa8b9cf7ceb9925b44746d3623cae01770e545807",
    # "api_version"=>"20161115",
    # "response_status"=>200,
    # "response_header"=>{"X-QueueTimeSeconds"=>"0", "Content-Type"=>"application/json", "Content-Length"=>"819"},
    # "response_body" ....
    # "request_params" ....
    # "duration"

    DEFAULT_KEEP_FIELDS = [
      "request_method", "path_info", "query_string", "agent", "authorization", "response_body", "request_params"
    ]

    def self.call(result, keep = DEFAULT_KEEP_FIELDS)
      return if result.nil?

      result.map do |r|
        m = format(r["message"], keep)
        next if m.empty?

        {
          timestamp: Time.at(r["timestamp"] / 1000).to_datetime,
          message: m
        }
      end.compact
    end

    def self.format(m, keep)
      m = remove_rails_timestamp(m)
      m = safe_parse(m)
      m = remove_empty_fields(m)
      m.except(*keep)
    end

    def self.remove_rails_timestamp(message)
      message.sub(/.*-- : /, '')
    end

    def self.safe_parse(message, save: true)
      begin
        JSON.parse message
      rescue JSON::ParserError
        # if save
        #   @message ||= []
        #   @message << message
        #
        #   res = safe_parse(@message.join, save: false)
        #   @message = [] if !res.empty?
        # end
        {}
      end
    end

    def self.remove_empty_fields(m)
      m.compact.reject { |m| m.empty? }
    end
  end
end
