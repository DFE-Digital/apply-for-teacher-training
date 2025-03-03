class Adviser::SignUp
  class AdviserSignUpUnavailableError < RuntimeError; end

  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attr_reader :application_form, :availability, :teaching_subjects
  attribute :preferred_teaching_subject_id

  delegate :available?, :waiting_to_be_assigned_to_an_adviser?, :already_assigned_to_an_adviser?, to: :availability
  delegate :primary, :secondary, to: :teaching_subjects, prefix: :teaching_subject

  validates :preferred_teaching_subject_id, inclusion: { in: :teaching_subject_ids, allow_blank: false }

  def initialize(application_form, *, **)
    @application_form = application_form
    @availability = Adviser::SignUpAvailability.new(application_form)
    @teaching_subjects = Adviser::TeachingSubjectsService.new

    super(*, **)
  end

  def save
    raise AdviserSignUpUnavailableError unless available?

    return false if invalid?

    AdviserSignUpWorker.perform_async(application_form.id, preferred_teaching_subject_id)

    availability.update_adviser_status(ApplicationForm.adviser_statuses[:waiting_to_be_assigned])

    true
  end

private

  def teaching_subject_ids
    Adviser::TeachingSubject.pluck(:external_identifier)
  end
end
