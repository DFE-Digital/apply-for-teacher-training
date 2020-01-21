require 'rails_helper'

RSpec.describe ProviderMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe 'Send account created email' do
    before do
      @provider_user = build_stubbed(:provider_user)
      @mail = mailer.account_created(@provider_user)
    end

    it 'sends an email with the correct subject' do
      expect(@mail.subject).to include(t('provider_account_created.email.subject'))
    end

    it 'addresses the provider by name' do
      expect(@mail.body.encoded).to include("Dear #{@provider_user.first_name} #{@provider_user.last_name}")
    end

    it 'includes a link to the provider home page' do
      expect(@mail.body.encoded).to include(provider_interface_applications_url)
    end
  end
end
