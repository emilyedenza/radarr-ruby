# frozen_string_literal: true

##
# Stores Redis-specific configuration.
class RedisConfig
  attr_reader :expiry_secs

  def initialize(config_hash)
    @expiry_secs = config_hash['expiry_secs']
  end

  def inspect
    "Expiry secs:\t\t\t#{expiry_secs}"
  end
end
