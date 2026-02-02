class RedactApplication < DeleteApplication
  def call!
    if !@force && in_flight_applications?
      raise 'Application has inflight applications. You will need to withdrawn the applications first!'
    end

    audit(actor) do
      ActiveRecord::Base.transaction do
        APPLICATION_FORM_FIELDS_TO_REDACT.each { |attr| application_form.send("#{attr}=", nil) }
        application_form.save!

        reference = application_form.support_reference
        application_form.candidate.update!(email_address: "deleted-application-#{reference}@example.com")
        application_form.candidate.one_login_auth&.delete
        application_form.candidate.sessions&.destroy_all

        application_form.own_and_associated_audits.destroy_all
        add_audit_event_for_deletion!
      end
    end
  end

private

  def in_flight_applications?
    application_form
      .application_choices
      .joins(:current_course)
      .where('current_course.recruitment_cycle_year' => RecruitmentCycleTimetable.current_year)
      .exists?(status: ApplicationStateChange::DECISION_PENDING_AND_INACTIVE_STATUSES + ApplicationStateChange::ACCEPTED_STATES)
  end
end
