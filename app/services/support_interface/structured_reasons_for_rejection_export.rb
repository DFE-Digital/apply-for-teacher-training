module SupportInterface
  class StructuredReasonsForRejectionExport
    def data_for_export
      data_for_export = application_choices.order(:id).map do |application_choice|
        output = {
          'Candidate ID' => application_choice.application_form_id,
          'Application ID' => application_choice.id,
          'Recruitment cycle year' => application_choice.course.recruitment_cycle_year,
          'Phase (apply1/apply2)' => application_choice.application_form.phase,
          'Provider code' => application_choice.provider.code,
          'Course code' => application_choice.course.code,
          'Date rejected' => application_choice.rejected_at.strftime('%d/%m/%Y'),
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
