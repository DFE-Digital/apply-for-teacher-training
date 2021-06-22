require 'rails_helper'

RSpec.describe DataMigrations::RemoveSurplusReferenceSelections do
  it 'removes surplus reference selections so that applications have a maximum of 2 selected references' do
    application_form1 = create(:completed_application_form, application_choices: [build(:submitted_application_choice)], references_count: 4, references_state: :feedback_provided)
    application_form2 = create(:completed_application_form, application_choices: [build(:submitted_application_choice)], references_count: 2, references_state: :feedback_provided)
    application_form3 = create(:completed_application_form, application_choices: [build(:submitted_application_choice)], references_count: 1, references_state: :feedback_provided)
    [application_form1, application_form2, application_form3].each do |app|
      app.application_references.update_all(selected: true)
    end

    described_class.new.change

    expect(application_form1.application_references.selected.size).to eq 2
    expect(application_form2.application_references.selected.size).to eq 2
    expect(application_form3.application_references.selected.size).to eq 1
  end

  it 'removes all selections from unsubmitted apps' do
    submitted_app = create(:completed_application_form, references_count: 4, references_state: :feedback_provided, application_choices: [build(:submitted_application_choice)])
    unsubmitted_app = create(:completed_application_form, references_count: 4, references_state: :feedback_provided)
    [submitted_app, unsubmitted_app].each do |app|
      app.application_references.update_all(selected: true)
    end

    described_class.new.change

    expect(submitted_app.application_references.selected.size).to eq 2
    expect(unsubmitted_app.application_references.selected.size).to eq 0
  end
end
