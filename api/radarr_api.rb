# frozen_string_literal: true

require_relative 'zarr_api'
require_relative '../config/config_factory'

##
# The Radarr V3 API has slightly different structures to the shared Zarr API. This class implements those changed items.
class RadarrApi < ZarrApi
  def initialize
    super(ConfigFactory.radarr)
  end

  def queue
    @conn.get('queue').body['records']
  end
end
