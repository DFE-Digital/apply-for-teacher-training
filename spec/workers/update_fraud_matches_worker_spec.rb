require 'rails_helper'

RSpec.describe UpdateFraudMatchesWorker do
  describe '#perform' do
    let(:worker) { described_class.new }

    before do
      @fraud_service = instance_double(UpdateFraudMatches, save!: nil)
      allow(UpdateFraudMatches).to receive(:new).and_return(@fraud_service)

      @duplicate_service = instance_double(UpdateDuplicateMatches, save!: nil)
      allow(UpdateDuplicateMatches).to receive(:new).and_return(@duplicate_service)
    end

    context 'when the `duplicate_matching` feature flag is inactive' do
      it 'calls UpdateFraudMatches' do
        FeatureFlag.deactivate(:duplicate_matching)
        worker.perform
        expect(@duplicate_service).not_to have_received(:save!)
        expect(@fraud_service).to have_received(:save!)
      end
    end

    context 'when the `duplicate_matching` feature flag is active' do
      it 'calls UpdateDuplicateMatches' do
        FeatureFlag.activate(:duplicate_matching)
        worker.perform
        expect(@fraud_service).not_to have_received(:save!)
        expect(@duplicate_service).to have_received(:save!)
      end
    end
  end
end
