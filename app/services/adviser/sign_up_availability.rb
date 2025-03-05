class Adviser::SignUpAvailability
  attr_reader :application_form

  ADVISER_STATUS_CHECK_INTERVAL = 30.minutes

  def initialize(application_form)
    @application_form = application_form
  end

  def eligible_for_an_adviser?
    refresh_adviser_status

    application_form.eligible_for_teaching_training_adviser?
  end

  def already_assigned_to_an_adviser?
    refresh_adviser_status

    application_form.adviser_status_assigned? || application_form.adviser_status_previously_assigned?
  end

  def waiting_to_be_assigned_to_an_adviser?
    refresh_adviser_status

    application_form.adviser_status_waiting_to_be_assigned?
  end

private

  def refresh_adviser_status
    Rails.cache.fetch(adviser_status_check_key, expires_in: ADVISER_STATUS_CHECK_INTERVAL) do
      Adviser::RefreshAdviserStatusWorker.perform_async(application_form.id)
      true
    end
  end

  def adviser_status_check_key
    "adviser_status_check_#{application_form.id}"
  end
end
