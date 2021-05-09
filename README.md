# TickingAway
> IRC Chat bot for time info adjusted for timezone

## Description

This gem can create an IRC Chat Bot using the [Cinch gem](https://github.com/cinchrb/cinch) that responds to `!timeat <tz_info>` and `!timepopularity <tz_info or prefix>`. The gem is runnable as a standalone Cinch chat bot or you can just throw IRC message strings at the `TickingAway::Bot` and get the string responses back. The time commands are implemented as Cinch Plugin so that you can also add it as a plugin to an existing Cinch ChatBot.

Disclaimer: The Cinch library has been dead for several years but still seems to work just fine on freenode.

![](header.png)

## Installation

RubyGems:

```sh
gem install ticking_away
```

Bundler:

```ruby
gem 'ticking_away'
```

GitHub:

```sh
git clone https://github.com/woodjeffrey2/ticking_away.git
```

## Usage

There are a couple of different ways you can use the gem.

### Standalone Cinch Chat Bot
You can run a standalone IRC Cinch chat bot by creating a `TickingAway::ChatBot` object

```ruby
require 'ticking_away'

bot = TickingAway::ChatBot.new('irc.freenode.org', ['my_channel', 'my_channel_2'])

bot.start
```

### Bot Object
You can also just create a `TickingAway::Bot` and send commands at it through the `chat(<message>)` method. Messages should be formatted in IRC format like `<username>: <command or message>`

```ruby
require 'ticking_away'

bot = TickingAway::Bot.new

bot_response = bot.chat('Jeremy: !timeat America/Los_Angeles')
```

### Cinch Plugin
You can also add the `!timeat` and `!timepopularity` commands to any Cinch Chat Bot you want.

```ruby
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

@bot.start
```

## Building the gem locally

In order to build and install the gem locally you'll need to clone the repo, then:

```sh
gem build ticking_away.gemspec

# install locally
gem install ./<generated .gem file>
```

## Unit Tests
Unit tests are written in MiniTest. In order to run them you'll need to clone the repo, then:

```sh
bundle install

rake test
```

## Meta

Jeff Wood

Distributed under the MIT license.

[https://github.com/woodjeffrey2/ticking_away](https://github.com/woodjeffrey2/ticking_away)
