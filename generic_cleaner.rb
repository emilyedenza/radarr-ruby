# frozen_string_literal: true

require 'redis'
require_relative 'cleaner'
require 'yaml'
require_relative 'config/config'

##
# Runs a clean loop triggered by a Sonarr or Radarr control flow/input.
class GenericCleaner
  DIVIDER = '*' * 18

  def initialize(config)
    @config = config
  end

  def run
    print_header

    redis_client = Redis.new
    puts redis_client.ping('Connected to Redis.')

    qbittorrent_config = RadarrRuby::Config.qbittorrent
    redis_config = RadarrRuby::Config.redis
    print_config(qbittorrent_config, redis_config)

    cleaner = RadarrRuby::Cleaner.new(@config, qbittorrent_config, redis_client, redis_config)
    start_loop(cleaner)
  end

  private

  def start_loop(cleaner)
    loop do
      cleaner.clean
      puts "Sleeping for #{@config.sleep_sec} sec."
      puts DIVIDER
      puts
      sleep(@config.sleep_sec)
    end
  end

  def print_header
    puts DIVIDER
    puts "| #{@config.app_name.upcase} CLEANER |"
    puts DIVIDER
    puts
  end

  def print_config(qbittorrent_config, redis_config)
    puts
    puts 'Config: '
    puts DIVIDER
    puts @config.inspect
    puts qbittorrent_config.inspect
    puts redis_config.inspect
    puts DIVIDER
    puts
  end
end
