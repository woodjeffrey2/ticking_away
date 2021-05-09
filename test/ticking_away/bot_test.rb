require_relative '../ticking_away_test'
require 'json'

class TickingAway::BotTest < TickingAwayTest

  def setup
    @filename = 'some_test_file.json'
    @base_url = 'https://some_time_server.org'
    @storage = TickingAwayTest::MockStorage.new(@filename)
    @bot = TickingAway::Bot.new(@storage, @base_url)

    @success_response = {
      'abbreviation' => 'PDT',
      'client_ip' => '24.22.121.72',
      'datetime' => '2021-05-08T10 =>25 =>32.321735-07 =>00',
      'day_of_week' => 6,
      'day_of_year' => 128,
      'dst' => true,
      'dst_from' => '2021-03-14T10 =>00 =>00+00 =>00',
      'dst_offset' => 3600,
      'dst_until' => '2021-11-07T09 =>00 =>00+00 =>00',
      'raw_offset' => -28800,
      'timezone' => 'America/Los_Angeles',
      'unixtime' => 1620494732,
      'utc_datetime' => '2021-05-08T17 =>25 =>32.321735+00 =>00',
      'utc_offset' => '-07 =>00',
      'week_number' => 18
    }
  end

  def test_chat_timeat
    tz_info = 'America/Los_Angeles'
    test_cmd = "!timeat #{tz_info}"

    stub_request(:any, "#{@bot.time_api}/timezone/#{tz_info}")
      .to_return(body: @success_response.to_json, status: 200)

    response = @bot.chat(test_cmd)
    expected_response = ' 8 May 2021 00:00'

    assert_equal(response, expected_response)

    saved_stats = @storage.stats
    expected_stats = {
      'America/Los_Angeles' => 1
    }

    assert_equal(saved_stats, expected_stats)
  end

  # def test_get_stat
  #   stat_name = 'America/Los_Angeles'

  #   @storage.increment_stat(stat_name)
  #   @storage.increment_stat("#{stat_name}/Taco_Bell")
  #   @storage.increment_stat("#{stat_name}/Pizza_Hut")

  #   actual = @storage.get_stat(stat_name)
  #   expected = 3
  #   assert_equal(actual, expected)
  #   clear_file
  # end

end

def clear_file
  File.delete(@filename) if File.file?(@filename)
end
