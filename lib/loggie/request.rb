require 'uri'
require 'net/http'

module Loggie
  # Makes external HTTP request, with a retry mechanism for
  # polling long running queries on remote server
  class Request
    include Logging
    READ_TOKEN = ENV['READ_TOKEN']
    MAX_RETRY = ENV.fetch('MAX_RETRY', 5).to_i

    # NOTE: This actually nests the retry due to POST then GET!
    def call(url, method: :get, options: nil)
      with_retry(MAX_RETRY) do
        request(url, method: method, options: options)
      end
    end

    private

    def with_retry(count, &block)
      @retry_count ||= 0
      response = block.call
      logger.debug "#{self.class} response:#{response.body}"

      if response.code =~ /2../
        res = JSON.parse response.read_body

        if res.key?("events")
          @retry_count = 0
          res["events"]
        else
          @retry_count += 1
          if @retry_count > MAX_RETRY
            message = "Retry count of #{MAX_RETRY} reached"
            logger.error message
            raise message
          end
          call res.fetch("links", [{}]).first.dig("href").gsub(/\?$/, '')
        end
      else
        message = "Failed request with:#{response.message}"
        logger.error message
        raise message
      end
    end

    def request(url, method:, options: nil)
      encoded_options = URI.encode_www_form(options) if options
      url = if method == :get
              URI([url, encoded_options].join("?"))
            else
              URI(url)
            end
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = if method == :get
                  Net::HTTP::Get.new(url)
                else
                  Net::HTTP::Post.new(url)
                end
      request["x-api-key"] = READ_TOKEN

      if method == :post
        request["content-type"] = 'application/json'
        request.body = options.to_json
      end

      http.request(request)
    end
  end
end
