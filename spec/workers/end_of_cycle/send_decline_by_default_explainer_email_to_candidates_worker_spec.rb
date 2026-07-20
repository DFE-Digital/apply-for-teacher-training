require 'rails_helper'

RSpec.describe EndOfCycle::SendDeclineByDefaultExplainerEmailToCandidatesWorker do
  describe '#perform' do
    context 'before the date for sending the explainer email', time: decline_by_default_explainer_date - 1.day do
      it 'does not enqueue the batch worker' do
        create(:application_choice, :declined_by_default)
        expect { described_class.new.perform }.not_to enqueue_job(EndOfCycle::SendDeclineByDefaultExplainerEmailToCandidatesBatchWorker)
      end
    end

    context 'after the date for sending the explainer email', time: decline_by_default_explainer_date + 1.day do
      it 'does not enqueue the batch worker' do
        create(:application_choice, :declined_by_default)
        expect { described_class.new.perform }.not_to enqueue_job(EndOfCycle::SendDeclineByDefaultExplainerEmailToCandidatesBatchWorker)
      end
    end

    context 'the date for sending the explainer email', time: decline_by_default_explainer_date do
      it 'enqueues batch worker' do
        rejected_with_offer = create(:application_form)
        create(:application_choice, :declined_by_default, application_form: rejected_with_offer)
        create(:application_choice, :offered, application_form: rejected_with_offer)

        rejected_without_offer = create(:application_choice, :declined_by_default).application_form

        # These applications should not be included
        create(:application_choice, :inactive)
        create(:application_choice, :interviewing)
        create(:application_choice, :awaiting_provider_decision)

        expect { described_class.new.perform }.to enqueue_job(EndOfCycle::SendDeclineByDefaultExplainerEmailToCandidatesBatchWorker).with(contain_exactly(rejected_with_offer.id, rejected_without_offer.id))
      end
    end
  end
end
