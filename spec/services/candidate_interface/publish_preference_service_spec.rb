require 'rails_helper'

RSpec.describe CandidateInterface::PublishPreferenceService do
  let(:application_form) { create(:application_form, :submitted) }
  let(:preference) { create(:candidate_preference, application_form:, status: :draft) } # opted-in by default
  let(:service) { described_class.new(preference:, application_form:) }

  before do
    allow(CandidateInterface::PreferencesEmail).to receive(:call)
  end

  describe '#call' do
    context 'when training_locations is set to anywhere' do
      before do
        preference.training_locations = 'anywhere'
        create(:candidate_location_preference, candidate_preference: preference)
      end

      it 'clears location preferences and dynamic location data' do
        service.call

        expect(preference.reload.location_preferences).to be_empty
        expect(preference.dynamic_location_preferences).to be_nil
      end

      it 'publishes the preference' do
        service.call
        expect(preference.reload).to be_published
      end

      it 'archives other published preferences' do
        other_published = create(:candidate_preference, application_form:, status: :published)
        service.call
        expect(other_published.reload.status).to eq('archived')
      end

      it 'destroys duplicated preferences' do
        duplicate = create(:candidate_preference, application_form:, status: :duplicated)
        service.call
        expect { duplicate.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'sends a preferences email if published' do
        service.call
        expect(CandidateInterface::PreferencesEmail).to have_received(:call).with(preference:)
      end
    end
  end
end
