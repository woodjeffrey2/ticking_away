require_relative '../ticking_away_test'
require 'webmock/minitest'

class TickingAway::WorldTimeTest < TickingAwayTest
  def setup
    @base_url = 'https://some_time_server.org'
    @tz_info = 'America/Los_Angeles'
    @request_url = "#{@base_url}/timezone/#{@tz_info}"

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

  def test_successful_get
    stub_request(:any, @request_url)
      .to_return(body: @success_response.to_json, status: 200)

    api_response = TickingAway::WorldTime.time_at(@base_url, @tz_info)
    expected_response = Time.parse(@success_response['datetime'])

    assert_equal(api_response, expected_response)
  end

  def test_not_found
    stub_request(:any, @request_url)
      .to_return(body: { error: 'unknown location' }.to_json, status: 404)

    exception = assert_raises TickingAway::Errors::UnrecognizedTimeZone do
      TickingAway::WorldTime.time_at(@base_url, @tz_info)
    end
    assert_equal('Error: Unrecognized Time Zone https://some_time_server.org/timezone/America/Los_Angeles', exception.message)
  end

  def test_bad_response
    stub_request(:any, @request_url)
      .to_return(body: nil, status: 500)

    assert_raises TickingAway::Errors::TimeTravelIsHard do
      TickingAway::WorldTime.time_at(@base_url, @tz_info)
    end
  end

  def test_array_response
    stub_request(:any, @request_url)
      .to_return(body: [1..5].to_json, status: 200)

    exception = assert_raises TickingAway::Errors::UnrecognizedTimeZone do
      TickingAway::WorldTime.time_at(@base_url, @tz_info)
    end
    assert_equal('Error: non-time response', exception.message)
  end

  def test_non_time_response
    stub_request(:any, @request_url)
      .to_return(body: '<html>asdfasdf</html>', status: 503)

    exception = assert_raises TickingAway::Errors::TimeTravelIsHard do
      TickingAway::WorldTime.time_at(@base_url, @tz_info)
    end
    assert_equal("809: unexpected token at '<html>asdfasdf</html>'", exception.message)
  end
end
