module SupportInterface
  class ApplicationReferencesExport
    def data_for_export
      application_forms = ApplicationForm.includes(:application_references, :application_choices)

      data_for_export = application_forms.map do |af|
        output = {
          'Recruitment cycle year' => af.recruitment_cycle_year,
          'Support ref number' => af.support_reference,
          'Phase' => af.phase,
          'Application state' => ProcessState.new(af).state,
        }

        af.application_references.map.with_index(1) do |reference, index|
          output["Ref #{index} type"] = reference.referee_type
          output["Ref #{index} state"] = reference.feedback_status
        end

        output
      end

      # The DataExport class creates the header row for us so we need to ensure
      # we sort by longest hash length to ensure all headers appear
      data_for_export.sort_by(&:length).reverse
    end
  end
end
