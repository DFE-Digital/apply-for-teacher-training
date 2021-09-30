require 'rails_helper'

RSpec.describe DataMigrations::BackfillWorkHistoryStatus do
  it 'updates `work_history_status` from `nil` to `can_complete` for application forms in the 2022 cycle with work experiences' do
    application_form_with_experiences = create(:application_form, work_history_status: nil, recruitment_cycle_year: 2022)
    create(:application_work_experience, application_form: application_form_with_experiences)

    application_form_with_experiences_from_previous_cycle = create(:application_form, work_history_status: nil, recruitment_cycle_year: 2021)
    create(:application_work_experience, application_form: application_form_with_experiences_from_previous_cycle)

    application_form_without_experiences = create(:application_form, work_history_status: nil, recruitment_cycle_year: 2022)

    described_class.new.change

    expect(application_form_with_experiences.reload.work_history_status).to eq 'can_complete'
    expect(application_form_with_experiences_from_previous_cycle.reload.work_history_status).to eq nil
    expect(application_form_without_experiences.reload.work_history_status).to eq nil
  end
end
