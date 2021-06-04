# frozen_string_literal: true

require_relative 'zarr_config'

module RadarrRuby
  ##
  # Stores Sonarr-specific configuration.
  class SonarrConfig < ZarrConfig
    attr_reader :db_path

    def initialize(config)
      super
      @db_path = config['db_path']
      @app_name = 'Sonarr'
      @resource_name = 'show'
    end
  end
end
