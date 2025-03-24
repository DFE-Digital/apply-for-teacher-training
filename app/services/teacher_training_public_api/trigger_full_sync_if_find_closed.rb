module TeacherTrainingPublicAPI
  class TriggerFullSyncIfFindClosed
    def self.call
      timetable = RecruitmentCycleTimetable.current_timetable
      return unless timetable.after_find_closes?

      TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async(false, timetable.relative_next_year, true)
    end
  end
end
