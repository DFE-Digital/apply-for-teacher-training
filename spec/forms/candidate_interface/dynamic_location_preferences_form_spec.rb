require 'rails_helper'

module CandidateInterface
  RSpec.describe CandidateInterface::DynamicLocationPreferencesForm, type: :model do
    include Rails.application.routes.url_helpers

    subject(:form) do
      described_class.new(preference:, dynamic_location_preferences:)
    end

    let(:preference) do
      create(
        :candidate_preference,
        dynamic_location_preferences: nil,
      )
    end
    let(:dynamic_location_preferences) { true }

    describe 'validations' do
      it { is_expected.to validate_inclusion_of(:dynamic_location_preferences).in_array([true, false]) }
    end

    describe '#save' do
      it 'updates a preference with dynamic_location_preferences' do
        expect { form.save }.to change(preference, :dynamic_location_preferences).from(nil).to(true)
      end
    end

    describe '#next_path' do
      let(:preference) { create(:candidate_preference) }

      context 'with return_to review' do
        it 'sets the next path to review path' do
          expect(form.next_path(return_to: 'review')).to eq(
            candidate_interface_draft_preference_path(preference),
          )
        end
      end

      context 'when applied only to salaries courses' do
        let(:preference) { create(:candidate_preference) }

        it 'sets the next path to funding_type' do
          allow(preference).to receive(:applied_only_to_salaried_courses?).and_return(true)

          expect(form.next_path).to eq(
            new_candidate_interface_draft_preference_funding_type_preference_path(preference),
          )
        end
      end

      context 'when applied to fee courses' do
        let(:preference) { create(:candidate_preference) }

        it 'sets the next path to review path' do
          allow(preference).to receive(:applied_only_to_salaried_courses?).and_return(false)

          expect(form.next_path).to eq(
            candidate_interface_draft_preference_path(preference),
          )
        end
      end
    end
  end
end
