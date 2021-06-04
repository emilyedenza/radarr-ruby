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
    end

    def inspect
      "#{super}
DB path:\t\t\t\t\t#{db_path}"
    end
  end
end
