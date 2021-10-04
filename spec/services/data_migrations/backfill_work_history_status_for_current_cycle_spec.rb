require 'rails_helper'

RSpec.describe DataMigrations::BackfillWorkHistoryStatusForCurrentCycle do
  it 'updates `work_history_status` from `nil` to `can_complete` for application forms in the 2021 cycle with work experiences when the flag is active' do
    application_form_with_experiences = create(
      :application_form,
      feature_restructured_work_history: true,
      work_history_status: nil,
      recruitment_cycle_year: 2021,
    )
    create(:application_work_experience, application_form: application_form_with_experiences)

    application_form_without_flag_with_experiences = create(
      :application_form,
      feature_restructured_work_history: false,
      work_history_status: nil,
      recruitment_cycle_year: 2021,
    )
    create(:application_work_experience, application_form: application_form_without_flag_with_experiences)

    application_form_with_experiences_from_next_cycle = create(
      :application_form,
      feature_restructured_work_history: true,
      work_history_status: nil,
      recruitment_cycle_year: 2022,
    )
    create(:application_work_experience, application_form: application_form_with_experiences_from_next_cycle)

    application_form_without_experiences = create(
      :application_form,
      feature_restructured_work_history: true,
      work_history_status: nil,
      recruitment_cycle_year: 2021,
    )

    described_class.new.change

    expect(application_form_with_experiences.reload.work_history_status).to eq 'can_complete'
    expect(application_form_without_flag_with_experiences.reload.work_history_status).to eq nil
    expect(application_form_with_experiences_from_next_cycle.reload.work_history_status).to eq nil
    expect(application_form_without_experiences.reload.work_history_status).to eq nil
  end

  it 'updates `work_history_status` from `nil` to `can_not_complete` for application forms in the 2021 cycle with no work experiences and an explanation when the flag is active' do
    application_form_with_an_explanation_and_flag_active = create(
      :application_form,
      feature_restructured_work_history: true,
      work_history_status: nil,
      recruitment_cycle_year: 2021,
      work_history_explanation: 'I hate work',
    )
    application_form_with_an_explanation_and_flag_inactive = create(
      :application_form,
      feature_restructured_work_history: false,
      work_history_status: nil,
      recruitment_cycle_year: 2021,
      work_history_explanation: 'I hate work',
    )
    application_form_with_an_explanation_from_next_cycle_and_flag_active = create(
      :application_form,
      feature_restructured_work_history: true,
      work_history_status: nil,
      recruitment_cycle_year: 2022,
      work_history_explanation: 'I hate work',
    )

    described_class.new.change

    expect(application_form_with_an_explanation_and_flag_active.reload.work_history_status).to eq 'can_not_complete'
    expect(application_form_with_an_explanation_and_flag_inactive.reload.work_history_status).to eq nil
    expect(application_form_with_an_explanation_from_next_cycle_and_flag_active.reload.work_history_status).to eq nil
  end
end
