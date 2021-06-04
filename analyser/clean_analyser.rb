# frozen_string_literal: true

require_relative 'queue_status'
require_relative '../api/qbittorrent_state'

##
# Given a configured completion threshold and a speed threshold, determines whether a torrent has changed, should be
# deleted, is newly visible, or is valid and should be left alone.
class CleanAnalyser
  def initialize(completion_threshold, speed_threshold_kibs)
    @completion_threshold = completion_threshold
    @speed_threshold_kibs = speed_threshold_kibs
  end

  ##
  # Analyses a +torrent+ download given a last known +cached_state+, and returns a QueueStatus to indicate what should
  # be done with it.
  def analyse(torrent, cached_state)
    return QueueStatus::NEW unless cached_state

    return QueueStatus::CHANGED unless torrent['state'] == cached_state

    return QueueStatus::DELETE if torrent['state'] == QbittorrentState::STALLED_DL

    return QueueStatus::DELETE if torrent['state'] == QbittorrentState::META_DL

    if torrent['state'] == QbittorrentState::DOWNLOADING && ((torrent['dlspeed'] < @speed_threshold_kibs * 1024 \
 && torrent['progress'] < @completion_threshold) || torrent['availability'] < 1)
      return QueueStatus::DELETE
    end

    QueueStatus::VALID
  end
end
