module SupportInterface
  class ApplicationReferencesExport
    def self.header_row
      [
        'Support Ref Number',
        'Phase',
        'Ref 1 type',
        'Ref 1 state',
        'Ref 2 type',
        'Ref 2 state',
        'Ref 3 type',
        'Ref 3 state',
        'Ref 4 type',
        'Ref 4 state',
      ]
    end

    def self.call
      application_forms = ApplicationForm.includes(:application_references)

      application_forms.map do |af|
        output = {
          'Support Ref Number' => af.support_reference,
          'Phase' => af.phase,
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
