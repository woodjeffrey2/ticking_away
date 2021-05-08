require 'cinch'

class TimeInfo
  include Cinch::Plugin

  DEFAULT_TIME_API = 'http://worldtimeapi.org/api'.freeze
  EXCUSES = [
    'Time is an illusion',
    'What is time, really?',
    'The linear progression of time is currently on hold'
  ].freeze

  match %r{timeat */*}, method: :time_check
  match 'hello', method: :hello

  def time_check(msg)
    # Parse the message for the timezone
    msg_cmd = msg.params[1]
    tz_info = msg_cmd[8..msg_cmd.length]

    puts "Event: Checking Time for timezone: #{tz_info}"

    msg.reply time_message(tz_info)
  end

  def hello(msg)
    msg.reply "Hello to you! My current time is #{Time.now}"
  end

  def base_url
    ENV['TICKINGAWAY_BASE_URL'] || DEFAULT_TIME_API
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
