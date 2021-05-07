require 'cinch'

class TickingAway
    def self.start(server, channels)
        bot = Cinch::Bot.new do
            configure do |c|
                c.server = server
                c.channels = channels
            end
            
            on :message, "hello" do |m|
                m.reply "Hello, #{m.user.nick}"
            end
        end

        bot.start
    end
end