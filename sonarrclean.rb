#!/usr/bin/env ruby
# frozen_string_literal: true

require 'redis'
require_relative 'cleaner'
require 'yaml'
require_relative 'config/config'

divider = '=' * 18
redis = Redis.new

puts divider
puts '| SONARR CLEANER |'
puts divider
puts
puts redis.ping('Connected to Redis.')

sonarr_config = RadarrRuby::Config.sonarr

puts
puts 'Config: '
puts divider
puts sonarr_config.inspect
puts divider
puts

cleaner = RadarrRuby::Cleaner.sonarr(sonarr_config)

loop do
  cleaner.clean
  puts "Sleeping for #{sonarr_config.sleep_sec} seconds."
  sleep(sonarr_config.sleep_sec)
end
