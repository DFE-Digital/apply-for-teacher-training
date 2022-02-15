module TeacherTrainingPublicAPI
  class SyncCheck
    LAST_SUCCESSFUL_SYNC = 'last-successful-sync-with-teacher-training-api'.freeze

    def self.set_last_sync(time)
      Redis.new.set(LAST_SUCCESSFUL_SYNC, time)
    end

    def self.clear_last_sync
      Redis.new.del(LAST_SUCCESSFUL_SYNC)
    end

    def self.last_sync
      Redis.new.get(LAST_SUCCESSFUL_SYNC)
    end

    def self.updated_since
      if last_sync.present?
        Time.zone.parse(last_sync) - 2.hours
      else
        2.hours.ago
      end
    end

    def self.check
      if last_sync.nil?
        false
      else
        Time.zone.parse(last_sync) >= 1.hour.ago
      end
    end
  end
end
