# frozen_string_literal: true

require 'redis'
require_relative 'cleaner'
require 'yaml'
require_relative 'config/config'

##
# Runs a clean loop triggered by a Sonarr or Radarr control flow/input.
class GenericCleaner
  def initialize(config)
    @config = config
  end

  def run
    divider = '=' * 18
    puts divider
    puts "| #{@config.app_name.upcase} CLEANER |"
    puts divider
    puts

    redis_client = Redis.new
    puts redis_client.ping('Connected to Redis.')

    qbittorrent_config = RadarrRuby::Config.qbittorrent
    redis_config = RadarrRuby::Config.redis
    puts
    puts 'Config: '
    puts divider
    puts @config.inspect
    puts qbittorrent_config.inspect
    puts redis_config.inspect
    puts divider
    puts

    cleaner = RadarrRuby::Cleaner.new(@config, qbittorrent_config, redis_client, redis_config)

    loop do
      cleaner.clean
      puts "Sleeping for #{@config.sleep_sec} sec."
      puts divider
      puts
      sleep(@config.sleep_sec)
    end
  end
end
