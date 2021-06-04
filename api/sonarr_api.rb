# frozen_string_literal: true

require_relative 'zarr_api'

##
# Performs operations on (and queries data from) Sonarr.
class SonarrApi < ZarrApi
  def initialize(config_hash)
    super
  end
end
