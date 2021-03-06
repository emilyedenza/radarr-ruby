# frozen_string_literal: true

require 'yaml'
require_relative 'sonarr_config'
require_relative 'radarr_config'
require_relative 'redis_config'
require_relative 'qbittorrent_config'

##
# Stores the YAML-based configuration for RadarrRuby's different areas of functionality.
class ConfigFactory
  def self.sonarr
    SonarrConfig.new(config_hash['sonarr'])
  end

  def self.radarr
    RadarrConfig.new(config_hash['radarr'])
  end

  def self.qbittorrent
    QbittorrentConfig.new(config_hash['qbittorrent'])
  end

  def self.redis
    RedisConfig.new(config_hash['redis'])
  end

  def self.config_hash(config_path = 'config.yml')
    @config_hash ||= YAML.load_file(config_path)
  end
end
