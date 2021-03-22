module SupportInterface
  class ApplicationReferencesExport
    def data_for_export
      application_forms = ApplicationForm.includes(:application_choices, application_references: :audits)

      data_for_export = application_forms.map do |application_form|
        output = {
          recruitment_cycle_year: application_form.recruitment_cycle_year,
          support_reference: application_form.support_reference,
          phase: application_form.phase,
          application_state: ProcessState.new(application_form).state,
        }

        application_form.application_references.map.with_index(1) do |reference, index|
          output[:"ref_#{index}_type"] = reference.referee_type
          output[:"ref_#{index}_state"] = reference.feedback_status
          output[:"ref_#{index}_requested_at"] = reference.requested_at
          output[:"ref_#{index}_received_at"] = received_at(reference)
        end

        output
      end

      # The DataExport class creates the header row for us so we need to ensure
      # we sort by longest hash length to ensure all headers appear
      data_for_export.sort_by(&:length).reverse
    end

  private

    def received_at(reference)
      reference.feedback_provided_at
    end
  end
end
