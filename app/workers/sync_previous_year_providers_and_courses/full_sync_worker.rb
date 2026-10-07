module SyncPreviousYearProvidersAndCourses
  class FullSyncWorker < ApplicationJob
    queue_as :low_priority

    def perform
      TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_later(
        false, # incremental
        previous_year, # year
      )
    end

  private

    def previous_year
      @previous_year ||= RecruitmentCycleTimetable.previous_year
    end
  end
end
