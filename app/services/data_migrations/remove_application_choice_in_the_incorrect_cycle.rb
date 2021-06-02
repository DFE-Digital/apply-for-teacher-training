module DataMigrations
  class RemoveApplicationChoiceInTheIncorrectCycle
    TIMESTAMP = 20210602144637
    MANUAL_RUN = false

    def change
      ApplicationChoice
      .joins(:application_form, course_option: [:course])
      .where('courses.recruitment_cycle_year != application_forms.recruitment_cycle_year')
      .find_each(batch_size: 100) do |application_choice|
        application_choice.application_form.update!(
          audit_comment: "Application_choice ##{application_choice.id} was deleted due to being associated with a course from another recruitment cycle",
        )
        application_choice.destroy
      end
    end
  end
end
