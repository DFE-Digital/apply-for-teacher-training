require 'rails_helper'

RSpec.describe CandidateInterface::PreferencesForm, type: :model do
  subject(:form) do
    described_class.new(preference:, params:)
  end

  let(:preference) do
    create(:candidate_preference, dynamic_location_preferences: false)
  end
  let(:params) { { dynamic_location_preferences: true } }

  describe 'validations' do
    context 'when there are no location preferences' do
      it 'adds location preferences blank error' do
        expect(form.valid?).to be_falsey
        expect(form.errors[:base]).to eq(['Add location preferences'])
      end
    end
  end

  describe '.build_from_preferences' do
    it 'builds the form from a preference' do
      form_object = described_class.build_from_preference(
        preference:,
      )

      expect(form_object).to have_attributes(
        preference:,
        dynamic_location_preferences: false,
      )
    end
  end

  describe '#save' do
    it 'updates a preference to add dynamic_location_preferences' do
      create(:candidate_location_preference, candidate_preference: preference)
      expect { form.save }.to change(preference, :dynamic_location_preferences).from(false).to(true)
    end
  end
end
