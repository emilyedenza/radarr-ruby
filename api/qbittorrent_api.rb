# frozen_string_literal: true

##
# Interacts with, and manages, the QBittorrent API.
class QbittorrentApi
  def initialize(qbittorrent_config)
    auth_cookie = log_in(qbittorrent_config.host, qbittorrent_config.username, qbittorrent_config.password)

    @conn = Faraday.new(url: qbittorrent_config.host) do |f|
      f.request(:retry)
      f.request(:json)
      f.response(:follow_redirects)
      f.response(:raise_error)
      f.response(:json)
      f.headers = { Cookie: auth_cookie }
    end
  end

  def torrents(options = {})
    response = @conn.get('torrents/info') do |req|
      req.params = { filter: options[:filter], category: options[:category], sort: options[:sort],
                     reverse: options[:reverse], limit: options[:limit], offset: options[:offset],
                     hashes: options[:hashes] }
    end
    response.body
  end

  private

  def log_in(host, username, password)
    login_response = Faraday.post("#{host}/auth/login") do |req|
      req.body = { username: username, password: password }
    end

    case login_response.body
    when 'Fails.'
      raise 'QBittorrent username/password combination incorrect.'
    when 'Ok.'
      login_response.headers['set-cookie']
    else
      raise "Unknown error when logging into QBittorrent: #{login_response.body}"
    end
  end
end
