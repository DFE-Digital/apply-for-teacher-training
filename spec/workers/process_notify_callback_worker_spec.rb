require 'rails_helper'

RSpec.describe ProcessNotifyCallbackWorker do
  describe '#perform' do
    it 'calls the process_notify_callback service' do
      instantiated_service = instance_double(ProcessNotifyCallback)
      allow(ProcessNotifyCallback).to receive(:new).and_return instantiated_service
      allow(instantiated_service).to receive(:call)

      described_class.new.perform({ 'reference' => 'foo', 'status' => 'bar' })

      expect(ProcessNotifyCallback).to have_received(:new).with({ notify_reference: 'foo', status: 'bar' })
      expect(instantiated_service).to have_received(:call)
    end
  end
end
