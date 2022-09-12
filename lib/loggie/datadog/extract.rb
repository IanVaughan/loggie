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
    # {
    #   "meta": {
    #     "page": {
    #       "after": "eyJhZnRlciI6IkFRQUFBWU1Qc2FGRE84dUhXd0FBQUFCQldVMVFjMkZKTmtGQlFVWkRRMWxrVW5WTFoxSlJRVVkifQ"
    #     }
    #   },
    #   "data": [
    #     {
    #       "attributes": {
    #         "status": "info",
    #         "service": "out-fund-staging",
    #         "tags": [
    #           "source:heroku",
    #           "source:heroku"
    #         ],
    #         "timestamp": "2022-09-05T22:07:23.730Z",
    #         "host": "host",
    #         "attributes": {
    #           "jid": 1,
    #           "log": {
    #             "level": "INFO"
    #           },
    #           "service": "out-fund-staging",
    #           "format": "json",
    #           "level": "info",
    #           "syslog": {
    #             "procid": "raw-order-transactions-shopify-consumer.1",
    #             "severity": 6,
    #             "appname": "app",
    #             "facility": 23,
    #             "timestamp": "2022-09-05T22:07:23.730171+00:00",
    #             "hostname": "host",
    #             "version": 1,
    #             "prival": 190
    #           },
    #           "offset": 136111,
    #           "message": "{\"name\":\"raw_order_transactions_shopify\",\"version\":\"1.0.0\",\"data\":{\"provider_uid\":\"cliff-side-london.myshopify.com\",\"order_system_id\":\"4928468091099\",\"order_transaction\":{\"id\":137449,\"shopify_integration_account_id\":7,\"shopify_integration_order_id\":119896,\"system_id\":\"5766867484891\",\"status\":\"SUCCESS\",\"kind\":\"SALE\",\"gateway\":\"shopify_payments\",\"test\":false,\"currency\":\"GBP\",\"amount_set\":\"209.0\",\"processed_at\":\"2022-09-05T22:47:28.000+01:00\",\"created_at\":\"2022-09-05T23:07:19.035+01:00\",\"updated_at\":\"2022-09-05T23:07:19.035+01:00\"}}}",
    #           "class": "ShopifyRawOrderTransactionsConsumer"
    #         },
    #         "message": "I, [2022-09-05T22:07:23.730073 #4] INFO -- : {\"message\":\"{\\"name\\":\\"raw_order_transactions_shopify\\",\\"version\\":\\"1.0.0\\",\\"data\\":{\\"provider_uid\\":\\"cliff-side-london.myshopify.com\\",\\"order_system_id\\":\\"4928468091099\\",\\"order_transaction\\":{\\"id\\":137449,\\"shopify_integration_account_id\\":7,\\"shopify_integration_order_id\\":119896,\\"system_id\\":\\"5766867484891\\",\\"status\\":\\"SUCCESS\\",\\"kind\\":\\"SALE\\",\\"gateway\\":\\"shopify_payments\\",\\"test\\":false,\\"currency\\":\\"GBP\\",\\"amount_set\\":\\"209.0\\",\\"processed_at\\":\\"2022-09-05T22: 47: 28.000+01: 00\\",\\"created_at\\":\\"2022-09-05T23: 07: 19.035+01: 00\\",\\"updated_at\\":\\"2022-09-05T23: 07: 19.035+01: 00\\"}}}\",\"offset\":136111,\"class\":\"ShopifyRawOrderTransactionsConsumer\",\"jid\":1,\"format\":\"json\",\"level\":\"info\"}"
    #       },
    #       "type": "log",
    #       "id": "AQAAAYMPsaRSKoN8WgAAAABBWU1Qc2FXbEFBQThVY3Y2YlRPRHl3QUI"
    #     }

    attr_reader :next_url

    def initialize(results)
      @results = results
    end

    def parse
      # @logs = data["data"]
      parsed = JSON.parse(results.read_body)
      @data = parsed["data"]
      @next_url = parsed.dig("links", "next")
      # JSON.parse(results)["data"][0]["attributes"]["attributes"]["message"]
    end

    def messages
      return [] if data.empty?

      data.map do |result|
        begin
          # ["attributes", "type", "id"]
          # attributes => ["status", "service", "tags", "timestamp", "host", "attributes", "message"]
          JSON.parse(result["attributes"]["message"])
        rescue JSON::ParserError => e
          result["attributes"]["message"]
        end
      end.compact
    end

    # def next_url
    #   data.dig("links", "next")
    #   #=> "https://api.datadoghq.eu/api/v2/logs/events?filter%5Bfrom%5D=1661853323787&filter%5Bquery%5D=service%3A%28shopify-sync-staging+OR+out-fund-staging%29+%40class%3AShopifyRawOrderTransactionsConsumer&filter%5Bto%5D=1662458123788&page%5Bcursor%5D=eyJhZnRlciI6IkFRQUFBWU1Qc2FGRE84dUhXd0FBQUFCQldVMVFjMkZKTmtGQlFVWkRRMWxrVW5WTFoxSlJRVVkifQ"
    # end

    private

    attr_reader :results, :data
  end
end
