require 'rails_helper'

RSpec.describe BackfillApplicationFormHesaSexAndEthnicityCode do
  describe '#change' do
    it 'converts integer hesa codes into strings' do
      application_form = create(:application_form,
                                equality_and_diversity: {
                                  hesa_sex: 1,
                                  hesa_ethnicity: 50,
                                })
      described_class.call(application_form)
      expect(application_form.equality_and_diversity['hesa_sex']).to eq('1')
      expect(application_form.equality_and_diversity['hesa_ethnicity']).to eq('50')
    end

    it 'doesnt replace with empty string when codes are nil' do
      application_form = create(:application_form,
                                equality_and_diversity: {
                                  hesa_sex: nil,
                                  hesa_ethnicity: nil,
                                })
      described_class.call(application_form)
      expect(application_form.equality_and_diversity['hesa_sex']).to be_nil
      expect(application_form.equality_and_diversity['hesa_ethnicity']).to be_nil
    end

    it 'doesnt alter the application forms updated at time' do
      application_form = create(:application_form,
                                equality_and_diversity: {
                                  hesa_sex: 1,
                                  hesa_ethnicity: 50,
                                })
      application_choice = create(:application_choice, updated_at: 1.day.ago, application_form: application_form)
      expect { described_class.call(application_form) }.not_to change(application_choice, :updated_at)
    end
  end
end
