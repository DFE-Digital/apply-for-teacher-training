module DataMigrations
  class BackfillExperiencesOnApplicationChoices
    TIMESTAMP = 20240725162306
    MANUAL_RUN = false

    def change
      ApplicationChoice
        .not_unsubmitted
        .where.missing(:work_experiences)
        .group_by(&:application_form_id).each do |application_form_id, application_choices|
        application_form = ApplicationForm.find(application_form_id)

        duped_work_experiences = application_form.application_work_experiences.map(&:dup)
        duped_volunteering_experiences = application_form.application_volunteering_experiences.map(&:dup)

        application_choices.each do |application_choice|
          application_choice.work_experiences = duped_work_experiences
          application_choice.volunteer_experiences = duped_volunteering_experiences
          application_choice.save!
        end
      end
    end
  end
end
