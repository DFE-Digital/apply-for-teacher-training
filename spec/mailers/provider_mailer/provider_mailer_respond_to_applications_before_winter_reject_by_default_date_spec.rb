require 'rails_helper'

RSpec.describe ProviderMailer do
  include TestHelpers::MailerSetupHelper

  describe '.respond_to_applications_before_winter_reject_by_default_date' do
    it 'raises an error' do
      provider_user = build(:provider_user)
      expect {
        described_class.respond_to_applications_before_winter_reject_by_default_date(provider_user).deliver_now
      }.to raise_error('Mailer still in development')
    end
  end
end
