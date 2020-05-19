class FindSyncCheck < OkComputer::Check
  LAST_SUCCESSFUL_SYNC = 'last-successful-sync-with-find'.freeze

  def self.set_last_sync(date)
    Redis.current.set(LAST_SUCCESSFUL_SYNC, date)
  end

  def self.clear_last_sync
    Redis.current.del(LAST_SUCCESSFUL_SYNC)
  end

  def self.last_sync
    Redis.current.get(LAST_SUCCESSFUL_SYNC)
  end

  def check
    last_date = self.class.last_sync

    if last_date.nil?
      mark_failure
      mark_message 'Problem finding the time when the Find sync last succeeded'
    elsif Time.zone.parse(last_date) < (Time.zone.now - 1.hour)
      mark_failure
      mark_message 'The sync with Find hasn\'t succeeded in an hour'
    else
      mark_message 'The sync with Find has succeeded in the last hour'
    end
  end
end
