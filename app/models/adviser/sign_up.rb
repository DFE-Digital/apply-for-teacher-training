class Adviser::SignUp
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :application_form
  attribute :preferred_teaching_subject_id

  validates :preferred_teaching_subject_id, inclusion: { in: :teaching_subject_ids, allow_blank: false }
  validate :application_form_valid_for_adviser_sign_up

  def save
    return false if invalid?

    sign_up_request = Adviser::SignUpRequest.find_or_create_by(application_form: application_form, teaching_subject: preferred_teaching_subject)
    AdviserSignUpWorker.perform_async(sign_up_request.id)

    # application_form.adviser_status_waiting_to_be_assigned!

    true
  end

  def self.build_from_hash(application_form, preferred_teaching_subject_id)
    new(
      application_form:,
      preferred_teaching_subject_id:,
    )
  end

  def primary_teaching_subjects_for_select
    Adviser::TeachingSubject.primary_level
  end

  def secondary_teaching_subjects_for_select
    Adviser::TeachingSubject.secondary_level
  end

  def preferred_teaching_subject
    Adviser::TeachingSubject.find_by(external_identifier: preferred_teaching_subject_id)
  end

private

  def application_form_valid_for_adviser_sign_up
    return if application_form.eligible_and_unassigned_a_teaching_training_adviser?

    errors.add(:application_form, :invalid_adviser_sign_up)
  end

  def teaching_subject_ids
    Adviser::TeachingSubject.pluck(:external_identifier)
  end
end
