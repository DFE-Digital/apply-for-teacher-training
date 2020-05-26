class PopulateCompletedSectionBooleans < ActiveRecord::Migration[6.0]
  def up
    submitted_applications = ApplicationForm.where.not(submitted_at: nil)

    submitted_applications.includes(application_choices: %i[course_option course]).each do |application_form|
      fields_to_update = {
        personal_details_completed: true,
        contact_details_completed: true,
        english_gcse_completed: true,
        maths_gcse_completed: true,
        training_with_a_disability_completed: true,
        safeguarding_issues_completed: true,
        becoming_a_teacher_completed: true,
        subject_knowledge_completed: true,
        interview_preferences_completed: true,
        references_completed: true,
      }

      if application_form.science_gcse_needed?
        fields_to_update.merge!({
          science_gcse_completed: true,
        })
      end

      application_form.update!(fields_to_update)
    end

    in_progress_application_forms = ApplicationChoice.includes(:application_form).unsubmitted.map(&:application_form).uniq
    started_application_forms = in_progress_application_forms.reject(&:blank_application?)

    started_application_forms.each do |application_form|
      presenter = CandidateInterface::ApplicationFormPresenter.new(application_form)
      application_form.update!(personal_details_completed: presenter.personal_details_completed?,
                               contact_details_completed: presenter.contact_details_completed?,
                               english_gcse_completed: presenter.english_gcse_completed?,
                               maths_gcse_completed: presenter.maths_gcse_completed?,
                               science_gcse_completed: presenter.science_gcse_completed?,
                               training_with_a_disability_completed: presenter.training_with_a_disability_completed?,
                               safeguarding_issues_completed: presenter.safeguarding_completed?,
                               becoming_a_teacher_completed: presenter.becoming_a_teacher_completed?,
                               subject_knowledge_completed: presenter.subject_knowledge_completed?,
                               interview_preferences_completed: presenter.interview_preferences_completed?,
                               references_completed: presenter.all_referees_provided_by_candidate?)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
