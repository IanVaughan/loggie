require 'uri'
require "json"
require 'net/http'

module Loggie
  class Request
    include Logging

    def call(url, method: :get, options: nil)
      encoded_options = URI.encode_www_form(options) if options

      url = (method == :get) ? URI([url, encoded_options].compact.join("?")) : URI(url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = method == :get ? Net::HTTP::Get.new(url) : Net::HTTP::Post.new(url)
      request["x-api-key"] = Loggie.configuration.read_token if Loggie.configuration.read_token.present?
      request["DD-API-KEY"] = Loggie.configuration.api_key if Loggie.configuration.api_key.present?
      request["DD-APPLICATION-KEY"] = Loggie.configuration.app_key if Loggie.configuration.app_key.present?

      if method == :post
        request["Content-Type"] = 'application/json'
        request.body = JSON.dump(options)
      end

      http.request(request)
    end
  end
end
