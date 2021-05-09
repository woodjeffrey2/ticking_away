require 'test_helper'

class TickingAwayTest < Minitest::Test
  # Mock storage to inject for tests. Different tests writing
  # + reading with the same file names can step on each others
  # toes and cause strange behavior
  class MockStorage < TickingAway::JSONFileStorage
    def save_stats
      true # don't save anything to file
    end
  end
end
