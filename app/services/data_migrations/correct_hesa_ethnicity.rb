module DataMigrations
  class CorrectHesaEthnicity
    TIMESTAMP = 20241024110710
    MANUAL_RUN = false

    def change
      application_forms.update_all(
        "equality_and_diversity = jsonb_set(equality_and_diversity, '{hesa_ethnicity}', '\"179\"', false)",
      )
    end

  private

    def application_forms
      ApplicationForm
        .where(recruitment_cycle_year: [2023, 2024])
        .where("equality_and_diversity->>'hesa_ethnicity' = ?", '160')
        .where("equality_and_diversity->>'ethnic_background' != ?", 'British, English, Northern Irish, Scottish, or Welsh')
    end
  end
end
