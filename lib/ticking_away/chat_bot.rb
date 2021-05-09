require 'cinch'

# This provides a default Chat Bot for running
# the TickingAway::TimeInfo Cinch plugin. A new
# Chatbot can be started by calling
# bot = TickingAway::ChatBot.new(<server>, <channel>)
# bot.start
module TickingAway
  class ChatBot

    def initialize(server, channels)
      @server = server
      @channels = channels
      @bot = nil
    end

    def start
      # Required for dealing with scope.
      # The block provided when instantiating the
      # bot and the configuration block only have the
      # scope of the start method while the start
      # method has access to the class's instance vars
      # The block cannot access the class's instance vars
      # unless they're assigned to a var in the method's scope
      # Good target for some refactoring
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
