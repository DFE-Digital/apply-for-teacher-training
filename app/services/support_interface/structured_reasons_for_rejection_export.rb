module SupportInterface
  class StructuredReasonsForRejectionExport
    def data_for_export
      data_for_export = application_choices.order(:id).map do |application_choice|
        output = {
          'Candidate ID' => application_choice.application_form_id,
          'Application ID' => application_choice.id,
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
