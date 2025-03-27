require 'rails_helper'

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
  end

  describe '#save' do
    context 'when creating a preference' do
      it 'creates a preference and adds location preferences' do
        expect { form.save }.to change(CandidatePreference, :count).by(1)
          .and change { CandidateLocationPreference.count }.by(2)

        preference_record = CandidatePreference.last
        expect(preference_record.pool_status).to eq('opt_in')
        expect(preference_record.location_preferences.count).to eq(2)
      end
    end

    context 'when updating a preference to opt out' do
      let(:preference) { create(:candidate_preference) }
      let(:params) { { pool_status: 'opt_out' } }

      it 'updates a preference to opt out and publishes the preference' do
        expect { form.save }.to change(preference, :pool_status).from('opt_in').to('opt_out')
          .and change(preference, :status).from('draft').to('published')
      end
    end
  end
end
