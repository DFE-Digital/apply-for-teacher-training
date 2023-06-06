require 'rails_helper'

RSpec.describe DataMigrations::BackfillEqualityAndDiversityCompletedAttributes do
  context 'when the application has been submitted' do
    it 'backfills the completed attributes' do
      application_form = create(:application_form, :submitted, :with_equality_and_diversity_data)
      described_class.new.change
      expect(application_form.reload.equality_and_diversity_completed).to be true
      expect(application_form.reload.equality_and_diversity_completed_at).to eq application_form.submitted_at
    end
  end

  context 'when the application has not been submitted' do
    it 'does not backfill the completed attributes' do
      application_form = create(:application_form)
      described_class.new.change
      expect(application_form.reload.equality_and_diversity_completed).to be_nil
      expect(application_form.reload.equality_and_diversity_completed_at).to be_nil
    end
  end
end
