# frozen_string_literal: true
require 'faraday'
require 'faraday_middleware'

##
# Makes requests to Sonarr and Radarr APIs (as operations between the two are interchangeable).
class ZarrApi
  def initialize(zarr_config)
    @conn = Faraday.new(url: zarr_config.base, params: { apikey: zarr_config.api_key }) do |f|
      f.request(:json)
      f.request(:retry)
      f.response(:follow_redirects)
      f.response(:json)
      f.response(:raise_error)
    end
  end

  def delete_queue_item(item_id, should_blacklist: true)
    @conn.delete("queue/#{item_id}", { should_blacklist: should_blacklist })
  end

  def fetch_queue
    @conn.get('queue').body
  end

  def get_free_disk_space; end

  def get_commands; end

  def restart; end
end