module SupportInterface
  class ApplicationChoicesExport
    def application_choices(export_options = {})
      results = []

      relevant_applications(export_options).find_each(batch_size: 100) do |application_form|
        application_form.application_choices.order(:id).each do |choice|
          results << {
            candidate_id: application_form.candidate_id,
            recruitment_cycle_year: application_form.recruitment_cycle_year,
            support_reference: application_form.support_reference,
            phase: application_form.phase,
            submitted_at: application_form.submitted_at,
            application_choice_id: choice.id,
            choice_status: choice.status,
            provider_code: choice.provider.code,
            course_code: choice.course.code,
            sent_to_provider_at: choice.sent_to_provider_at,
            reject_by_default_at: choice.reject_by_default_at,
            decision: decision_interpretation(choice:),
            decided_at: choice.offered_at || choice.rejected_at,
            offer_response: offer_response_interpretation(choice:),
            offer_response_at: choice.accepted_at || choice.declined_at,
            recruited_at: choice.recruited_at,
            rejection_reason: choice.rejection_reason,
            structured_rejection_reasons: FlatReasonsForRejectionPresenter.build_top_level_reasons(choice.structured_rejection_reasons),
          }
        end
      end

      results
    end

    alias data_for_export application_choices

  private

    def decision_interpretation(choice:)
      if choice.offered_at.present?
        :offered
      elsif choice.rejected_by_default? && choice.rejected_at.present?
        :rejected_by_default
      elsif choice.rejected_at.present?
        :rejected
      elsif choice.decision_pending?
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

    def relevant_applications(export_options)
      application_forms = ApplicationForm
        .includes(
          :candidate,
          application_choices: %i[course provider audits],
        )
        .where('candidates.hide_in_reporting' => false)
        .where.not(submitted_at: nil)

      application_forms = application_forms.current_cycle if export_options['current_cycle']

      application_forms.order(:submitted_at)
    end
  end
end
