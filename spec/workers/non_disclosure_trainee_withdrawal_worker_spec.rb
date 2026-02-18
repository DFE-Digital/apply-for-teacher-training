require 'rails_helper'

RSpec.describe NonDisclosureTraineeWithdrawalWorker do
  let(:candidate) { create(:candidate, email_address: 'john_doe@example.com') }

  before do
    @instance = instance_double(GeneratePossiblePreviousTeacherTraining, call: nil)
    allow(GeneratePossiblePreviousTeacherTraining).to receive(:new).and_return(@instance)
  end

  describe '.perform' do
    it 'calls the Generator Possible Previous Teacher Training service' do
      described_class.new.perform(candidate.id)

      expect(@instance).to have_received(:call)
      expect(GeneratePossiblePreviousTeacherTraining).to have_received(:new).with(candidate)
    end
  end
end
