require 'json'

module TickingAway
  # Class to store !timeat stats as a JSON file in local storage
  # and return !timepopularity stats for a provided !timeat call
  class JSONFileStorage
    attr_reader :filename
    attr_accessor :stats

    def initialize(filename = 'ticking_away_stats.json')
      @filename = filename
      @stats = read_from_file
    end

    # Add 1 to a !timeat <tz_info> stat
    # and save the hash as JSON to a file
    def increment_stat(stat_name)
      if stats[stat_name]
        stats[stat_name] += 1
      else
        stats.merge!({ stat_name => 1 })
      end
      save_stats
    end

    # Get the number of times !timeat was called for a
    # tz_info or prefix. Partial prefix matches count towards
    # the total.
    # If we didn't want them to, it could check the
    # next char in the key after the .start_with? match. If it's outside the
    # length or a "/", then the prefix or tz_info matches exactly
    def get_stat(stat_name)
      call_count = 0
      stats.each do |key, value|
        call_count += value if key.start_with?(stat_name)
      end

      call_count
    end

    def save_stats
      File.write(filename, JSON.dump(stats))
    end

    def read_file
      File.read(filename)
    end

    # Get saved stats on instantiation or return an empty hash
    def read_from_file
      return JSON.parse(read_file) if File.file?(filename)
      {}
    end
  end
end
