require 'rails_helper'

RSpec.describe SupportInterface::CandidateEmailSendCountsExport do
  describe 'documentation' do
    before { create(:email) }

    it_behaves_like 'a data export'
  end

  describe '#data_for_export' do
    it 'returns a hash of email counts from the emails table' do
      Timecop.freeze(Time.zone.now.round) do
        yesterday = Time.zone.now - 1.day
        two_days_ago = Time.zone.now - 2.days

        'application_submitted'.tap do |mail_template|
          create(:email, mail_template: mail_template, mailer: :candidate_mailer, created_at: yesterday)
          create(:email, mail_template: mail_template, mailer: :candidate_mailer, created_at: two_days_ago)
          create(:email, mail_template: mail_template, mailer: :candidate_mailer, created_at: two_days_ago, to: 'another_recipient@email.com')
        end
        create(:email, mail_template: 'conditions_met', mailer: :candidate_mailer, created_at: two_days_ago)

        expect(described_class.new.data_for_export).to match_array([
          {
            email_template: 'application_submitted',
            send_count: 3,
            last_sent_at: yesterday.utc,
            unique_recipients: 2,
            mailer: 'Candidate mailer',
          },
          {
            email_template: 'conditions_met',
            send_count: 1,
            last_sent_at: two_days_ago.utc,
            unique_recipients: 1,
            mailer: 'Candidate mailer',
          },
        ])
      end
    end

    it 'distinguishes between templates with the same name but from different mailers' do
      Timecop.freeze(Time.zone.now.round) do
        yesterday = Time.zone.now - 1.day

        create(:email, mail_template: 'offer_accepted', mailer: :candidate_mailer, created_at: yesterday)
        create(:email, mail_template: 'offer_accepted', mailer: :provider_mailer, created_at: yesterday)

        expect(described_class.new.data_for_export).to match_array([
          {
            email_template: 'offer_accepted',
            send_count: 1,
            last_sent_at: yesterday.utc,
            unique_recipients: 1,
            mailer: 'Candidate mailer',
          },
          {
            email_template: 'offer_accepted',
            send_count: 1,
            last_sent_at: yesterday.utc,
            unique_recipients: 1,
            mailer: 'Provider mailer',
          },
        ])
      end
    end
  end
end
