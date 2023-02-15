class Adviser::SignUp
  class AdviserSignUpUnavailableError < RuntimeError; end

  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks
  include Adviser::Matchback

  ADVISER_STATUS_CHECK_INTERVAL = 30.minutes

  attr_reader :application_form, :application_form_validations
  attribute :preferred_teaching_subject

  validates :preferred_teaching_subject, inclusion: { in: :teaching_subject_names, allow_blank: false }

  def initialize(application_form, *args, **kwargs)
    @application_form = application_form
    @application_form_validations = Adviser::ApplicationFormValidations.new(application_form)

    super(*args, **kwargs)
  end

  def save
    raise AdviserSignUpUnavailableError unless available?

    return false if invalid?

    AdviserSignUpWorker.perform_async(application_form.id, preferred_teaching_subject_id)

    application_form.update!(signed_up_for_adviser: true)

    true
  end

  def available?
    return false unless feature_active?

    refresh_adviser_status_from_git_api

    application_form_validations.valid?
  rescue GetIntoTeachingApiClient::ApiError => e
    Rails.logger.warn("Adviser sign up unavailable due to API error: #{e.message}")

    false
  end

  def teaching_subjects
    @teaching_subjects ||= GetIntoTeachingApiClient::LookupItemsApi.new.get_teaching_subjects
  end

private

  def refresh_adviser_status_from_git_api
    return if application_form.signed_up_for_adviser

    application_form.update!(signed_up_for_adviser: !can_sign_up_for_adviser?)
  end

  def can_sign_up_for_adviser?
    Rails.cache.fetch(adviser_status_check_key, expires_in: ADVISER_STATUS_CHECK_INTERVAL) do
      matchback_candidate.nil? || matchback_candidate.can_subscribe_to_teacher_training_adviser
    end
  end

  def adviser_status_check_key
    "adviser_status_check_#{application_form.id}"
  end

  def preferred_teaching_subject_id
    teaching_subjects.find { |subject| subject.value == preferred_teaching_subject }&.id
  end

  def teaching_subject_names
    teaching_subjects.map(&:value)
  end

  def feature_active?
    FeatureFlag.active?(:adviser_sign_up)
  end
end
