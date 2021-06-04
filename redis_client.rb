# frozen_string_literal: true

require 'singleton'
require_relative 'config/config_factory'

##
# Ensures that one shared Redis client is used throughout the application.
class RedisClient
  include Singleton

  attr_reader :client

  def initialize
    @client = Redis.new({ url: ConfigFactory.redis.host })
  end
end
