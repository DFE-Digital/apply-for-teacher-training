require 'rails_helper'

RSpec.describe DataMigrations::BackfillReferencesCompleted do
  it 'sets references_completed to true for all submitted applications where it is nil' do
    submitted_with_nil_field = create(:application_form, submitted_at: Time.zone.now, references_completed: nil)
    submitted_with_field_marked = create(:application_form, submitted_at: Time.zone.now, references_completed: true)
    not_submitted = create(:application_form, submitted_at: nil, references_completed: nil)

    described_class.new.change

    expect(submitted_with_nil_field.reload.references_completed).to eq true
    expect(submitted_with_field_marked.reload.references_completed).to eq true
    expect(not_submitted.reload.references_completed).to eq nil
  end
end
