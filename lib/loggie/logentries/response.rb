module Loggie
  module Logentries
    class Response
      attr_reader :logs, :progress, :links, :id, :leql, :events

      def initialize(response)
        data = JSON.parse response.read_body

        @logs = data["logs"]
        @links = data["links"]
        @leql = data["leql"]

        if data.key?("events") # 200
          @events = data["events"]
        else # 202 for a query that successfully started but has not yet finished
          @progress = data["progress"]
          @id = data["id"]
        end
      end

      def next_url
        # res.fetch("links", [{}]).first.dig("href").gsub(/\?$/, '')
        links.first["href"]
      end

      def events?
        !@events.nil?
      end
    end
  end
end
