require 'rails_helper'

RSpec.describe UCASMatches::ResolveOnUCAS, sidekiq: true do
  let(:ucas_match) { create(:ucas_match, :with_dual_application) }

  context 'when the application has a ucas_match' do
    before do
      ucas_match.application_choices_for_same_course_on_both_services.first.provider.provider_users = [create(:provider_user)]
      described_class.new(ucas_match).call
    end

    it 'sets the application as resolved on UCAS and sends the relevant emails' do
      candidate_email = ActionMailer::Base.deliveries.find { |e| e.header['rails-mailer'].value == 'candidate_mailer' }
      provider_email = ActionMailer::Base.deliveries.find { |e| e.header['rails-mailer'].value == 'provider_mailer' }

      expect(ucas_match.action_taken).to eq('resolved_on_ucas')
      expect(candidate_email.header['rails-mail-template'].value).to eq('ucas_match_resolved_on_ucas_email')
      expect(provider_email.header['rails-mail-template'].value).to eq('ucas_match_resolved_on_ucas_email')
    end
  end

  context 'when we requested withdrawal from UCAS' do
    before do
      ucas_match.ucas_withdrawal_requested!
      ucas_match.application_choices_for_same_course_on_both_services.first.provider.provider_users = [create(:provider_user)]
      described_class.new(ucas_match).call
    end

    it 'sets the application as resolved on UCAS and sends the relevant emails' do
      candidate_email = ActionMailer::Base.deliveries.find { |e| e.header['rails-mailer'].value == 'candidate_mailer' }
      provider_email = ActionMailer::Base.deliveries.find { |e| e.header['rails-mailer'].value == 'provider_mailer' }

      expect(ucas_match.action_taken).to eq('resolved_on_ucas')
      expect(candidate_email.header['rails-mail-template'].value).to eq('ucas_match_resolved_on_ucas_at_our_request_email')
      expect(provider_email.header['rails-mail-template'].value).to eq('ucas_match_resolved_on_ucas_email')
    end
  end
end
