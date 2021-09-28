module TeacherTrainingPublicAPI
  class SyncAllProvidersAndCoursesWorker
    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :low_priority

    def perform(incremental = true, suppress_sync_update_errors = false)
      return if HostingEnvironment.review?

      SyncSubjects.new.perform

      SyncAllProvidersAndCourses.call(
        recruitment_cycle_year: SyncCycle.current_year,
        incremental_sync: incremental,
        suppress_sync_update_errors: suppress_sync_update_errors,
      )

      if FeatureFlag.active?(:sync_next_cycle)
        SyncAllProvidersAndCourses.call(
          recruitment_cycle_year: SyncCycle.next_year,
          incremental_sync: incremental,
          suppress_sync_update_errors: suppress_sync_update_errors,
        )
      end
    end
  end
end
