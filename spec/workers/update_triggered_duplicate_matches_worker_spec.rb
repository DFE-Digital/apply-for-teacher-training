require 'rails_helper'

RSpec.describe UpdateTriggeredDuplicateMatchesWorker do
  describe '#perform' do
    let(:application_form) { create(:application_form) }
    let(:service) { instance_double(UpdateTriggeredDuplicateMatches, save!: nil) }

    before do
      allow(UpdateTriggeredDuplicateMatches).to receive(:new).and_return(service)
    end

    it 'calls UpdateTriggeredDuplicateMatches for the application form' do
      described_class.perform_now(application_form.id)

      expect(UpdateTriggeredDuplicateMatches).to have_received(:new).with(application_form)
      expect(service).to have_received(:save!)
    end

    it 'does nothing when the application form no longer exists' do
      described_class.perform_now(0)

      expect(UpdateTriggeredDuplicateMatches).not_to have_received(:new)
    end
  end
end
