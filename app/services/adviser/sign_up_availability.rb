class Adviser::SignUpAvailability
  include Adviser::Matchback

  attr_reader :application_form, :application_form_validations

  ADVISER_STATUS_CHECK_INTERVAL = 30.minutes

  def initialize(application_form)
    @application_form = application_form
    @application_form_validations = Adviser::ApplicationFormValidations.new(application_form)
  end

  def available?
    return false unless feature_active?

    refresh_adviser_status_from_git_api

    application_form_validations.valid?
  rescue GetIntoTeachingApiClient::ApiError => e
    Rails.logger.warn("Adviser sign up unavailable due to API error: #{e.message}")

    false
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

  def feature_active?
    FeatureFlag.active?(:adviser_sign_up)
  end
end
