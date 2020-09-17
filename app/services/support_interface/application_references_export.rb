module SupportInterface
  class ApplicationReferencesExport
    def self.header_row
      header_row = [
        'Support ref number',
        'Phase',
        'Application state',
      ]

      ApplicationForm::MAXIMUM_REFERENCES.times do |i|
        header_row << "Ref #{i + 1} type"
        header_row << "Ref #{i + 1} state"
      end

      header_row
    end

    def self.call
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
