require 'httparty'
require 'time'

module TickingAway
  # Class to get time from the World Time Api or another Api with the same spec
  class WorldTime
    UNKNOWN_TIME_ZONE_RESPONSE = {
      'error' => 'unknown location'
    }.freeze

    class << self
      def time_at(base_url, tz_info)
        request_url = "#{base_url}/timezone/#{tz_info}"

        response = HTTParty.get(request_url)
        handle_response(response, request_url)
      rescue => e
        puts "Could not connect to time server #{request_url}"
        raise e
      end

      def handle_response(response, request_url)
        # Convert JSON response to Hash, handling an empty or nil body
        parsed_response = response.body.nil? || response.body.empty? ? {} : JSON.parse(response.body)

        case response.code
        when 200
          puts "Event: Retreived current time for #{parsed_response['timezone']}: #{parsed_response['datetime']}"
        when 404
          # Differentiate between an unknown time zone and a random 404
          if parsed_response.eql?(UNKNOWN_TIME_ZONE_RESPONSE)
            raise TickingAway::Errors::UnrecognizedTimeZone, "Error: Unrecognized Time Zone #{request_url}"
          end

          raise TickingAway::Errors::UrlNotFound, "Error: 404 response for #{request_url}"
        else
          raise "Error: #{response.code} #{parsed_response}"
        end

        time_string = parsed_response['datetime']
        # DateTime.strptime(time_string.gsub(' =>', ''), "%FT%T.%6N%:z")
        Time.parse(time_string)
      end
    end
  end
end
