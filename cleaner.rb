# frozen_string_literal: true

require 'active_support/inflector'
require_relative 'api/zarr_api'
require_relative 'api/qbittorrent_api'
require_relative 'analyser/decision_engine'

##
# Cleans stalled or slow downloads from Sonarr or Radarr.
class Cleaner
  def initialize(zarr_api, qbittorrent_config)
    @zarr_api = zarr_api
    @qbittorrent_api = QbittorrentApi.new(qbittorrent_config)
    @decision_factory = DecisionEngine.new(zarr_api.config.completion_threshold, zarr_api.config.speed_threshold_kibs)
  end

  ##
  # Cleans up stalled or slow downloads from the relevant client.
  # Prints log output to console as it processes.
  def clean
    free_disk_space_item = @zarr_api.free_disk_space.find { |d| d['path'] == @zarr_api.config.disk_path }
    free_bytes = free_disk_space_item['freeSpace']
    free_bytes_threshold = @zarr_api.config.free_threshold_mib * 1024**2
    if free_bytes < free_bytes_threshold
      puts "#{free_bytes} bytes < minimum (#{free_bytes_threshold}). Skipping run."
      return
    end

    torrents_timer_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    
    begin
      torrents = @qbittorrent_api.torrents({ filter: 'active', category: @zarr_api.config.category })
      torrents += @qbittorrent_api.torrents({ filter: 'stalled', category: @zarr_api.config.category })
    rescue Faraday::Error => e
      return "ERROR: #{e.response[:status]} while fetching torrents."
    end
    
    torrents_timer_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    torrents_duration = (torrents_timer_end - torrents_timer_start).round(2)
    puts "Fetched #{torrents.length} #{'torrent'.pluralize(torrents.length)} in #{torrents_duration} sec."
    puts

    qb_status_boxes = @decision_factory.bulk_decide(torrents)

    print_status_boxes(qb_status_boxes)

    unless qb_status_boxes[:delete].any?
      puts 'Nothing to delete. All done.'
      return
    end

    zarr_timer_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    
    begin
      zarr_queue = @zarr_api.queue
    rescue Faraday::Error
      return "#{e.response[:status]} while fetching #{@zarr_api.config.resource_name}s."
    end
    
    zarr_timer_end = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    zarr_timer_duration = (zarr_timer_end - zarr_timer_start).round(2)
    print "Fetched #{zarr_queue.length} #{@zarr_api.config.resource_name.pluralize(zarr_queue.length)} "
    puts "in #{zarr_timer_duration} sec."

    zarr_no_download_items = zarr_queue.find_all { |z| !z['downloadId'] }
    if zarr_no_download_items.any?
      print "WARNING: Found #{zarr_no_download_items.length} "
      puts "#{@zarr_api.config.resource_name.pluralize(zarr_no_download_items.length)} without download IDs:
#{zarr_no_download_items.map { |z| "  > #{z['title']}" }.uniq.join("\n")}"
      puts
    end

    queue_items_to_delete = zarr_queue.find_all do |z|
      qb_status_boxes[:delete].any? do |q|
        z['downloadId'] && q['hash'] == z['downloadId'].downcase
      end
    end

    delete_match_count = queue_items_to_delete.length
    puts "#{delete_match_count} matched #{@zarr_api.config.resource_name.pluralize(delete_match_count)} to delete."

    print_match_warning(delete_match_count, qb_status_boxes) if delete_match_count < qb_status_boxes[:delete].length

    if delete_match_count > @zarr_api.config.delete_limit
      puts "Limiting deletion from #{delete_match_count} to #{@zarr_api.config.delete_limit}."
    end

    smart_delete(queue_items_to_delete)
  end

  private

  def smart_delete(queue_items_to_delete)
    ids_to_delete = queue_items_to_delete[0...@zarr_api.config.delete_limit].map { |z| z['id'] }

    if defined?(@zarr_api.delete_multiple_queue_items)
      @zarr_api.delete_multiple_queue_items(ids_to_delete)
    else
      ids_to_delete.each { |i| @zarr_api.delete_queue_item(i) }
    end
  end

  def print_match_warning(delete_match_count, qb_status_boxes)
    filtered_commands = @zarr_api.commands.filter do |c|
      @zarr_api.config.commands.include?(c['name']) && c['status'] == 'started'
    end
    print "WARNING: Only matched #{delete_match_count}/#{qb_status_boxes[:delete].length}. "

    if filtered_commands.any?
      print "#{filtered_commands.length} #{'command'.pluralize(filtered_commands.length)} running "
      puts "(#{filtered_commands.map { |c| c['name'] }.uniq.join(', ')})."
    else
      puts 'No commands running.'
    end
  end

  def print_status_boxes(qb_status_boxes)
    puts "New: #{qb_status_boxes[:new].length}"
    puts "Changed: #{qb_status_boxes[:changed].length}"
    puts "Valid: #{qb_status_boxes[:valid].length}"
    puts "Delete: #{qb_status_boxes[:delete].length}"
    puts
  end
end
