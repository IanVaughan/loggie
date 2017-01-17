require 'uri'
require 'net/http'

module Loggie
  # Makes external HTTP request, with a retry mechanism for
  # polling long running queries on remote server
  class Request
    include Logging
    READ_TOKEN = ENV['READ_TOKEN']

    def initialize(retry_mechanism: )
      @retry_mechanism = retry_mechanism || Retry.new
    end

    def call(url, method: :get, options: nil)
      retry_mechanism.call(url, method, options) do |url, method, options|
        request(url, method: method, options: options)
      end
    end

    private

    attr_reader :retry_mechanism

    def request(url, method:, options: nil)
      encoded_options = URI.encode_www_form(options) if options

      url = if method == :get
              URI([url, encoded_options].compact.join("?"))
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
