# frozen_string_literal: true

require_relative 'generic_config'

##
# Stores qBittorrent-specific configuration.
# The (inconsistent) lowercase "Q" is for development rule-following.
class QbittorrentConfig < GenericConfig
  attr_reader :host, :username, :password

  def initialize(config_hash)
    super(config_hash, %w[username password])
    @host = config_hash['host']
    @username = config_hash['username']
    @password = config_hash['password']
  end
end
