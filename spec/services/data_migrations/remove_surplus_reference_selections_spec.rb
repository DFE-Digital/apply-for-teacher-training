require 'rails_helper'

RSpec.describe DataMigrations::RemoveSurplusReferenceSelections do
  it 'removes surplus references selections so that applications have a maximum of 2 selected references' do
    application_form1 = create(:completed_application_form, references_count: 4, references_state: :feedback_provided)
    application_form2 = create(:completed_application_form, references_count: 2, references_state: :feedback_provided)
    application_form3 = create(:completed_application_form, references_count: 1, references_state: :feedback_provided)

    described_class.new.change

    expect(application_form1.application_references.selected.size).to eq 2
    expect(application_form2.application_references.selected.size).to eq 2
    expect(application_form3.application_references.selected.size).to eq 1
  end
end
