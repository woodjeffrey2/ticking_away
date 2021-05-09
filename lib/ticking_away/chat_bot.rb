require 'cinch'

module TickingAway
  class ChatBot

    def initialize(server, channels)
      @server = server
      @channels = channels
      @bot = nil
    end

    def start
      # Scope nonsense
      server = @server
      channels = @channels

      @bot = Cinch::Bot.new do
        configure do |c|
          c.server = server
          c.channels = channels
          c.nick = 'TickingAwayBot'
          c.plugins.plugins = [TickingAway::TimeInfo]
        end
      end

      @bot.start
    end

    def stop
      @bot.stop
    end
  end
end
