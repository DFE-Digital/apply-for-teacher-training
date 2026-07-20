module EndOfCycle
  class NextYearIncrementalSync < SyncNextYearsCoursesAndProviders
    self.queue_adapter = :solid_queue

    def perform
      return unless sync_next_year?

      TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_later(
        true, # incremental_sync
        next_year, # year
      )
    end
  end
end
