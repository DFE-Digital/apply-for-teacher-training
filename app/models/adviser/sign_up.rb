class Adviser::SignUp
  class AdviserSignUpUnavailableError < RuntimeError; end

  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attr_reader :application_form, :availability
  attribute :preferred_teaching_subject

  delegate :available?, to: :availability

  validates :preferred_teaching_subject, inclusion: { in: :teaching_subject_names, allow_blank: false }

  def initialize(application_form, *args, **kwargs)
    @application_form = application_form
    @availability = Adviser::SignUpAvailability.new(application_form)

    super(*args, **kwargs)
  end

  def save
    raise AdviserSignUpUnavailableError unless available?

    return false if invalid?

    AdviserSignUpWorker.perform_async(application_form.id, preferred_teaching_subject_id)

    availability.update_adviser_status(ApplicationForm.adviser_statuses[:waiting_to_be_assigned])

    true
  end

  def teaching_subjects
    @teaching_subjects ||= GetIntoTeachingApiClient::LookupItemsApi.new.get_teaching_subjects
  end

private

  def preferred_teaching_subject_id
    teaching_subjects.find { |subject| subject.value == preferred_teaching_subject }&.id
  end

  def teaching_subject_names
    teaching_subjects.map(&:value)
  end
end
