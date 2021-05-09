require 'ticking_away'

bot = Cinch::Bot.new do
        configure do |c|
          c.server = server
          c.channels = channels
          c.nick = 'TickingAwayBot'
          c.plugins.plugins = [TickingAway::TimeInfo]
          c.plugins.options[TickingAway::TimeInfo] = {
            :time_api => 'https://worldtimeapi.org/api'
          }
        end
      end

bot.start
