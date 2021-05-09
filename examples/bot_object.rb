require 'ticking_away'

# You can provide optional arguments for .new(storage: <storage object>, time_api: <base api url>)
# If they are not provided they'll be set to their defaults which is JSON File Storage
# and the World Time Api (http://worldtimeapi.org/api)
bot = TickingAway::Bot.new

bot_response = bot.chat('Jeremy: !timeat America/Los_Angeles')

puts bot_response
