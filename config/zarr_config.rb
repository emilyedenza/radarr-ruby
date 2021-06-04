##
# Mixin for common configuration in both Sonarr and Radarr.

module RadarrRuby
  class ZarrConfig
    attr_reader :base, :sleep_sec, :api_key, :category, :speed_threshold_kibs, :free_threshold_mib, :disk_path,
                :delete_limit, :commands, :completion_threshold, :commands_enabled

    def initialize(config)
      @base = config['base']
      @sleep_sec = config['sleep_sec']
      @api_key = config['api_key']
      @category = config['category']
      @speed_threshold_kibs = config['speed_threshold_kibs']
      @free_threshold_mib = config['free_threshold_mib']
      @disk_path = config['disk_path']
      @delete_limit = config['delete_limit']
      @commands = config['commands']
      @completion_threshold = config['completion_threshold']
      @commands_enabled = config['commands_enabled']
    end

    def inspect
      "Base:\t\t\t\t\t\t#{base}
Sleep:\t\t\t\t\t\t#{sleep_sec}
Category:\t\t\t\t\t#{category}
Speed threshold (KiB/s):\t#{speed_threshold_kibs}
Free threshold (MiB):\t\t#{free_threshold_mib}
Disk path:\t\t\t\t#{disk_path}
Delete limit:\t\t\t\t#{delete_limit}
Commands:\t\t\t\t\t#{commands}
Completion threshold:\t\t#{completion_threshold}
Commands enabled:\t\t\t#{commands_enabled}"
    end
  end
end
