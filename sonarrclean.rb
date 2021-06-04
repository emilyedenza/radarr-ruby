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

redis = Redis.new
puts redis.ping('Connected to Redis.')

sonarr_config = RadarrRuby::Config.sonarr
qbittorrent_config = RadarrRuby::Config.qbittorrent
puts
puts 'Config: '
puts divider
puts sonarr_config.inspect
puts qbittorrent_config.inspect
puts divider
puts

cleaner = RadarrRuby::Cleaner.new(sonarr_config, qbittorrent_config)

loop do
  cleaner.clean
  puts "Sleeping for #{sonarr_config.sleep_sec} sec."
  sleep(sonarr_config.sleep_sec)
end
