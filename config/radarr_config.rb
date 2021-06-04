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
    end

    def inspect
      "#{super}
Root folder path:\t\t\t\t#{root_folder_path}
Quality profile ID:\t\t\t#{quality_profile_id}"
    end
  end
end
