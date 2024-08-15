module DataMigrations
  class BackfillEnglishProficiencyRecordsForCarriedOverApplications
    TIMESTAMP = 20240815092638
    MANUAL_RUN = false

    IGNORED_ATTRIBUTES = %w[id created_at updated_at application_form_id].freeze

    def change
      problem_application_forms.find_each do |application_form|
        previous_english_proficiency = application_form.previous_application_form.english_proficiency

        efl_qualification = if previous_english_proficiency.efl_qualification.present?
                              previous_english_proficiency.efl_qualification_type.constantize.new(
                                **previous_english_proficiency.efl_qualification.attributes.except(*IGNORED_ATTRIBUTES),
                              )
                            end
        EnglishProficiency.create!(
          **previous_english_proficiency.attributes.except(*IGNORED_ATTRIBUTES),
          efl_qualification:,
          application_form:,
        )
      end
    end

    def problem_application_forms
      ApplicationForm
        .current_cycle
        .unsubmitted
        .where.missing(:english_proficiency)
        .where(efl_completed: true)
        .where(previous_application_form_id: previous_applications_with_english_proficiencies_ids)
        .includes(previous_application_form: :english_proficiency)
    end

    def previous_applications_with_english_proficiencies_ids
      ApplicationForm
        .where('recruitment_cycle_year < ?', 2024)
        .where.associated(:english_proficiency)
        .pluck(:id)
    end
  end
end
