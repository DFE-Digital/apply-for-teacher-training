module SupportInterface
  class StructuredReasonsForRejectionExport
    def data_for_export
      data_for_export = application_choices.order(:id).map do |application_choice|
        output = {
          candidate_id: application_choice.application_form_id,
          application_choice_id: application_choice.id,
          recruitment_cycle_year: application_choice.course.recruitment_cycle_year,
          phase: application_choice.application_form.phase,
          provider_code: application_choice.provider.code,
          course_code: application_choice.course.code,
          rejected_at: application_choice.rejected_at.strftime('%d/%m/%Y'),
        }.merge!(FlatReasonsForRejectionPresenter.build_from_structured_rejection_reasons(ReasonsForRejection.new(application_choice.structured_rejection_reasons)))

        output
      end

      data_for_export
    end

  private

    def application_choices
      ApplicationChoice.where.not(structured_rejection_reasons: nil)
    end
  end
end
