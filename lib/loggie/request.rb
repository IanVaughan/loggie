require 'uri'
require 'net/http'

module Loggie
  class Request
    include Logging
    READ_TOKEN = ENV['READ_TOKEN']
    MAX_RETRY = ENV.fetch('MAX_RETRY', 5).to_i

    def self.call(url, method: :get, options: nil)
      with_retry(MAX_RETRY) do
        request(url, method: method, options: options)
      end
    end

    def self.with_retry(count, &block)
      @retry_count ||= 0
      response = block.call

      if response.code =~ /2../
        res = JSON.parse response.read_body

        if res.key?("events")
          @retry_count = 0
          res["events"]
        else
          @retry_count += 1
          raise "Retry count of #{MAX_RETRY} reached" if @retry_count > MAX_RETRY
          call res.fetch("links", [{}]).first.dig("href")
        end
      else
        raise response.message
      end
    end

    def self.request(url, method:, options: nil)
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

      response = http.request(request)
    end
  end
end
