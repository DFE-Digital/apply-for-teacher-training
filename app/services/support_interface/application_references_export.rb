module SupportInterface
  class ApplicationReferencesExport
    def data_for_export
      application_forms = ApplicationForm.includes(:application_references)

      application_forms.map do |af|
        output = {
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
    end
  end
end
