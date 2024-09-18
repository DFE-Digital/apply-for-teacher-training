require 'rails_helper'

RSpec.describe EndOfCycle::CancelUnsubmittedApplicationsSecondaryWorker do
  describe '#perform' do
    it 'cancels unsubmitted applications' do
      cancellable = create(:application_choice, :unsubmitted)
      described_class.new.perform([cancellable.application_form.id])

      expect(cancellable.reload.status).to eq 'application_not_sent'
    end

    it 'does not cancel if not unsubmitted' do
      uncancellable = create(:application_choice, :rejected)
      described_class.new.perform([uncancellable.application_form.id])

      expect(uncancellable.reload.status).to eq 'rejected'
    end
  end
end
