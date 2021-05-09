require 'json'

module TickingAway
  # Class to store timeat stats as a JSON file in local storage
  class JSONFileStorage
    attr_reader :filename
    attr_accessor :stats

    def initialize(filename = 'ticking_away_stats.json')
      @filename = filename
      @stats = read_from_file
    end

    def increment_stat(stat_name)
      if stats[stat_name]
        stats[stat_name] += 1
      else
        stats.merge!({ stat_name => 1 })
      end
      save_stats
    end

    def save_stats
      File.write(filename, JSON.dump(stats))
    end

    # Get the number of times !timeat was called for a
    # timezone or prefix. Partial prefix matches count towards
    # the total.
    def get_stat(stat_name)
      call_count = 0
      stats.each do |key, value|
        call_count += value if key.start_with?(stat_name)
      end

      call_count
    end

    def read_file
      File.read(filename)
    end

    def read_from_file
      return JSON.parse(read_file) if File.file?(filename)
      {}
    end
  end
end
