# frozen_string_literal: true

require 'yaml'
require_relative 'sonarr_config'
require_relative 'radarr_config'
require_relative 'qbittorrent_config'

module RadarrRuby
  ##
  # Stores the YAML-based configuration for RadarrRuby's different areas of functionality.
  class Config
    def self.sonarr
      SonarrConfig.new(config_hash['sonarr'])
    end

    def self.radarr
      RadarrConfig.new(config_hash['radarr'])
    end

    def self.qbittorrent
      QbittorrentConfig.new(config_hash['qb'])
    end

    def self.config_hash(config_path = 'config.yml')
      @config_hash ||= YAML.load_file(config_path)
    end
  end
end
