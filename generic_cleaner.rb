# frozen_string_literal: true

require 'redis'
require_relative 'cleaner'
require 'yaml'
require_relative 'api/radarr_api'
require_relative 'api/sonarr_api'
require_relative 'config/config_factory'

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
    @zarr_api = zarr_api
  end

  def run
    print_header

    qbittorrent_config = ConfigFactory.qbittorrent
    print_config(qbittorrent_config, ConfigFactory.redis)

    cleaner = Cleaner.new(@zarr_api, qbittorrent_config)
    start_loop(cleaner)
  end

  private

  def start_loop(cleaner)
    loop do
      cleaner.clean
      puts "Sleeping for #{@zarr_api.config.sleep_sec} sec."
      puts DIVIDER
      puts
      sleep(@zarr_api.config.sleep_sec)
    end
  end

  def print_header
    puts DIVIDER
    puts "| #{@zarr_api.config.app_name.upcase} CLEANER |"
    puts DIVIDER
    puts
  end

  def print_config(*configs)
    puts
    puts 'Config: '
    puts DIVIDER
    configs.each { |c| puts c.inspect }
    puts DIVIDER
    puts
  end
end
