require_relative '../ticking_away_test'
require 'json'

class TickingAway::BotTest < TickingAwayTest

  def setup
    ENV['BACKOFF_BASE'] = '0.1' # use small backoff for faster tests
    @filename = 'some_test_file.json'
    @base_url = 'https://some_time_server.org'
    @storage = TickingAwayTest::MockStorage.new(@filename)
    @bot = TickingAway::Bot.new(storage: @storage, time_api: @base_url)

    @success_response = {
      'abbreviation' => 'PDT',
      'client_ip' => '24.22.121.72',
      'datetime' => '2021-05-08T10:25:32.321735-07:00',
      'day_of_week' => 6,
      'day_of_year' => 128,
      'dst' => true,
      'dst_from' => '2021-03-14T10:00:00+00:00',
      'dst_offset' => 3600,
      'dst_until' => '2021-11-07T09:00:00+00:00',
      'raw_offset' => -28800,
      'timezone' => 'America/Los_Angeles',
      'unixtime' => 1620494732,
      'utc_datetime' => '2021-05-08T17:25:32.321735+00:00',
      'utc_offset' => '-07:00',
      'week_number' => 18
    }
  end

  def test_chat_timeat
    tz_info = 'America/Los_Angeles'
    test_cmd = "!timeat #{tz_info}"

    stub_request(:any, "#{@bot.time_api}/timezone/#{tz_info}")
      .to_return(body: @success_response.to_json, status: 200)

    response = @bot.chat(test_cmd)
    expected_response = ' 8 May 2021 10:25'

    assert_equal(response, expected_response)

    saved_stats = @storage.stats
    expected_stats = {
      'America/Los_Angeles' => 1
    }

    assert_equal(saved_stats, expected_stats)
  end

  # Test timeat with "username: " at the front of the string
  def test_username_chat_timeat
    @storage.stats = {}
    tz_info = 'America/Los_Angeles'
    test_cmd = "Jeremy: !timeat #{tz_info}"

    stub_request(:any, "#{@bot.time_api}/timezone/#{tz_info}")
      .to_return(body: @success_response.to_json, status: 200)

    response = @bot.chat(test_cmd)
    expected_response = ' 8 May 2021 10:25'

    assert_equal(response, expected_response)

    saved_stats = @storage.stats
    expected_stats = {
      'America/Los_Angeles' => 1
    }

    assert_equal(saved_stats, expected_stats)
  end

  def test_chat_timepopularity
    @storage.stats = {}
    tz_info = 'America/Los_Angeles'
    test_at_cmd = "!timeat #{tz_info}"
    test_pop_cmd = "!timepopularity #{tz_info}"

    stub_request(:any, "#{@bot.time_api}/timezone/#{tz_info}")
      .to_return(body: @success_response.to_json, status: 200)
    stub_request(:any, "#{@bot.time_api}/timezone/#{tz_info}/Taco_Bell")
      .to_return(body: @success_response.to_json, status: 200)

    @bot.chat(test_at_cmd)
    @bot.chat(test_at_cmd)
    @bot.chat("#{test_at_cmd}/Taco_Bell")

    saved_stat = @bot.chat(test_pop_cmd)
    expected_stat = 3

    assert_equal(saved_stat, expected_stat)
  end

  def test_chat_timeat_bad_timezone
    @storage.stats = {}
    tz_info = 'America/Los_Angelez'
    test_cmd = "!timeat #{tz_info}"

    stub_request(:any, "#{@bot.time_api}/timezone/#{tz_info}")
      .to_return(body: { error: 'unknown location' }.to_json, status: 404)

    response = @bot.chat(test_cmd)
    expected_response = 'unknown timezone'

    assert_equal(response, expected_response)

    # make sure we're not storing bad lookups
    saved_stats = @storage.stats
    expected_stats = {}

    assert_equal(saved_stats, expected_stats)
  end

  def test_chat_timeat_bad_status
    @storage.stats = {}
    tz_info = 'America/Los_Angeles'
    test_cmd = "!timeat #{tz_info}"

    stub_request(:any, "#{@bot.time_api}/timezone/#{tz_info}")
      .to_return(body: nil, status: 503)

    response = @bot.chat(test_cmd)
    possible_responses = [
      'Time is an illusion',
      'What is time, really?',
      'The linear progression of time is currently on hold'
    ]

    assert possible_responses.include?(response)
  end

  def test_timeat_random_5XX
    @storage.stats = {}
    tz_info = 'America/Los_Angeles'
    test_cmd = "!timeat #{tz_info}"

    stub_request(:any, "#{@bot.time_api}/timezone/#{tz_info}")
      .to_return(body: nil, status: 503)

    response = @bot.chat(test_cmd)
    possible_responses = [
      'Time is an illusion',
      'What is time, really?',
      'The linear progression of time is currently on hold'
    ]

    assert possible_responses.include?(response)
  end
end
