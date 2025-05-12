module TeacherTrainingPublicAPI
  class SyncAllProvidersAndCoursesWorker
    include Sidekiq::Worker

    sidekiq_options retry: 3, queue: :low_priority

    def perform(incremental = true, year = nil)
      return if HostingEnvironment.review?

      year ||= year_to_sync

      SyncSubjects.new.perform
      SyncAllProvidersAndCourses.call(
        recruitment_cycle_year: year,
        incremental_sync: incremental,
      )
    end

  private

    def year_to_sync
      if RecruitmentCycleTimetable.current_timetable.after_find_closes?
        RecruitmentCycleTimetable.next_year
      else
        RecruitmentCycleTimetable.current_year
      end
    end
  end
end
