module SupportInterface
  class ApplicationChoicesExport
    def application_choices
      relevant_applications.flat_map do |application_form|
        application_form.application_choices.map do |choice|
          {
            support_reference: application_form.support_reference,
            submitted_at: application_form.submitted_at,
            choice_id: choice.id,
            provider_code: choice.provider.code,
            course_code: choice.course.code,
            sent_to_provider_at: sent_to_provider_audit_entry(choice: choice)&.created_at,
            decided_at: choice.offered_at || choice.rejected_at,
            decision: decision_interpretation(choice: choice),
          }
        end
      end
    end

  private

    def sent_to_provider_audit_entry(choice:)
      choice
        .own_and_associated_audits
        .find_by(audited_changes: { 'status' => %w[application_complete awaiting_provider_decision] })
    end

    def decision_interpretation(choice:)
      if choice.offered_at.present?
        :offered
      elsif choice.rejected_by_default? && choice.rejected_at.present?
        :rejected_by_default
      elsif choice.rejected_at.present?
        :rejected
      elsif choice.awaiting_provider_decision?
        :awaiting_provider
      end
    end

    def relevant_applications
      ApplicationForm
        .includes(
          :candidate,
          :application_choices,
        )
        .where('candidates.hide_in_reporting' => false)
        .where.not(submitted_at: nil)
    end
  end
end
