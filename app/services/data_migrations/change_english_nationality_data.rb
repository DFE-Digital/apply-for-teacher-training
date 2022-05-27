module DataMigrations
  class ChangeEnglishNationalityData
    TIMESTAMP = 20220525155807
    MANUAL_RUN = false

    def change
      ApplicationForm.where(first_nationality: %w[English Welsh Scottish], recruitment_cycle_year: 2022).each do |nationality|
        nationality.update!(first_nationality: 'British')
      end
    end

    def dry_run
      total_number = ApplicationForm.where(first_nationality: %w[English Welsh Scottish], recruitment_cycle_year: 2022)

      Rails.logger.debug { "There are #{total_number.size} records with English, Welsh or Scottish as their first nationality" }
    end
  end
end
