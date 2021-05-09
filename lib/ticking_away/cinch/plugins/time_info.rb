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
# A memo message plugin for Cinch.
# Copyright © 2021 Jeff Wood
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
require 'cinch'

module TickingAway
  class TimeInfo
    include ::Cinch::Plugin

    DEFAULT_TIME_API = 'http://worldtimeapi.org/api'.freeze
    EXCUSES = [
      'Time is an illusion',
      'What is time, really?',
      'The linear progression of time is currently on hold'
    ].freeze

    match /timeat */, method: :time_check
    match /timepopularity */, method: :stat_check

    listen_to :connect, method: :on_connect

    # Instantiate JSON file storage when the bot connects
    # to the IRC server. I'd like to eventually add some Dependency
    # Injection for stat storage method
    def on_connect(*)
      @stat_file = TickingAway::JSONFileStorage.new
    end

    # Check time for the timezone provided against the
    # provided time api.
    def time_check(msg)
      tz_info = parse_message(msg, '!timeat '.length)

      puts "Event: Checking Time for timezone: #{tz_info}"

      msg.reply time_message(tz_info)
    end

    # Return the statistic for the provided tz_info or prefix
    def stat_check(msg)
      msg.reply @stat_file.get_stat(parse_message(msg, '!timepopularity '.length))
    end

    private

    # Parse the message for the string after the command.
    # Requires the command length (including the ! and space)
    # to know where to start the substring
    def parse_message(msg, cmd_length)
      message = msg.params[1]
      message[cmd_length..message.length]
    end

    # Look for the time api in ENV, then Cinch::Plugin config
    # Fall back to hardcoded worldtimeapi
    def base_url
      ENV['TIME_API'] || config[:time_api] || DEFAULT_TIME_API
    end

    # Generate the time message, returning "unknown location"
    # for any unrecognized time zones and logging any uncaught
    # errors before returning an excuse at random.
    # Stats will only be incremented if the api call was successful
    def time_message(tz_info)
      time = TickingAway::WorldTime.time_at(base_url, tz_info)

      @stat_file.increment_stat(tz_info)
      time.strftime('%e %b %Y %H:%M')
    rescue TickingAway::Errors::UnrecognizedTimeZone => e
      puts e.message
      'unknown timezone'
    rescue => e
      puts e.message
      EXCUSES.sample
    end
  end
end
