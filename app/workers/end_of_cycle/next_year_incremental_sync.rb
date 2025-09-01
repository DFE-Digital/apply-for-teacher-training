module EndOfCycle
  class NextYearIncrementalSync < SyncNextYearsCoursesAndProviders
    def perform
      return unless sync_next_year?

      TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async(
        true, # incremental_sync
        next_year, # year
      )
    end
  end
end
