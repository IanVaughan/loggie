# require 'pry'

# module Loggie
#   module Datadog
#     class Response
#       attr_reader :logs, :data

#       def initialize(response)
#         @data = JSON.parse(response.read_body)
#         @logs = data["data"]
#       end

#       def next_url
#         data["links"]["next"]
#         #=> "https://api.datadoghq.eu/api/v2/logs/events?filter%5Bfrom%5D=1661853323787&filter%5Bquery%5D=service%3A%28shopify-sync-staging+OR+out-fund-staging%29+%40class%3AShopifyRawOrderTransactionsConsumer&filter%5Bto%5D=1662458123788&page%5Bcursor%5D=eyJhZnRlciI6IkFRQUFBWU1Qc2FGRE84dUhXd0FBQUFCQldVMVFjMkZKTmtGQlFVWkRRMWxrVW5WTFoxSlJRVVkifQ"
#       end

#       def events?
#         !@events.nil?
#       end
#     end
#   end
# end
