require 'httparty'
require 'time'
require 'json'

module TickingAway
  # Class to get time from the World Time Api or another Api with the same spec
  class WorldTime
    UNKNOWN_LOCATION_RESPONSE = {
      'error' => 'unknown location'
    }.freeze

    # Define methods as (kind of) Class methods since we don't need to store state
    class << self
      def time_at(base_url, tz_info)
        request_url = "#{base_url}/timezone/#{tz_info}"

        response = call_api(request_url)
        handle_response(response, request_url)
      end

      def call_api(request_url)
        HTTParty.get(request_url)
      rescue => e
        raise TickingAway::Errors::TimeTravelIsHard, e.message
      end

      def handle_response(response, request_url)
        # Convert JSON response to Hash, handling an empty or nil body
        parsed_response = parse_response(response.body)

        case response.code
        when 200
          raise TickingAway::Errors::UnrecognizedTimeZone, 'Error: non-time response' unless parsed_response.is_a?(Hash)

          puts "Event: Retreived current time for #{parsed_response['timezone']}: #{parsed_response['datetime']}"
        when 404
          # Differentiate between an unknown location response and a random 404 by checking the response body
          if parsed_response.eql?(UNKNOWN_LOCATION_RESPONSE)
            raise TickingAway::Errors::UnrecognizedTimeZone, "Error: Unrecognized Time Zone #{request_url}"
          end

          raise TickingAway::Errors::TimeTravelIsHard, "Error: 404 response for #{request_url}"
        else
          raise TickingAway::Errors::TimeTravelIsHard, "Error: #{response.code} #{parsed_response}"
        end

        # Convert the time from a RFC3339 formatted string to a Time object
        Time.parse(parsed_response['datetime'])
      end

      def parse_response(body)
        JSON.parse(body)
      rescue => e
        raise TickingAway::Errors::TimeTravelIsHard, e.message
      end
    end
  end
end
