require 'rails_helper'

RSpec.describe EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker do
  describe '#perform' do
    it 'calls service with provider ids' do
      provider = create(:provider_permissions).provider
      send_reminder_service = instance_double(EndOfCycle::SendRejectByDefaultReminderToProvidersService, call: nil)
      allow(EndOfCycle::SendRejectByDefaultReminderToProvidersService).to receive(:new).with(provider).and_return(send_reminder_service)

      described_class.new.perform([provider.id])
      expect(EndOfCycle::SendRejectByDefaultReminderToProvidersService).to have_received(:new).with(provider)
      expect(send_reminder_service).to have_received(:call)
    end
  end
end
