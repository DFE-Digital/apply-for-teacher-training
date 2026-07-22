require 'rails_helper'

RSpec.describe EndOfCycle::SendRejectByDefaultExplainerEmailToCandidatesWorker do
  describe '#perform' do
    context 'before the date for sending the explainer email', time: reject_by_default_explainer_date - 1.day do
      it 'does not enqueue the batch worker' do
        create(:application_choice, :rejected_by_default)
        allow(EndOfCycle::SendRejectByDefaultExplainerEmailToCandidatesBatchWorker).to receive(:perform_at)
        described_class.new.perform
        expect(EndOfCycle::SendRejectByDefaultExplainerEmailToCandidatesBatchWorker).not_to have_received(:perform_at)
      end
    end

    context 'after the date for sending the explainer email', time: reject_by_default_explainer_date + 1.day do
      it 'does not enqueue the batch worker' do
        create(:application_choice, :rejected_by_default)
        allow(EndOfCycle::SendRejectByDefaultExplainerEmailToCandidatesBatchWorker).to receive(:perform_at)
        described_class.new.perform
        expect(EndOfCycle::SendRejectByDefaultExplainerEmailToCandidatesBatchWorker).not_to have_received(:perform_at)
      end
    end

    context 'the date for sending the explainer email', time: reject_by_default_explainer_date do
      it 'enqueues batch worker' do
        rejected_with_offer = create(:application_form)
        create(:application_choice, :rejected_by_default, application_form: rejected_with_offer)
        create(:application_choice, :offered, application_form: rejected_with_offer)

        rejected_without_offer = create(:application_choice, :rejected_by_default).application_form

        # These applications should not be included
        create(:application_choice, :inactive)
        create(:application_choice, :interviewing)
        create(:application_choice, :awaiting_provider_decision)

        allow(EndOfCycle::SendRejectByDefaultExplainerEmailToCandidatesBatchWorker).to receive(:perform_at)
        described_class.new.perform

        expect(EndOfCycle::SendRejectByDefaultExplainerEmailToCandidatesBatchWorker)
          .to have_received(:perform_at).with(kind_of(Time), [rejected_with_offer.id, rejected_without_offer.id])
      end
    end
  end
end
