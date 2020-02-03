class GetRefereesToChase
  def perform
    application_choices = ApplicationChoice.awaiting_references

    choices_with_applications_submitted_in_the_last_5_days = application_choices.select do |application_choice|
      application_choice.application_form.submitted_at < Time.zone.now - 5.days
    end

    application_forms = choices_with_applications_submitted_in_the_last_5_days.map(&:application_form).uniq

    references = application_forms.map(&:application_references).flatten

    references_feedback_requested = references.select(&:feedback_requested?)

    references_feedback_requested.select { |reference| reference.chasers_sent.referee_mailer_reference_request_chaser_email.blank? }
  end
end
