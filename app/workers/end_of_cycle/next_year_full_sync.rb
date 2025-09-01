module EndOfCycle
  class NextYearFullSync < SyncNextYearsCoursesAndProviders
    def perform
      return unless sync_next_year?

      TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async(
        false, # incremental_sync
        next_year, # year
      )
    end
  end
end
