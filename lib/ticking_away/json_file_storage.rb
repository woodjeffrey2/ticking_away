require 'json'

module TickingAway
  # Class to store timeat stats as a JSON file in local storage
  class JSONFileStorage
    attr_reader :filename

    def initialize(filename = 'ticking_away_stats.json')
      @filename = filename
    end

    def increment_stat(stat_name)
      if File.file?(filename)
        saved_stats = JSON.parse(read_file)

        if saved_stats[stat_name].nil?
          File.write(filename, JSON.dump(saved_stats.merge({ stat_name => 1 })))
        else
          saved_stats[stat_name] += 1
          File.write(filename, JSON.dump(saved_stats))
        end
      else
        File.write(filename, JSON.dump({ stat_name => 1 }))
      end
    end

    def get_stat(stat_name)
      saved_stats = JSON.parse(read_file)

      call_count = 0
      saved_stats.each do |key, value|
        call_count += value if key.start_with?(stat_name)
      end

      call_count
    end

    def read_file
      File.read(filename)
    end
  end
end
