require 'ticking_away'

server = 'irc.freenode.org'
channels = ['##8ea0e901-440a-49d8-9ba4-f80f24566e87']

bot = TickingAway::ChatBot.new(server, channels)
bot.start
