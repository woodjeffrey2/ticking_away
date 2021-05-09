# = Cinch TickingAway::TimeInfo plugin
# This plugin enables Cinch to respond to !timeat <tz_info> and
# !timepopularity <tz_info or prefix> commands.
#
# !timeat <tz_info> will respond with the current time for the
# provided timezone according to the World Time Api or any other
# provided time Api that conforms to the spec.
#
# !timepopularity <tz_info or prefix> will respond with the number
# of times !timeat was called successfully for the provided tz_info or
# prefix. For instance, "!timepopularity America" will return the
# number of times "!timeat America" was called, but it will also
# count the number of times "!timeat America/Los_Angeles" or
# "!timeat America/New_York" was called because they both contain
# the prefix "America"
#
#
# == Configuration
# Add the following to your bot’s configure.do stanza:
#
#   config.plugins.options[TickingAway::TimeInfo] = {
#     :time_api => 'https://worldtimeapi.org/api'
#   }
#
# [time_api ('https://worldtimeapi.org/api')]
#   The time is retreived from a time Api. It requires the spec to match
#   the World Time Api. If this is not specified either through the config,
#   or by providing the ENV var TIME_API, it will default to https://worldtimeapi.org/api
#
# == Author
# Jeff Wood
#
# == License
# A time info plugin for Cinch.
# Copyright © 2021 Jeff Wood
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the MIT License.
require 'cinch'

module TickingAway
  class TimeInfo
    include ::Cinch::Plugin

    match (/timeat */), method: :timeat
    match (/timepopularity */), method: :timepopularity

    listen_to :connect, method: :on_connect

    # Instantiate bot with JSON file storage when the bot connects
    # to the IRC server. I'd like storage to be configurable
    # through the Cinch configs eventually
    def on_connect(*)
      @storage = TickingAway::JSONFileStorage.new
      @ta_bot = config[:time_api] ? TickingAway::Bot.new(storage: @storage, time_api: config[:time_api]) : TickingAway::Bot.new(storage: @storage)
    end

    # Check time for the timezone provided against the
    # provided time api by asking the TickingAway Bot
    def timeat(msg)
      msg.reply @ta_bot.time_check(msg.params[1])
    end

    # Return the statistic for the provided tz_info or prefix
    # by asking the TickingAway Bot
    def timepopularity(msg)
      msg.reply @ta_bot.stat_check(msg.params[1])
    end
  end
end
