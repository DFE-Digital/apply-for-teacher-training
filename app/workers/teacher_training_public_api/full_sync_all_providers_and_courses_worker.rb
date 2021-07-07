module TeacherTrainingPublicAPI
  class FullSyncAllProvidersAndCoursesWorker
    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform
      SyncSubjects.new.perform
      SyncAllProvidersAndCourses.call(incremental_sync: false)

      if FeatureFlag.active?(:sync_next_cycle)
        SyncAllProvidersAndCourses.call(recruitment_cycle_year: RecruitmentCycle.next_year, incremental_sync: false)
      end
    end
  end
end
