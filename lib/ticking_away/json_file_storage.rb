require 'json'

module TickingAway
  class JSONFileStorage
    attr_reader :filename

    def initialize(filename = 'ticking_away_stats.json')
      @filename = filename
    end

    def increment_stat(stat_name)
      if File.file?(file_path)
        saved_stats = JSON.parse(read_file)

        if saved_stats[stat_name].nil?
          File.write(file_path, JSON.dump(saved_stats.merge({ stat_name => 1 })))
        else
          saved_stats[stat_name] += 1
          File.write(file_path, JSON.dump(saved_stats))
        end
      else
        File.write(file_path, JSON.dump({ stat_name => 1 }))
      end
    end

    def file_path
      File.join(File.dirname(__FILE__), 'storage', filename)
    end

    def read_file
      File.read(file_path)
    end
  end
end
