class Adviser::SignUpAvailability
  attr_reader :application_form, :candidate_matchback, :application_form_validations

  ADVISER_STATUS_CHECK_INTERVAL = 30.minutes
  ADVISER_STATUS = {
    222750000 => ApplicationForm.adviser_statuses[:unassigned],
    222750001 => ApplicationForm.adviser_statuses[:waiting_to_be_assigned],
    222750002 => ApplicationForm.adviser_statuses[:assigned],
    222750003 => ApplicationForm.adviser_statuses[:previously_assigned],
  }.freeze

  def initialize(application_form)
    @application_form = application_form
    @application_form_validations = Adviser::ApplicationFormValidations.new(application_form)
    @candidate_matchback = Adviser::CandidateMatchback.new(application_form)
  end

  def available?
    return false unless feature_active?

    refresh_adviser_status_from_git_api

    application_form_validations.valid?
  rescue GetIntoTeachingApiClient::ApiError => e
    Sentry.capture_exception(e)

    false
  end

  def update_adviser_status(status)
    application_form.update(adviser_status: status)
    Rails.cache.write(adviser_status_check_key, status, expires_in: ADVISER_STATUS_CHECK_INTERVAL)
  end

private

  def refresh_adviser_status_from_git_api
    application_form.update!(adviser_status: adviser_status)
  end

  def adviser_status
    Rails.cache.fetch(adviser_status_check_key, expires_in: ADVISER_STATUS_CHECK_INTERVAL) do
      matchback_candidate = candidate_matchback.matchback
      ADVISER_STATUS[matchback_candidate&.adviser_status_id] || ApplicationForm.adviser_statuses[:unassigned]
    end
  end

  def adviser_status_check_key
    "adviser_status_check_#{application_form.id}"
  end

  def feature_active?
    FeatureFlag.active?(:adviser_sign_up)
  end
end
