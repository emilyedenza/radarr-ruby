# frozen_string_literal: true

require_relative 'zarr_api'
require_relative '../config/config_factory'

##
# Initialises an ordinary Zarr API with Sonarr config variables.
class SonarrApi < ZarrApi
  def initialize
    super(ConfigFactory.sonarr)
  end
end
