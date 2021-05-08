require 'httparty'

module TickingAway
  # Class to get time from the World Time Api or another Api with the same spec
  class WorldTime
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
          puts "Event: Successfully retreived current time for #{parsed_response['timezone']}: #{parsed_response['datetime']}"
        when 404
          raise TickingAway::Errors::UnrecognizedTimeZone, "Error: 404 response for #{request_url}"
        else
          raise "Error: #{response.code} #{parsed_response}"
        end

        parsed_response
      end
    end
  end
end
