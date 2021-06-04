#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optionparser'
require_relative 'generic_cleaner'
require_relative 'config/config'

$stdout.sync = true

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: init.rb [options]'

  opts.on('-r', '--radarr', 'Clean Radarr downloads') do |r|
    options[:radarr] = r
  end

  opts.on('-s', '--sonarr', 'Clean Sonarr downloads') do |s|
    options[:sonarr] = s
  end

  opts.on('-h', '--help', 'Prints this help') do
    abort opts
  end
end.parse!

abort 'Cannot clean Radarr and Sonarr simultaneously. Please choose one.' if options[:radarr] && options[:sonarr]
abort 'Please choose to clean either Radarr (-r) or Sonarr (-s).' unless options[:radarr] || options[:sonarr]

config = options[:radarr] ? RadarrRuby::Config.radarr : RadarrRuby::Config.sonarr
cleaner = GenericCleaner.new(config)
cleaner.run
