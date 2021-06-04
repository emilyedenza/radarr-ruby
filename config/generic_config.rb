# frozen_string_literal: true

##
# Allows for convenient inspection to show config summary.
class GenericConfig
  def initialize(config_hash, redacted_keys = [])
    @config_hash = config_hash
    @redacted_keys = redacted_keys
  end

  def inspect
    @config_hash.map { |k, v| config_output(k, v) }.join("\n")
  end

  private

  def config_output(label, value)
    format('%-<label>25s: %<value>40s',
           { label: label, value: @redacted_keys.include?(label) ? '*' * 8 : value })
  end
end
