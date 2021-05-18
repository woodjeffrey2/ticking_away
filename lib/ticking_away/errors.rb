module TickingAway
  module Errors
    # Custom Errors
    class UnrecognizedTimeZone < StandardError; end

    class TimeTravelIsHard < StandardError; end

    class Random5XX < StandardError; end
  end
end
