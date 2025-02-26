class Adviser::SignUpAvailability
  attr_reader :application_form, :candidate_matchback, :application_form_validations

  ADVISER_STATUS_CHECK_INTERVAL = 30.minutes

  def initialize(application_form)
    @application_form = application_form
    @application_form_validations = Adviser::ApplicationFormValidations.new(application_form)
    @candidate_matchback = Adviser::CandidateMatchback.new(application_form)
  end

  def available?
    return false unless perform_precheck

    application_form_validations.valid?
  end

  def already_assigned_to_an_adviser?
    return false unless perform_precheck

    application_form.adviser_status_assigned? || application_form.adviser_status_previously_assigned?
  end

  def waiting_to_be_assigned_to_an_adviser?
    return false unless perform_precheck

    application_form.adviser_status_waiting_to_be_assigned?
  end

  def update_adviser_status(status)
    application_form.update(adviser_status: status)
    Rails.cache.write(adviser_status_check_key, status, expires_in: ADVISER_STATUS_CHECK_INTERVAL)
  end

private

  def perform_precheck
    return false unless feature_active?

    refresh_adviser_status_from_git_api
  rescue StandardError => e
    Sentry.capture_message('GIT API has returned an error. This error is only logged into Sentry and the candidate is not seeing an error page. But the teacher training advisor feature was not active for this request due to this error. It is recommend to contact the GIT team on #twd_git_bat')
    Sentry.capture_exception(e)

    false
  end

  def refresh_adviser_status_from_git_api
    application_form.update!(adviser_status: adviser_status)
  end

  def adviser_status
    Rails.cache.fetch(adviser_status_check_key, expires_in: ADVISER_STATUS_CHECK_INTERVAL) do
      candidate_matchback.teacher_training_adviser_sign_up.adviser_status
    end
  end

  def adviser_status_check_key
    "adviser_status_check_#{application_form.id}"
  end

  def feature_active?
    FeatureFlag.active?(:adviser_sign_up)
  end
end
