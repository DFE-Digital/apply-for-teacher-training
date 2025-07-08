require 'rails_helper'

RSpec.describe CandidateInterface::LocationPreferencesRequiredForm, type: :model do
  include Rails.application.routes.url_helpers

  subject(:form) do
    described_class.new({ preference: })
  end

  let(:preference) do
    create(:candidate_preference, funding_type:, training_locations:)
  end
  let(:funding_type) { 'fee' }
  let(:training_locations) { 'anywhere' }

  describe '#valid?' do
    it 'returns error if there are no location preferences' do
      expect(form.valid?).to be false
      expect(form.errors[:base].first).to eq 'Add an area you can train in'
    end
  end

  describe '#back_path' do
    context 'when funding_type is present' do
      it 'sets the back path to funding type' do
        expect(form.back_path).to eq(
          new_candidate_interface_draft_preference_funding_type_preference_path(preference),
        )
      end
    end

    context 'when training_locations is anywhere' do
      let(:funding_type) { nil }

      it 'sets the back path to training_locations' do
        expect(form.back_path).to eq(
          new_candidate_interface_draft_preference_training_location_path(preference),
        )
      end
    end

    context 'when training_locations is specific' do
      let(:funding_type) { nil }
      let(:training_locations) { 'specific' }

      it 'sets the back path to dynamic locations' do
        expect(form.back_path).to eq(
          new_candidate_interface_draft_preference_dynamic_location_preference_path(preference),
        )
      end
    end
  end
end
