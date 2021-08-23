module DataMigrations
  class PopulateApplicationChoiceCurrentRecruitmentCycleYear
    TIMESTAMP = 20210823135628
    MANUAL_RUN = true

    def change
      ApplicationChoice.find_each(batch_size: 100) do |application_choice|
        year = application_choice.current_course.recruitment_cycle_year

        application_choice.update_columns(current_recruitment_cycle_year: year) or
          raise "Unable to update ApplicationChoice ##{application_choice.id}"
      end
    end
  end
end
