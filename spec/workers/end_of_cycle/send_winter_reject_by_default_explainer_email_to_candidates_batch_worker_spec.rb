require 'rails_helper'

RSpec.describe EndOfCycle::SendWinterRejectByDefaultExplainerEmailToCandidatesBatchWorker do
  describe '#perform' do
    context 'candidate has offers' do
      it 'enqueues email asking candidate to respond to offers' do
        application_form = create(:application_form)
        create(:application_choice, :offered, application_form:)
        create(:application_choice, :rejected_by_default, application_form:)

        expect { described_class.new.perform([application_form.id]) }
          .to have_enqueued_mail(CandidateMailer, :respond_to_offer_before_winter_deadline)
      end
    end

    context 'candidate does not have offers' do
      it 'enqueues email telling candidate why their application was rejected' do
        application_form = create(:application_form)
        create(:application_choice, :rejected_by_default, application_form:)

        expect { described_class.new.perform([application_form.id]) }
          .to have_enqueued_mail(CandidateMailer, :winter_reject_by_default_explainer)
      end
    end
  end
end
