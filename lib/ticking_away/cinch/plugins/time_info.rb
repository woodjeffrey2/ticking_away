require 'cinch'

module TickingAway
# Plugin to add !timeat and !timepopularity commands
# to a Cinch IRC chat bot
class TimeInfo
  include ::Cinch::Plugin

  DEFAULT_TIME_API = 'http://worldtimeapi.org/api'.freeze
  EXCUSES = [
    'Time is an illusion',
    'What is time, really?',
    'The linear progression of time is currently on hold'
  ].freeze

  match /timeat */, method: :time_check
  match /timepopularity */, method: :stat_check

  listen_to :connect, method: :on_connect

  def on_connect(*)
    @stat_file = TickingAway::JSONFileStorage.new
  end

  def time_check(msg)
    tz_info = parse_message(msg, 8)

    puts "Event: Checking Time for timezone: #{tz_info}"

    @stat_file.increment_stat(tz_info)
    msg.reply time_message(tz_info)
  end

  def stat_check(msg)
    msg.reply @stat_file.get_stat(parse_message(msg, 16))
  end

  private

  def parse_message(msg, cmd_length)
    message = msg.params[1]
    message[cmd_length..message.length]
  end

  def base_url
    ENV['TIME_API'] || DEFAULT_TIME_API
  end

  def time_message(tz_info)
    time = TickingAway::WorldTime.time_at(base_url, tz_info)

    "Current time is: #{time['datetime']}"
  rescue TickingAway::Errors::UnrecognizedTimeZone => e
    puts e.message
    "Sorry, but I do not know where \"#{tz_info}\" is. Are you sure you're still on Earth?"
  rescue => e
    puts e.message
    EXCUSES.sample
  end
end
end
