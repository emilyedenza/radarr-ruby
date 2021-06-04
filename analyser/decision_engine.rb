# frozen_string_literal: true

require_relative 'queue_status'
require_relative '../api/qbittorrent_state'
require_relative '../redis_client'
require_relative '../config/config_factory'

##
# Given a configured completion threshold and a speed threshold, determines whether a torrent has changed, should be
# deleted, is newly visible, or is valid and should be left alone.
class DecisionEngine
  def initialize(completion_threshold, speed_threshold_kibs)
    @completion_threshold = completion_threshold
    @speed_threshold_kibs = speed_threshold_kibs
  end

  ##
  # Analyses a +torrent+ download given a last known +cached_state+, and returns a QueueStatus to indicate what should
  # be done with it.
  def decide(torrent, cached_state)
    return QueueStatus::NEW unless cached_state

    return QueueStatus::CHANGED unless torrent['state'] == cached_state

    return QueueStatus::DELETE if torrent['state'] == QbittorrentState::STALLED_DL

    return QueueStatus::DELETE if torrent['state'] == QbittorrentState::META_DL

    return QueueStatus::DELETE if valid_for_deletion(torrent)

    QueueStatus::VALID
  end

  def bulk_decide(torrents)
    status_boxes = { new: [], changed: [], delete: [], valid: [] }
    torrents.each do |t|
      hash = t['hash']
      cached_state = RedisClient.instance.client.get(hash)
      case decide(t, cached_state)
      when QueueStatus::NEW
        status_boxes[:new].append(t)
      when QueueStatus::CHANGED
        status_boxes[:changed].append(t)
      when QueueStatus::DELETE
        status_boxes[:delete].append(t)
      when QueueStatus::VALID
        status_boxes[:valid].append(t)
      end

      RedisClient.instance.client.set(t['hash'], t['state'], ex: ConfigFactory.redis.expiry_secs)
    end
    status_boxes
  end

  private

  def valid_for_deletion(torrent)
    torrent['state'] == QbittorrentState::DOWNLOADING && ((torrent['dlspeed'] < @speed_threshold_kibs * 1024 \
   && torrent['progress'] < @completion_threshold) || torrent['availability'] < 1)
  end
end
