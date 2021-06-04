# frozen_string_literal: true

require_relative 'zarr_api'
require_relative '../config/config_factory'

##
# The Radarr V3 API has slightly different structures to the shared Zarr API. This class implements those changed items.
class RadarrApi < ZarrApi
  def initialize
    super(ConfigFactory.radarr)
  end

  def queue(options = {})
    params = {
      page: options[:page] || 1,
      pageSize: options[:page_size] || 100,
      sortDirection: options[:sort_direction] || 'ascending',
      sortKey: options[:sort_key] || 'timeLeft',
      includeUnknownMovieItems: options[:include_unknown_movie_items] || true
    }

    @conn.get('queue', params).body['records']
  end

  ##
  # Delete a single queue item by ID.
  # If +blacklist+ is true, this will prevent the API from fetching this release in the future.
  # +remove_from_client+ should always be true. If false, this causes inconsistency between the API and qBittorrent.
  def delete_queue_item(item_id, blacklist: true, remove_from_client: true)
    @conn.delete("queue/#{item_id}", { removeFromClient: remove_from_client, blacklist: blacklist })
  end

  ##
  # Delete multiple queue items by ID.
  # If +blacklist+ is true, this will prevent the API from fetching this release in the future.
  # +remove_from_client+ should always be true. If false, this causes inconsistency between the API and qBittorrent.
  def delete_multiple_queue_items(item_ids, blacklist: true, remove_from_client: true)
    @conn.delete('queue/bulk') do |req|
      req.params.merge!({ removeFromClient: remove_from_client, blacklist: blacklist })
      req.body = { ids: item_ids }
    end
  end
end
