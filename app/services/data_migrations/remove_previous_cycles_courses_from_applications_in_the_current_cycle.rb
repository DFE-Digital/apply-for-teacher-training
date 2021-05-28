module DataMigrations
  class RemovePreviousCyclesCoursesFromApplicationsInTheCurrentCycle
    TIMESTAMP = 20210528131818
    MANUAL_RUN = false

    def change
      ApplicationChoice
      .joins(:application_form, course_option: [:course])
      .where(course: { recruitment_cycle_year: RecruitmentCycle.previous_year })
      .where(application_form: { recruitment_cycle_year: RecruitmentCycle.current_year })
      .find_each(batch_size: 100) do |application_choice|
        application_choice.application_form.update!(
          audit_comment: "Application_choice ##{application_choice.id} was deleted due to being associated with a course from last years recruitment cycle",
        )
        application_choice.destroy
      end
    end
  end
end
