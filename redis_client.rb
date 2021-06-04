# frozen_string_literal: true

require 'singleton'

##
# Ensures that one shared Redis client is used throughout the application.
class RedisClient
  include Singleton

  attr_reader :client

  def initialize
    @client = Redis.new
    puts @client.ping('Connected to Redis.')
  end
end
