module SyncPreviousYearProvidersAndCourses
  class IncrementalSyncWorker < ApplicationJob
    queue_as :low_priority

    def perform
      TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_later(
        true, # incremental
        previous_year, # year
      )
    end

  private

    def previous_year
      @previous_year ||= RecruitmentCycleTimetable.previous_year
    end
  end
end
