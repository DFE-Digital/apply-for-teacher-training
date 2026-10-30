require 'rails_helper'

RSpec.describe DataMigrations::IncompleteEflSectionForContradictoryEflData do
  describe '#change' do
    it 'updates efl_completed to false for contradictory english proficiencies' do
      # Setup test data
      application_form = create(:application_form, recruitment_cycle_year: 2027)
      create(:english_proficiency, application_form: application_form, draft: false, has_qualification: true, efl_qualification_id: nil)

      # Run the data migration
      described_class.new.change

      # Reload the application form and check the efl_completed attribute
      expect(application_form.reload.efl_completed).to be_falsey
    end
  end
end
