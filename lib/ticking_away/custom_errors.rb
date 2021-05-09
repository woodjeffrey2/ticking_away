module TickingAway
  module Errors
    # Custom Errors
    class UnrecognizedTimeZone < StandardError; end
    class ApiUrlNotFound < StandardError; end
  end
end
