module TeacherTrainingPublicAPI
  class SyncSubjects
    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform
      TeacherTrainingPublicAPI::Subject.paginate(per_page: 500).each do |api_subject|
        subject = ::Subject.find_or_create_by(code: api_subject.code)
        subject.update(name: api_subject.name)
      end
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end
  end
end
