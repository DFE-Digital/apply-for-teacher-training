require 'rails_helper'

RSpec.describe EndOfCycle::SendWinterDeclineByDefaultExplainerEmailToCandidatesBatchWorker do
  describe '#perform' do
    it 'enqueues email telling candidate why their application was declined' do
      application_form = create(:application_form)
      create(:application_choice, :declined_by_default, application_form:)

      expect { described_class.new.perform([application_form.id]) }
        .to have_enqueued_mail(CandidateMailer, :winter_decline_by_default_explainer)
    end
  end
end
