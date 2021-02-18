module SupportInterface
  class ApplicationReferencesExport
    def data_for_export(run_once_flag = false)
      application_forms = ApplicationForm.includes(:application_choices, application_references: :audits)

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
          output["Ref #{index} requested at"] = reference.requested_at
          output["Ref #{index} received at"] = received_at(reference)
        end

        output
        break if run_once_flag
      end

      # The DataExport class creates the header row for us so we need to ensure
      # we sort by longest hash length to ensure all headers appear
      data_for_export.sort_by(&:length).reverse if data_for_export.present?
    end

  private

    def received_at(reference)
      reference.feedback_provided_at
    end
  end
end
