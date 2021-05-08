require_relative '../ticking_away_test'

class TickingAway::JSONFileStorageTest < TickingAwayTest

  def setup
    @filename = 'some_test_file.json'
  end

  def test_increment_stat
    storage = TickingAway::JSONFileStorage.new(@filename)

    # Delete the file if it's there already
    File.delete(storage.file_path) if File.file?(@filename)

    storage.increment_stat('America/Los_Angeles')

    saved_stats = JSON.parse(File.read(storage.file_path))
    expected_stats = {
      'America/Los_Angeles' => 1
    }

    assert_equal(saved_stats, expected_stats)
  end
end
