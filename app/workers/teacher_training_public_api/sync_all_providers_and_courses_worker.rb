module TeacherTrainingPublicAPI
  class SyncAllProvidersAndCoursesWorker
    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :low_priority

    def perform(incremental = true, year = nil, suppress_sync_update_errors = false)
      return if HostingEnvironment.review? || FeatureFlag.active?(:disable_publish_sync)

      year ||= year_to_sync

      SyncSubjects.new.perform
      SyncAllProvidersAndCourses.call(
        recruitment_cycle_year: year,
        incremental_sync: incremental,
        suppress_sync_update_errors:,
      )
    end

  private

    def year_to_sync
      if CycleTimetable.find_down?
        ::RecruitmentCycle.next_year
      else
        ::RecruitmentCycle.current_year
      end
    end
  end
end
