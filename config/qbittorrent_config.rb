module RadarrRuby
  ##
  # Stores QBittorrent-specific configuration.
  # The (inconsistent) lowercase "Q" is for development rule-following.
  class QbittorrentConfig
    attr_reader :host, :username, :password

    def initialize(config_hash)
      @host = config_hash['host']
      @username = config_hash['username']
      @password = config_hash['password']
    end
  end
end
