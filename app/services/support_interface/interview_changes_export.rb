module SupportInterface
  class InterviewChangesExport
    def data_for_export
      interview_audits.find_each(batch_size: 100).map do |audit|
        row_for_audit(audit)
      end
    end

    def row_for_audit(audit)
      interview = audit.auditable
      application_choice = interview.application_choice
      {
        audit_id: audit.id,
        audit_created_at: audit.created_at,
        audit_type: audit.action,
        interview_id: interview.id,
        candidate_id: application_choice.candidate.id,
        application_form_id: application_choice.application_form.id,
        provider_code: application_choice.provider.code,
        provider_user: audit_user(audit),
        interview_status: interview_status(interview, audit),
        interview_preferences: application_choice.application_form.interview_preferences,
        application_submitted_at: application_choice.application_form.submitted_at,
        course_code: application_choice.course.code,
        course_location: application_choice.site.name_and_code,
      }.merge(interview_change(audit))
    end

  private

    def interview_audits
      Audited::Audit.where(auditable_type: 'Interview').includes(
        :user,
        auditable: {
          application_choice: %i[application_form course site candidate provider],
        },
      )
    end

    def interview_status(interview, audit)
      if audit.created_at < interview_time_when_change_made(interview, audit)
        'upcoming'
      else
        'past'
      end
    end

    def interview_time_when_change_made(interview, audit)
      # We want to return the time the interview was scheduled for at the time of the audit.
      # If the time was changed, then return the original time from the audited_changes.
      # If the time was not changed, then it is either an upcoming interview (since the validation means you can't make it in the past)
      # or it is a cancellation and the interview time on the interview model is representative.
      interview_time_from_audit(audit).presence || interview.date_and_time
    end

    def interview_time_from_audit(audit)
      audited_time = audit.audited_changes['date_and_time']
      if audited_time.is_a?(Array)
        Time.zone.parse(audited_time.first)
      elsif audited_time.present?
        Time.zone.parse(audited_time)
      end
    end

    def interview_change(audit)
      changes = changed_attributes(audit)
      {
        date_and_time: change_to_attr(changes, 'date_and_time'),
        cancelled_at: change_to_attr(changes, 'cancelled_at'),
        cancellation_reason: change_to_attr(changes, 'cancellation_reason'),
        provider_id: change_to_attr(changes, 'provider_id'),
        location: change_to_attr(changes, 'location'),
        additional_details: change_to_attr(changes, 'additional_details'),
      }
    end

    def changed_attributes(audit)
      if audit.action == 'update'
        audit.audited_changes.transform_values(&:last)
      else
        audit.audited_changes
      end
    end

    def change_to_attr(changes, attr)
      if changes.keys.include?(attr)
        changes[attr]
      else
        ''
      end
    end

    def audit_user(audit)
      if audit.user_type == 'SupportUser'
        'Support'
      elsif audit.user.present?
        audit.user.email_address
      else
        'Automated process'
      end
    end
  end
end
