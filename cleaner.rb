# frozen_string_literal: true
#

require_relative 'api/zarr_api'
require_relative 'api/qbittorrent_api'
require_relative 'analyser/clean_analyser'

module RadarrRuby
  ##
  # Cleans stalled or slow downloads from Sonarr or Radarr.
  class Cleaner
    attr_reader :commands_enabled, :zarr_db_path, :stuck_threshold, :commands, :delete_limit, :singular_name,
                :speed_threshold_kibs, :category, :disk_path, :free_threshold_mib, :zarr_api, :clean_analyser,
                :redis_stuck_label

    def initialize(zarr_config, qbittorrent_config, redis_client, redis_config)
      @zarr_api = ZarrApi.new(zarr_config)
      @zarr_config = zarr_config
      @qbittorrent_api = QbittorrentApi.new(qbittorrent_config)
      @redis_client = redis_client
      @clean_analyser = CleanAnalyser.new(zarr_config.completion_threshold, zarr_config.speed_threshold_kibs)
      @redis_config = redis_config
    end

    ##
    # Cleans up stalled or slow downloads from the relevant client.
    # Prints log output to console as it processes.
    def clean
      qbittorrent_status_boxes = { new: [], changed: [], delete: [], valid: [] }

      free_disk_space_item = @zarr_api.free_disk_space.find { |d| d['path'] == @zarr_config.disk_path }
      free_bytes = free_disk_space_item['freeSpace']
      free_bytes_threshold = @zarr_config.free_threshold_mib * 1024**2
      if free_bytes < free_bytes_threshold
        puts "#{free_bytes} bytes < minimum (#{free_bytes_threshold}). Skipping run."
        return
      end

      torrents_timer_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      torrents = @qbittorrent_api.torrents({ filter: 'active', category: @zarr_config.category })
      torrents += @qbittorrent_api.torrents({ filter: 'stalled', category: @zarr_config.category })
      torrents_timer_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      torrents_duration = (torrents_timer_end - torrents_timer_start).round(2)
      puts "Fetched #{torrents.length} torrents in #{torrents_duration} sec."
      puts

      torrents.each do |t|
        hash = t['hash']
        cached_state = @redis_client.get(hash)
        case @clean_analyser.analyse(t, cached_state)
        when QueueStatus::NEW
          qbittorrent_status_boxes[:new].append(t)
        when QueueStatus::CHANGED
          qbittorrent_status_boxes[:changed].append(t)
        when QueueStatus::DELETE
          qbittorrent_status_boxes[:delete].append(t)
        when QueueStatus::VALID
          qbittorrent_status_boxes[:valid].append(t)
        end

        @redis_client.set(t['hash'], t['state'], ex: @redis_config.expiry_secs)
      end

      puts "New: #{qbittorrent_status_boxes[:new].length}"
      puts "Changed: #{qbittorrent_status_boxes[:changed].length}"
      puts "Valid: #{qbittorrent_status_boxes[:valid].length}"
      puts "Delete: #{qbittorrent_status_boxes[:delete].length}"
      puts

      zarr_timer_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      zarr_queue = @zarr_api.queue
      zarr_timer_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      zarr_timer_duration = (zarr_timer_end - zarr_timer_start).round(2)
      puts "Fetched #{zarr_queue.length} queue items in #{zarr_timer_duration} sec."

      queue_items_to_delete = zarr_queue.find_all do |z|
        qbittorrent_status_boxes[:delete].any? do |q|
          q['hash'] == z['downloadId'].downcase
        end
      end
      puts "#{queue_items_to_delete.length} matched queue items to delete."

      if queue_items_to_delete.length > @zarr_config.delete_limit
        puts "Limiting deletion from #{queue_items_to_delete.length} to #{@zarr_config.delete_limit}."
      end

      queue_items_to_delete[0...@zarr_config.delete_limit].each { |z| @zarr_api.delete_queue_item(z['id']) }
    end
  end
end
