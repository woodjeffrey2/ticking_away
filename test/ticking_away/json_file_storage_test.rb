require_relative '../ticking_away_test'
require 'json'

class TickingAway::JSONFileStorageTest < TickingAwayTest

  def setup
    @filename = 'some_test_file.json'
    clear_file
    @storage = TickingAway::JSONFileStorage.new(@filename)
  end

  def test_increment_stat
    @storage.increment_stat('America/Los_Angeles')

    saved_stats = JSON.parse(File.read(@filename))
    expected_stats = {
      'America/Los_Angeles' => 1
    }

    assert_equal(saved_stats, expected_stats)
    clear_file
  end

  def test_get_stat
    stat_name = 'America/Los_Angeles'

    @storage.increment_stat(stat_name)
    @storage.increment_stat("#{stat_name}/Taco_Bell")
    @storage.increment_stat("#{stat_name}/Pizza_Hut")

    actual = @storage.get_stat(stat_name)
    expected = 3
    assert_equal(actual, expected)
    clear_file
  end

  def test_get_stat_no_partial
    stat_name = 'America/Los_Angeles'

    @storage.increment_stat(stat_name)
    @storage.increment_stat("#{stat_name}/Taco_Bell")
    @storage.increment_stat("#{stat_name}/Pizza_Hut")

    actual = @storage.get_stat('Ameri')
    expected = 0
    assert_equal(actual, expected)
    clear_file
  end

  def clear_file
    File.delete(@filename) if File.file?(@filename)
  end
end


