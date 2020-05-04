module SupportInterface
  class ApplicationChoicesExport
    def application_choices
      relevant_applications.flat_map do |application_form|
        application_form.application_choices.map do |choice|
          {
            support_reference: application_form.support_reference,
            choice_id: choice.id,
            submitted_at: application_form.submitted_at,
            choice_status: choice.status,
            provider_code: choice.provider.code,
            course_code: choice.course.code,
            sent_to_provider_at: choice.sent_to_provider_at,
            reject_by_default_at: choice.reject_by_default_at,
            decline_by_default_at: choice.decline_by_default_at,
            decision: decision_interpretation(choice: choice),
            decided_at: choice.offered_at || choice.rejected_at,
            offer_response: offer_response_interpretation(choice: choice),
            offer_response_at: choice.accepted_at || choice.declined_at,
          }
        end
      end
    end

  private

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

    def offer_response_interpretation(choice:)
      if choice.accepted_at.present?
        :accepted
      elsif choice.declined_by_default? && choice.declined_at.present?
        :declined_by_default
      elsif choice.declined_at.present?
        :declined
      elsif choice.offer?
        :awaiting_candidate
      end
    end

    def relevant_applications
      ApplicationForm
        .includes(
          :candidate,
          application_choices: %i[course provider audits],
        )
        .where('candidates.hide_in_reporting' => false)
        .where.not(submitted_at: nil)
        .order('submitted_at asc')
    end
  end
end
