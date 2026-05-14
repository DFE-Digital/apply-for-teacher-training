require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.winter_reject_by_default_explainer' do
    it 'raises an error' do
      application_form = build(:completed_application_form)
      expect {
        described_class.winter_reject_by_default_explainer(application_form).deliver_now
      }.to raise_error('Mailer still in development')
    end
  end
end
