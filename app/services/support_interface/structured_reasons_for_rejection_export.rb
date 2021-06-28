module SupportInterface
  class StructuredReasonsForRejectionExport
    def data_for_export
      application_choices.order(:id).find_each(batch_size: 100).map do |application_choice|
        {
          candidate_id: application_choice.candidate.id,
          application_choice_id: application_choice.id,
          recruitment_cycle_year: application_choice.course.recruitment_cycle_year,
          phase: application_choice.application_form.phase,
          provider_code: application_choice.provider.code,
          course_code: application_choice.course.code,
          rejected_at: application_choice.rejected_at.iso8601,
          rejected_by_default: application_choice.rejected_by_default,
          reject_by_default_at: application_choice.reject_by_default_at&.iso8601,
          reject_by_default_feedback_sent_at: application_choice.reject_by_default_feedback_sent_at&.iso8601,
        }.merge!(FlatReasonsForRejectionPresenter.build_from_structured_rejection_reasons(ReasonsForRejection.new(application_choice.structured_rejection_reasons)))
      end
    end

  private

    def application_choices
      ApplicationChoice.where.not(structured_rejection_reasons: nil)
    end
  end
end
