require 'rails_helper'

RSpec.describe EndOfCycle::SendApplicationDeadlineHasPassedEmailToCandidatesBatchWorker do
  describe '#perform' do
    it 'calls candidate mailer with application form' do
      application_form = create(:application_form, :unsubmitted)

      expect { described_class.new.perform([application_form.id]) }.to have_enqueued_mail(CandidateMailer, :application_deadline_has_passed)
    end
  end
end
