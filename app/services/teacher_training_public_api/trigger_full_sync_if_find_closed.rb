module TeacherTrainingPublicAPI
  class TriggerFullSyncIfFindClosed
    def self.call
      if Time.zone.now.between?(CycleTimetable.find_closes, CycleTimetable.find_closes + 1.day)
        TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async(false, ::RecruitmentCycle.next_year, true)
      end
    end
  end
end
