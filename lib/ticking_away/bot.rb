module TickingAway
  class Bot
    TIMEAT_CMD = '!timeat '.freeze
    TIMEPOPULARITY_CMD = '!timepopularity '.freeze
    DEFAULT_TIME_API = 'http://worldtimeapi.org/api'.freeze
    EXCUSES = [
      'Time is an illusion',
      'What is time, really?',
      'The linear progression of time is currently on hold'
    ].freeze

    attr_reader :storage, :time_api

    # Allow the caller to pass in the storage method via
    # primitive DI. Other storage methods must implement
    # increment_stat(<tz_info>) and get_stat(<tz_info or prefix>)
    def initialize(storage: nil, time_api: nil)
      @storage = storage || TickingAway::JSONFileStorage.new
      @time_api = ENV['TIME_API'] || time_api || DEFAULT_TIME_API
    end

    # Send a string to the Bot in the format of
    # <user_name>: <message>
    # Only !timeat <tz_info> and !timepopularity <tz_info or prefix>
    # commands will return a string response
    def chat(msg)
      case msg.partition(' ')[0]
      when TIMEAT_CMD.strip
        time_check(msg)
      when TIMEPOPULARITY_CMD.strip
        stat_check(msg)
      end
    end

    # Check time for the timezone provided against the
    # provided time api.
    def time_check(msg)
      tz_info = parse_message(msg, TIMEAT_CMD.length)

      puts "Event: Checking Time for timezone: #{tz_info}"

      time_message(tz_info)
    end

    # Return the statistic for the provided tz_info or prefix
    def stat_check(msg)
      storage.get_stat(parse_message(msg, TIMEPOPULARITY_CMD.length))
    end

    private

    # Parse the message for the string after the command.
    # Requires the command length (including the ! and space)
    # to know where to start the substring
    def parse_message(msg, cmd_length)
      msg[cmd_length..msg.length]
    end

    # Generate the time message, returning "unknown location"
    # for any unrecognized time zones and logging any uncaught
    # errors before returning an excuse at random.
    # Stats will only be incremented if the api call was successful
    def time_message(tz_info)
      time = TickingAway::WorldTime.time_at(time_api, tz_info)

      storage.increment_stat(tz_info)
      time.strftime('%e %b %Y %H:%M')
    rescue TickingAway::Errors::UnrecognizedTimeZone => e
      puts e.message
      'unknown timezone'
    rescue => e
      puts e.message
      EXCUSES.sample
    end
  end
end
