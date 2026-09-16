require 'rails_helper'

RSpec.describe DataMigrations::FixMistakenlyCompletePreviousTeacherTrainingSections do
  it 'only updates relevant 2027 application forms' do
    form_from_2026 = create(
      :application_form,
      recruitment_cycle_year: 2026,
      previous_teacher_training_completed: true,
    )

    form_with_published_trainings = create(
      :application_form,
      recruitment_cycle_year: 2027,
      previous_teacher_training_completed: true,
    )

    create_list(
      :previous_teacher_training,
      2,
      status: 'published',
      application_form: form_with_published_trainings,
    )

    form_without_published_trainings = create(
      :application_form,
      recruitment_cycle_year: 2027,
      previous_teacher_training_completed: true,
    )

    described_class.new.change

    expect(form_without_published_trainings.reload.previous_teacher_training_completed).to be false
    expect(form_with_published_trainings.reload.previous_teacher_training_completed).to be true
    expect(form_from_2026.reload.previous_teacher_training_completed).to be true
  end
end
