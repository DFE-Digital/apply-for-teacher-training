module DataMigrations
  class NormalizeNamesOnApplicationForm
    TIMESTAMP = 20260602110000
    MANUAL_RUN = false

    def change
      forms_with_unnormalized_names do |application_form|
        columns.each do |column|
          next if application_form[column].nil?

          application_form[column] = application_form[column].strip
        end

        application_form.save!
      end
    end

  private

    def forms_with_unnormalized_names
      current_forms.where('first_name <> TRIM(first_name) OR last_name <> TRIM(last_name)')
    end

    def current_forms
      @current_forms ||= ApplicationForm.where(recruitment_cycle_year: [2025, 2026])
    end

    def columns
      %i[first_name last_name]
    end
  end
end
