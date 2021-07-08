module TeacherTrainingPublicAPI
  class IncrementalSyncAllProvidersAndCoursesWorker
    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform
      SyncSubjects.new.perform
      SyncAllProvidersAndCourses.call

      if FeatureFlag.active?(:sync_next_cycle)
        SyncAllProvidersAndCourses.call(recruitment_cycle_year: RecruitmentCycle.next_year)
      end
    end
  end
end
