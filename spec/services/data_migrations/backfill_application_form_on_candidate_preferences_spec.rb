require 'rails_helper'

RSpec.describe DataMigrations::BackfillApplicationFormOnCandidatePreferences do
  it 'adds an application form to the candidate preference where it is missing' do
    application_form = create(:application_form)
    without_application_form = create(:candidate_preference, application_form: nil, candidate: application_form.candidate)
    described_class.new.change

    expect(without_application_form.reload.application_form_id).to eq application_form.id
  end
end
