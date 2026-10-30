module DataMigrations
  class IncompleteEflSectionForContradictoryEflData
    TIMESTAMP = 20261030135056
    MANUAL_RUN = false

    def change
      contradictory_english_proficiencies= EnglishProficiency
        .joins(:application_form)
        .where(draft: false, has_qualification: true, efl_qualification_id: nil)
        .where(application_forms: { recruitment_cycle_year: 2027 }).pluck(:application_form_id)

      contradictory_english_proficiencies.each do |application_form_id|
        ApplicationForm.find(application_form_id).update!(efl_completed: false)
      end
    end
  end
end
