module DataMigrations
  class FixMistakenlyCompletePreviousTeacherTrainingSections
    TIMESTAMP = 20260916105849
    MANUAL_RUN = true

    def change
      forms.update_all(
        previous_teacher_training_completed: false,
        previous_teacher_training_completed_at: nil,
      )
    end

    def forms
      ApplicationForm
        .where(
          recruitment_cycle_year: 2027,
          previous_teacher_training_completed: true,
        )
        .where.not(
          id: PreviousTeacherTraining
                .where(status: 'published')
                .select(:application_form_id),
        )
    end
  end
end
