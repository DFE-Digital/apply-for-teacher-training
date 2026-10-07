module TeacherTrainingPublicAPI
  class SyncCheck
    LAST_SUCCESSFUL_SYNC = 'last-successful-sync-with-teacher-training-api'.freeze

    def self.cache_key(cycle_year)
      if cycle_year == RecruitmentCycleTimetable.current_year
        LAST_SUCCESSFUL_SYNC
      else
        "#{LAST_SUCCESSFUL_SYNC}-#{cycle_year}"
      end
    end

    def self.set_last_sync(time, cycle_year)
      key = cache_key(cycle_year)
      Rails.cache.write(key, time)
    end

    def self.clear_last_sync(cycle_year)
      key = cache_key(cycle_year)
      Rails.cache.delete(key)
    end

    def self.last_sync(cycle_year)
      key = cache_key(cycle_year)
      Rails.cache.read(key)
    end

    def self.updated_since(cycle_year)
      last_sync = last_sync(cycle_year)
      if last_sync.present?
        (last_sync - 2.hours).iso8601
      else
        2.hours.ago.iso8601
      end
    end

    def self.check(cycle_year)
      last_sync = last_sync(cycle_year)
      if last_sync.nil?
        false
      else
        last_sync >= 1.hour.ago
      end
    end
  end
end
