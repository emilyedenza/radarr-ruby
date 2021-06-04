# frozen_string_literal: true

require_relative 'generic_config'

##
# Stores Redis-specific configuration.
class RedisConfig < GenericConfig
  attr_reader :expiry_secs, :host

  def initialize(config_hash)
    super
    @expiry_secs = config_hash['expiry_secs']
    @host = config_hash['host']
  end
end
