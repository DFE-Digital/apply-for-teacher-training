module TeacherTrainingPublicAPI
  class SyncAllProvidersAndCoursesWorker
    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform(incremental = true)
      SyncSubjects.new.perform
      SyncAllProvidersAndCourses.call(incremental_sync: incremental)

      if FeatureFlag.active?(:sync_next_cycle)
        SyncAllProvidersAndCourses.call(recruitment_cycle_year: RecruitmentCycle.next_year, incremental_sync: incremental)
      end
    end
  end
end
