# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

##
# Makes requests to Sonarr and Radarr APIs (as operations between the two are interchangeable).
# The "Z" in Zarr is a placeholder to indicate that it works across both Sonarr and Radarr.
class ZarrApi
  attr_reader :config

  def initialize(zarr_config)
    @config = zarr_config
    retry_options = {
      max: 20,
      interval: 0.1,
      backoff_factor: 2,
    }
    @conn = Faraday.new(url: zarr_config.base, params: { apikey: zarr_config.api_key }) do |f|
      f.request(:json)
      f.request(:retry, retry_options)
      f.response(:follow_redirects)
      f.response(:json)
      f.response(:raise_error)
    end
  end

  ##
  # Delete a single queue item by ID.
  # If +blacklist+ is true, this will prevent the API from fetching this release in the future.
  def delete_queue_item(item_id, blacklist: true)
    @conn.delete("queue/#{item_id}", { blacklist: blacklist })
  end

  ##
  # Query all movie/show downloads.
  def queue
    @conn.get('queue').body
  end

  ##
  # Query API for free disk space.
  def free_disk_space
    @conn.get('diskspace').body
  end

  ##
  # Query currently running commands.
  def commands
    @conn.get('command').body
  end

  ##
  # Restart the whole Zarr application.
  def restart
    @conn.post('system/restart').body
  end
end
