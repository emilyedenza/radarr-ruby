# frozen_string_literal: true

module QbittorrentState
  ERROR = 'error'
  MISSING_FILES = 'missingFiles'
  UPLOADING = 'uploading'
  PAUSED_UP = 'pausedUP'
  QUEUED_UP = 'queuedUP'
  STALLED_UP = 'stalledUP'
  CHECKING_UP = 'checkingUP'
  FORCED_UP = 'forcedUP'
  ALLOCATING = 'allocating'
  DOWNLOADING = 'downloading'
  META_DL = 'metaDL'
  PAUSED_DL = 'pausedDL'
  QUEUED_DL = 'queuedDL'
  STALLED_DL = 'stalledDL'
  CHECKING_DL = 'checkingDL'
  FORCED_DL = 'forcedDL'
  CHECKING_RESUME_DATA = 'checkingResumeData'
  MOVING = 'moving'
  UNKNOWN = 'unknown'
end
