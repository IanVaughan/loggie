module Loggie
  # res = Retry.call( -> { Request.call(url, options) })
  class Logentries
    class Retry
      def call(_proc)
        @count ||= 0
        result = _proc.call

        if result.key?("events")
          results["events"]
        else
          @count += 1
          self.call result.fetch("links", [{}]).first.dig("href")
        end
      end
    end
  end
end
