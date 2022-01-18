require 'rails_helper'

RSpec.describe UpdateFraudMatchesWorker do
  describe '#perform' do
    let(:worker) { described_class.new }

    before do
      @duplicate_service = instance_double(UpdateDuplicateMatches, save!: nil)
      allow(UpdateDuplicateMatches).to receive(:new).and_return(@duplicate_service)
    end

    it 'calls UpdateDuplicateMatches' do
      worker.perform
      expect(@duplicate_service).to have_received(:save!)
    end
  end
end
