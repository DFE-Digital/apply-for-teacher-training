require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.respond_to_offer_before_winter_deadline' do
    it 'raises an error' do
      application_form = build(:completed_application_form)
      expect {
        described_class.respond_to_offer_before_winter_deadline(application_form).deliver_now
      }.to raise_error('Mailer still in development')
    end
  end
end
