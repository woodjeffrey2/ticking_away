require 'ticking_away'

bot = Cinch::Bot.new do
        configure do |c|
          c.server = 'irc.freenode.org'
          c.channels = ['my_channel', 'my_channel_2']
          c.nick = 'TickingAwayBot'
          c.plugins.plugins = [TickingAway::TimeInfo]
          c.plugins.options[TickingAway::TimeInfo] = {
            :time_api => 'https://worldtimeapi.org/api'
          }
        end
      end

bot.start
