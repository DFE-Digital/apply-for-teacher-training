require 'rails_helper'

module CandidateInterface
  RSpec.describe TrainingLocationsForm, type: :model do
    include Rails.application.routes.url_helpers

    subject(:form) do
      described_class.new(preference:, training_locations:)
    end

    let(:preference) do
      create(
        :candidate_preference,
        training_locations: existing_training_locations,
      )
    end
    let(:existing_training_locations) { nil }
    let(:training_locations) { 'anywhere' }

    describe 'validations' do
      it { is_expected.to validate_inclusion_of(:training_locations).in_array(%w[anywhere specific]) }
    end

    describe '#save!' do
      context 'when training_locations is anywhere' do
        it 'updates a preference with training_locations' do
          expect { form.save! }.to change(preference, :training_locations).from(nil).to('anywhere')
        end
      end

      context 'when training_locations is specific' do
        let(:training_locations) { 'specific' }
        let(:preference) do
          create(
            :candidate_preference,
            application_form: create(
              :application_form,
              :completed,
              submitted_application_choices_count: 1,
            ),
            training_locations: nil,
          )
        end

        it 'updates a preference with training_locations' do
          expect { form.save! }.to change(preference, :training_locations).from(nil).to('specific')
            .and change(preference.location_preferences, :count).from(0).to(1)
        end
      end
    end

    describe '#next_step_path' do
      context 'with return_to review and training_locations anywhere' do
        let(:existing_training_locations) { 'anywhere' }

        it 'sets the next path to funding_type' do
          allow(preference).to receive(:applied_only_to_salaried_courses?).and_return(true)

          expect(form.next_step_path(return_to: 'review')).to eq(
            candidate_interface_draft_preference_path(preference),
          )
        end
      end

      context 'with applied_only to salaried and training_locations anywhere' do
        let(:existing_training_locations) { 'anywhere' }

        it 'sets the next path to funding_type' do
          allow(preference).to receive(:applied_only_to_salaried_courses?).and_return(true)

          expect(form.next_step_path).to eq(
            new_candidate_interface_draft_preference_funding_type_preference_path(preference),
          )
        end
      end

      context 'when training_locations anywhere' do
        let(:existing_training_locations) { 'anywhere' }

        it 'sets the next path to review' do
          allow(preference).to receive(:applied_only_to_salaried_courses?).and_return(false)

          expect(form.next_step_path).to eq(
            candidate_interface_draft_preference_path(preference),
          )
        end
      end

      context 'when training_locations is specific' do
        let(:existing_training_locations) { 'specific' }

        it 'sets the next path to location_preferences' do
          allow(preference).to receive(:applied_only_to_salaried_courses?).and_return(false)

          expect(form.next_step_path).to eq(
            candidate_interface_draft_preference_location_preferences_path(preference),
          )
        end
      end
    end
  end
end
