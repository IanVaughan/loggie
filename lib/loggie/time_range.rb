module Loggie
  class TimeRange
    def initialize

    end

    def to_unix
      {
        from: from,
        to: to
      }
    end
  end
end
