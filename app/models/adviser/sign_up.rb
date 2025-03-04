class Adviser::SignUp
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :application_form, :availability, :teaching_subjects
  attribute :preferred_teaching_subject_id

  validates :preferred_teaching_subject_id, inclusion: { in: :teaching_subject_ids, allow_blank: false }
  validate :application_form_valid_for_adviser_sign_up

  def initialize(application_form, *, **)
    @application_form = application_form

    super(*, **)
  end

  def save
    return false if invalid?

    AdviserSignUpWorker.perform_async(application_form.id, preferred_teaching_subject_id)

    application_form.adviser_status_waiting_to_be_assigned!

    true
  end

  def primary_teaching_subjects_for_select
    Adviser::TeachingSubject.primary_level
  end

  def secondary_teaching_subjects_for_select
    Adviser::TeachingSubject.secondary_level
  end

private

  def application_form_valid_for_adviser_sign_up
    return if application_form.eligible_for_teaching_training_adviser?

    errors.add(:application_form, :invalid_adviser_sign_up)
  end

  def teaching_subject_ids
    Adviser::TeachingSubject.pluck(:external_identifier)
  end
end
