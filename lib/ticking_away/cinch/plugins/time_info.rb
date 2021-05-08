require 'cinch'

class TimeInfo
  include Cinch::Plugin

  match 'timeat', :method => :time_check

  def time_check(msg)
    msg.reply "Current time is: #{Time.now}"
  end
end