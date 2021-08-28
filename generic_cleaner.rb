# frozen_string_literal: true

require 'logger'
require 'redis'
require_relative 'cleaner'
require 'yaml'
require_relative 'api/radarr_api'
require_relative 'api/sonarr_api'
require_relative 'config/config_factory'
require_relative 'redis_client'

##
# Runs a clean loop triggered by a Sonarr or Radarr control flow/input.
class GenericCleaner
  DIVIDER = '*' * 18

  def self.radarr
    GenericCleaner.new(RadarrApi.new)
  end

  def self.sonarr
    GenericCleaner.new(SonarrApi.new)
  end

  def initialize(zarr_api)
    @logger = Logger.new($stdout)
    @zarr_api = zarr_api
  end

  def run
    print_header

    qbittorrent_config = ConfigFactory.qbittorrent
    print_config(@zarr_api.config, qbittorrent_config, ConfigFactory.redis)
    print_redis_check

    cleaner = Cleaner.new(@zarr_api, qbittorrent_config)
    start_loop(cleaner)
  end

  private

  def print_redis_check
    @logger.info RedisClient.instance.client.ping('Redis connected.')
    @logger.info DIVIDER
  end

  def start_loop(cleaner)
    loop do
      cleaner.clean
      @logger.info "Sleeping for #{@zarr_api.config.sleep_sec} sec."
      @logger.info DIVIDER
      sleep(@zarr_api.config.sleep_sec)
    end
  end

  def print_header
    @logger.info DIVIDER
    @logger.info "| #{@zarr_api.config.app_name.upcase} CLEANER |"
    @logger.info DIVIDER
  end

  def print_config(*configs)
    @logger.info 'Config: '
    @logger.info DIVIDER
    configs.each { |c| @logger.info c.inspect }
    @logger.info DIVIDER
  end
end
