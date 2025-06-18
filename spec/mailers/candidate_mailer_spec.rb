require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  it_behaves_like 'mailer previews', Candidate::ApplicationSubmittedPreview
  it_behaves_like 'mailer previews', Candidate::ApplicationUnsubmittedPreview
  it_behaves_like 'mailer previews', Candidate::EndOfCyclePreview
  it_behaves_like 'mailer previews', Candidate::FindACandidatePreview
  it_behaves_like 'mailer previews', Candidate::InterviewPreview
  it_behaves_like 'mailer previews', Candidate::OffersPreview
  it_behaves_like 'mailer previews', Candidate::ReferencesPreview
  it_behaves_like 'mailer previews', Candidate::WithdrawalsAndRejectionsPreview

  describe 'click-tracking' do
    let(:email) { described_class.nudge_unsubmitted(application_form) }

    before { email_log_interceptor_stubbing }

    it 'adds header to email containing notify reference' do
      expect(email.header[:reference]&.value).to eq('fake-ref-123')
    end

    it 'appends the notify reference as a `utm_source` url param on links within the email body' do
      expect(email.body).to include('utm_source=fake-ref-123')
    end
  end
end
