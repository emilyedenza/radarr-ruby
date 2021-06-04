# frozen_string_literal: true

module RadarrRuby
  ##
  # Stores Radarr-specific configuration.
  class RadarrConfig < ZarrConfig
    attr_reader :root_folder_path, :quality_profile_id

    def initialize(config)
      super
      @root_folder_path = config['root_folder_path']
      @quality_profile_id = config['quality_profile_id']
      @app_name = 'Radarr'
      @resource_name = 'movie'
    end
  end
end
