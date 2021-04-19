module TeacherTrainingPublicAPI
  class SyncAllProvidersAndCoursesWorker
    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform
      SyncSubjects.new.perform
      SyncAllProvidersAndCourses.call
    end
  end
end
