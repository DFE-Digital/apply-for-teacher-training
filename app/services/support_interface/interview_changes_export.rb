module SupportInterface
  class InterviewChangesExport
    include AuditHelper

    def data_for_export
      rows = interview_audits.find_each(batch_size: 100).lazy.map do |audit|
        row_for_audit(audit)
      end

      rows.reject(&:nil?)
    end

    def row_for_audit(audit)
      interview = audit.auditable
      return if interview.blank?

      application_choice = interview.application_choice
      {
        audit_id: audit.id,
        audit_created_at: audit.created_at,
        audit_type: audit.action,
        interview_id: interview.id,
        candidate_id: application_choice.candidate.id,
        application_choice_id: application_choice.id,
        provider_code: application_choice.provider.code,
        provider_user: audit_user(audit),
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
      if change_by_support?(audit)
        'Support'
      elsif audit.user.present?
        audit.user.email_address
      else
        'Automated process'
      end
    end
  end
end
