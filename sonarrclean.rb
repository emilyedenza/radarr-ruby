#!/usr/bin/env ruby
# frozen_string_literal: true

require 'redis'
require_relative 'cleaner'
require 'yaml'
require_relative 'config/config'

divider = '=' * 18
puts divider
puts '| SONARR CLEANER |'
puts divider
puts

redis_client = Redis.new
puts redis_client.ping('Connected to Redis.')

sonarr_config = RadarrRuby::Config.sonarr
qbittorrent_config = RadarrRuby::Config.qbittorrent
redis_config = RadarrRuby::Config.redis
puts
puts 'Config: '
puts divider
puts sonarr_config.inspect
puts qbittorrent_config.inspect
puts redis_config.inspect
puts divider
puts

cleaner = RadarrRuby::Cleaner.new(sonarr_config, qbittorrent_config, redis_client, redis_config)

loop do
  cleaner.clean
  puts "Sleeping for #{sonarr_config.sleep_sec} sec."
  puts divider
  sleep(sonarr_config.sleep_sec)
end
