module SupportInterface
  class ApplicationChoicesExport
    def application_choices
      results = []

      relevant_applications.find_each(batch_size: 100) do |application_form|
        application_form.application_choices.each do |choice|
          results << {
            candidate_id: application_form.candidate_id,
            recruitment_cycle_year: application_form.recruitment_cycle_year,
            support_reference: application_form.support_reference,
            phase: application_form.phase,
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
            recruited_at: choice.recruited_at,
            rejection_reason: choice.rejection_reason,
            structured_rejection_reasons: FlatReasonsForRejectionExtract.build_high_level(choice.structured_rejection_reasons),
          }
        end
      end

      results
    end

    alias_method :data_for_export, :application_choices

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
