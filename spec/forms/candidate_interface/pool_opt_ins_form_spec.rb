require 'rails_helper'

module CandidateInterface
  RSpec.describe CandidateInterface::PoolOptInsForm, type: :model do
    subject(:form) do
      described_class.new(current_candidate:, preference:, params:)
    end

    let(:current_candidate) { create(:candidate) }
    let(:preference) { nil }
    let(:params) { { pool_status: 'opt_in' } }
    let(:application_form) do
      create(:application_form, :completed, candidate: current_candidate)
    end
    let!(:application_choice) do
      create(:application_choice, :awaiting_provider_decision, application_form:)
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:pool_status) }
    end

    describe '.build_from_preferences' do
      let(:preference) { create(:candidate_preference) }

      it 'builds the form from a preference' do
        form_object = described_class.build_from_preference(
          current_candidate:,
          preference:,
        )

        expect(form_object).to have_attributes(
          current_candidate:,
          preference:,
          pool_status: 'opt_in',
        )
      end

      it 'builds the form with opt out reason if it exists' do
        preference.update(pool_status: 'opt_out', opt_out_reason: 'Here is a reason')

        form_object = described_class.build_from_preference(
          current_candidate:,
          preference:,
        )

        expect(form_object).to have_attributes(
          current_candidate:,
          preference:,
          pool_status: 'opt_out',
          opt_out_reason: 'Here is a reason',
        )
      end
    end

    describe '#save' do
      context 'when creating a preference' do
        it 'creates a preference' do
          allow(LocationPreferences).to receive(:add_default_location_preferences)
            .and_return(nil)

          expect { form.save }.to change(CandidatePreference, :count).by(1)

          preference_record = CandidatePreference.last
          expect(preference_record.pool_status).to eq('opt_in')
          expect(LocationPreferences).to have_received(:add_default_location_preferences)
        end
      end

      context 'when creating a preference to opt out without a reason' do
        let(:params) { { pool_status: 'opt_out' } }

        it 'creates a preference and removes any existing published preferences' do
          existing_published_preference = create(
            :candidate_preference,
            candidate: current_candidate,
            status: 'published',
          )

          form.save

          preference_record = CandidatePreference.last
          expect(preference_record.pool_status).to eq('opt_out')
          expect { existing_published_preference.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when creating a preference to opt out with a reason' do
        let(:params) { { pool_status: 'opt_out', opt_out_reason: 'I do not want to share my details with other providers' } }

        it 'creates a preference and removes any existing published preferences' do
          existing_published_preference = create(
            :candidate_preference,
            candidate: current_candidate,
            status: 'published',
          )

          form.save

          preference_record = CandidatePreference.last
          expect(preference_record.pool_status).to eq('opt_out')
          expect(preference_record.opt_out_reason).to eq('I do not want to share my details with other providers')
          expect { existing_published_preference.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when updating a preference to opt out' do
        let(:preference) { create(:candidate_preference, status: 'draft') }
        let(:params) { { pool_status: 'opt_out' } }

        it 'updates a preference to opt out and publishes the preference and removes existing published ones' do
          existing_published_preference = create(
            :candidate_preference,
            candidate: current_candidate,
            status: 'published',
          )

          expect { form.save }.to change(preference, :pool_status).from('opt_in').to('opt_out')
            .and change(preference, :status).from('draft').to('published')

          expect { existing_published_preference.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
