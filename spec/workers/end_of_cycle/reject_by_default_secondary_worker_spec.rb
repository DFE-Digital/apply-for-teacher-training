require 'rails_helper'

RSpec.describe EndOfCycle::RejectByDefaultSecondaryWorker do
  describe '#perform' do
    it 'calls the reject by default service for each application' do
      application_forms = create_list(:application_form, 2)
      rejection_service = spy
      allow(EndOfCycle::RejectByDefaultService)
        .to receive(:new).with(kind_of(ApplicationForm)).and_return(rejection_service).twice

      described_class.new.perform(application_forms.pluck(:id))
      expect(rejection_service).to have_received(:call).twice
    end
  end
end
