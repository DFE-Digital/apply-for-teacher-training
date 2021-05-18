require 'rails_helper'

RSpec.describe DataMigrations::BackfillReferencesCompletedBoolean do
  it 'sets the references completed boolean to true if two references have been provided' do
    application_form_with_1_feedback_provided_reference = create(:application_form)
    create(:reference, :feedback_provided, application_form: application_form_with_1_feedback_provided_reference)
    create(:reference, :feedback_requested, application_form: application_form_with_1_feedback_provided_reference)

    application_form_with_2_feedback_provided_references = create(:application_form)
    create(:reference, :feedback_provided, application_form: application_form_with_2_feedback_provided_references)
    create(:reference, :feedback_provided, application_form: application_form_with_2_feedback_provided_references)

    described_class.new.change

    expect(application_form_with_1_feedback_provided_reference.reload.references_completed).to eq nil
    expect(application_form_with_2_feedback_provided_references.reload.references_completed).to eq true
  end
end
