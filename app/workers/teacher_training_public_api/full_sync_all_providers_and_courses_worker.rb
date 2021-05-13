module TeacherTrainingPublicAPI
  class FullSyncAllProvidersAndCoursesWorker
    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform
      SyncSubjects.new.perform
      SyncAllProvidersAndCourses.call(incremental_sync: false)
    end
  end
end
