require 'test_helper'

class TickingAwayTest < Minitest::Test

  class MockStorage
    attr_reader :file_name
    attr_accessor :stats

    def initialize(file_name)
      @file_name = file_name
      @stats = {}
    end

    def increment_stat(stat_name)
      if stats[stat_name]
        stats[stat_name] += 1
      else
        stats.merge!({ stat_name => 1 })
      end
    end

    def get_stat(stat_name)
      call_count = 0
      stats.each do |key, value|
        call_count += value if key.start_with?(stat_name)
      end

      call_count
    end
  end
end
