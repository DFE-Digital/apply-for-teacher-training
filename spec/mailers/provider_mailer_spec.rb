require 'rails_helper'

RSpec.describe ProviderMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe 'Send account created email' do
    let(:mail) { mailer.account_created(build_stubbed(:provider_user)) }

    before { mail.deliver_later }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('provider_account_created.email.subject'))
    end

    it 'addresses the provider by name' do
      pending 'we don\'t yet store the names - only email addresses but this is being added because it\'s needed for DSI registration'
      expect(mail.body.encoded).to include('Dear Bob')
    end

    it 'includes a link to the provider home page' do
      expect(mail.body.encoded).to include(provider_interface_applications_url)
    end
  end
end
