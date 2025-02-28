class Adviser::FetchTeachingSubjectsWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low_priority

  def perform
    # Get the subjects from the API
    # Find or Create TeachingSubject using the ID/external_identifier
    teaching_subject_from_api = api_teaching_subjects.map do |api_teaching_subject|
      external_identifier = api_teaching_subject.id
      title = api_teaching_subject.value
      level = api_teaching_subject.id == primary_subject_id ? 'primary' : 'secondary'

      teaching_subject = Adviser::TeachingSubject.find_or_initialize_by(external_identifier:)
      teaching_subject.title = title
      teaching_subject.level = level
      teaching_subject.save!
      teaching_subject
    end
    # Find all other TeachingSubjects and soft delete them
    Adviser::TeachingSubject.excluding(teaching_subject_from_api).discard_all
  end

private

  def api_teaching_subjects
    GetIntoTeachingApiClient::LookupItemsApi.new
                                            .get_teaching_subjects
                                            .reject do |subject|
      subject.id.in?(exclude_subject_ids)
    end
  end

  def primary_subject_id
    Adviser::Constants.fetch(:teaching_subjects, :primary)
  end

  def exclude_subject_ids
    Adviser::Constants.fetch(:teaching_subjects, :excluded).values
  end
end
