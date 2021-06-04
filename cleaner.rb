# frozen_string_literal: true
#
require 'set'
require_relative 'api/zarr_api'

module RadarrRuby
  ##
  # Cleans stalled or slow downloads from Sonarr or Radarr.
  class Cleaner
    attr_reader :commands_enabled, :zarr_db_path, :stuck_threshold, :commands, :delete_limit, :singular_name,
                :speed_threshold_kibs, :category, :disk_path, :free_threshold_mib, :zarr_api, :clean_analyser,
                :redis_stuck_label

    ##
    # Generates a cleaner instance for Radarr.
    def self.radarr(radarr_config)
      Cleaner.new(ZarrApi.new(radarr_config))
    end

    ##
    # Generates a cleaner instance for Sonarr.
    def self.sonarr(sonarr_config)
      Cleaner.new(ZarrApi.new(sonarr_config))
    end

    def initialize(api)
      @api = api
    end

    ##
    # Cleans up stalled or slow downloads from the relevant client.
    def clean
      hashes_to_delete = Set.new
      titles_to_delete = []

      # begin
        # free_space = zarr_api.get_free_disk_space
        # rescue read timeout
        # rescue status error
      # end

      # free_space_threshold_bytes = free_threshold_mib * 1024 ** 2
      @api.queue
    end
  end
end
