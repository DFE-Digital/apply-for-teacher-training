require 'rails_helper'

RSpec.describe UCASMatches::SendUCASMatchEmails, sidekiq: true do
  let!(:ucas_match_no_action_needed) { create(:ucas_match, scheme: %w[D]) }
  let!(:ucas_match_action_needed) { create(:ucas_match, :with_dual_application) }
  let!(:ucas_match_to_send_remider_emails) { create(:ucas_match, :with_dual_application, :need_to_send_reminder_emails) }

  describe '#perform' do
    before do
      described_class.new.perform
    end

    it 'does not send emails for UCAS matches which do not need any action' do
      expect(email_for_candidate(ucas_match_no_action_needed.candidate)).not_to be_present
    end

    it 'sends initial emails for a UCAS match that needs action' do
      initial_email = email_for_candidate(ucas_match_action_needed.candidate)
      expect(initial_email).to be_present
      expect(initial_email.subject).to include 'Action required: it looks like you submitted a duplicate application'
    end

    it 'records when the initial emails were sent' do
      ucas_match_action_needed.reload
      expect(ucas_match_action_needed.action_taken).to eq('initial_emails_sent')
      expect(ucas_match_action_needed.candidate_last_contacted_at).to be_within(1.second).of(Time.zone.now)
    end

    it 'sends reminder emails for a UCAS match that needs action' do
      reminder_email = email_for_candidate(ucas_match_to_send_remider_emails.candidate)
      expect(reminder_email).to be_present
      expect(reminder_email.subject).to include 'Action required: please withdraw one of your duplicate applications'
    end

    it 'records when the reminder emails were sent' do
      ucas_match_to_send_remider_emails.reload
      expect(ucas_match_to_send_remider_emails.action_taken).to eq('reminder_emails_sent')
      expect(ucas_match_to_send_remider_emails.candidate_last_contacted_at).to be_within(1.second).of(Time.zone.now)
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |e| e.header['to'].value == candidate.email_address }
  end
end
