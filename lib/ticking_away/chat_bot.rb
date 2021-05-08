require 'cinch'

module TickingAway
    class ChatBot
        
        def initialize(server, channels)
            @server = server
            @channels = channels
            @bot = nil
        end

        def start
            server = @server
            channels = @channels
            @bot = Cinch::Bot.new do
                configure do |c|
                    c.server = server
                    c.channels = channels
                    c.nick = 'TickingAway'
                    c.plugins.plugins = [TimeInfo]
                end
            end
    
            @bot.start
        end

        def stop
            @bot.stop
        end
    end
end