require 'rails_helper'

RSpec.describe EndOfCycle::DeclineByDefaultSecondaryWorker do
  describe '#perform' do
    it 'calls decline by default service with application forms' do
      application_forms = create_list(:application_form, 2)
      decline_by_default_service = spy
      allow(EndOfCycle::DeclineByDefaultService)
        .to receive(:new).with(kind_of(ApplicationForm)).and_return(decline_by_default_service).twice

      described_class.new.perform(application_forms.pluck(:id))
      expect(decline_by_default_service).to have_received(:call).twice
    end
  end
end
