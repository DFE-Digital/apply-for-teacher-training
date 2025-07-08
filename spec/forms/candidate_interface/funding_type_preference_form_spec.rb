require 'rails_helper'

module CandidateInterface
  RSpec.describe CandidateInterface::FundingTypePreferenceForm, type: :model do
    include Rails.application.routes.url_helpers

    subject(:form) do
      described_class.new(preference:, funding_type:)
    end

    let(:preference) do
      create(
        :candidate_preference,
        funding_type: nil,
        training_locations:,
      )
    end
    let(:funding_type) { 'fee' }
    let(:training_locations) { 'anywhere' }

    describe 'validations' do
      it { is_expected.to validate_inclusion_of(:funding_type).in_array(%w[fee salary]) }
    end

    describe '#save!' do
      it 'updates a preference with funding_type' do
        expect { form.save! }.to change(preference, :funding_type).from(nil).to('fee')
      end
    end

    describe '#back_path' do
      context 'with return_to review' do
        it 'sets the back link to review path' do
          expect(form.back_path(return_to: 'review')).to eq(
            candidate_interface_draft_preference_path(preference),
          )
        end
      end

      context 'when training location is anywhere' do
        it 'sets the back link training_locations' do
          expect(form.back_path).to eq(
            new_candidate_interface_draft_preference_training_location_path(preference),
          )
        end
      end

      context 'when training location is specific' do
        let(:training_locations) { 'specific' }

        it 'sets the back link to dynamic locations' do
          expect(form.back_path).to eq(
            new_candidate_interface_draft_preference_dynamic_location_preference_path(preference),
          )
        end
      end
    end
  end
end
