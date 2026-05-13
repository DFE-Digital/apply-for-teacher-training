require 'rails_helper'

RSpec.describe EndOfCycle::CancelReferenceRequestsSecondaryWorker do
  describe '#perform' do
    it 'calls cancel referee service on the given references' do
      references = create_list(:reference, 2, :feedback_requested)
      cancel_referee = instance_double(CancelReferee, call: nil)
      allow(CancelReferee).to receive(:new).and_return(cancel_referee)

      described_class.new.perform(references.pluck(:id))
      expect(CancelReferee).to have_received(:new).twice
      expect(cancel_referee).to have_received(:call).with(reference: kind_of(ApplicationReference)).twice
    end
  end
end
