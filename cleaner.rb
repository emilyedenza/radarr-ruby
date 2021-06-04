# frozen_string_literal: true
#
require 'set'
require_relative 'api/zarr_api'
require_relative 'api/qbittorrent_api'

module RadarrRuby
  ##
  # Cleans stalled or slow downloads from Sonarr or Radarr.
  class Cleaner
    attr_reader :commands_enabled, :zarr_db_path, :stuck_threshold, :commands, :delete_limit, :singular_name,
                :speed_threshold_kibs, :category, :disk_path, :free_threshold_mib, :zarr_api, :clean_analyser,
                :redis_stuck_label

    def initialize(zarr_config, qbittorrent_config)
      @zarr_api = ZarrApi.new(zarr_config)
      @zarr_config = zarr_config
      @qbittorrent_api = QbittorrentApi.new(qbittorrent_config)
    end

    ##
    # Cleans up stalled or slow downloads from the relevant client.
    # Prints log output to console as it processes.
    def clean
      hashes_to_delete = Set.new
      titles_to_delete = []

      free_disk_space_item = @zarr_api.free_disk_space.find { |d| d['path'] == @zarr_config.disk_path }

      free_bytes = free_disk_space_item['freeSpace']
      free_bytes_threshold = @zarr_config.free_threshold_mib * 1024**2
      if free_bytes < free_bytes_threshold
        puts "#{free_bytes} bytes < minimum (#{free_bytes_threshold}). Skipping run."
        return
      end

      torrents_timer_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      torrents = @qbittorrent_api.torrents({ filter: 'active' })
      torrents += @qbittorrent_api.torrents({ filter: 'stalled' })
      torrents_timer_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      torrents_duration = (torrents_timer_end - torrents_timer_start).round(2)
      puts "Fetched #{torrents.length} torrents in #{torrents_duration} sec."

      zarr_timer_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      zarr_queue = @zarr_api.queue
      zarr_timer_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      zarr_timer_duration = (zarr_timer_end - zarr_timer_start).round(2)
      puts "Fetched #{zarr_queue.length} queue items in #{zarr_timer_duration} sec."
    end
  end
end
