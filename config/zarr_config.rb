# frozen_string_literal: true

require_relative 'generic_config'

##
# Config shared across Radarr and Sonarr
class ZarrConfig < GenericConfig
  attr_reader :base, :sleep_sec, :api_key, :category, :speed_threshold_kibs, :free_threshold_mib, :disk_path,
              :delete_limit, :commands, :completion_threshold, :commands_enabled, :app_name, :resource_name

  def initialize(config_hash)
    super(config_hash, %w[api_key])
    @app_name = '(unknown)'
    @resource_name = '(unknown)'
    @base = config_hash['base']
    @sleep_sec = config_hash['sleep_sec']
    @api_key = config_hash['api_key']
    @category = config_hash['category']
    @speed_threshold_kibs = config_hash['speed_threshold_kibs']
    @free_threshold_mib = config_hash['free_threshold_mib']
    @disk_path = config_hash['disk_path']
    @delete_limit = config_hash['delete_limit']
    @commands = config_hash['commands']
    @completion_threshold = config_hash['completion_threshold']
    @commands_enabled = config_hash['commands_enabled']
  end
end
