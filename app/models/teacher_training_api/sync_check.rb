module TeacherTrainingAPI
  class SyncCheck < OkComputer::Check
    LAST_SUCCESSFUL_SYNC = 'last-successful-sync-with-teacher-training-api'.freeze

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
        mark_message 'Problem finding the time when the Teacher training API sync last succeeded'
      elsif Time.zone.parse(last_date) < (Time.zone.now - 1.hour)
        mark_failure
        mark_message 'The sync with the Teacher training API has not succeeded in an hour'
      else
        mark_message 'The sync with the Teacher training API has succeeded in the last hour'
      end
    end
  end
end
