require 'rails_helper'

RSpec.describe SupportInterface::CandidateEmailSendCountsExport do
  describe '#data_for_export' do
    it 'returns a hash of email counts from the emails table' do
      Timecop.freeze(Time.zone.now.round) do
        yesterday = Time.zone.now - 1.day
        two_days_ago = Time.zone.now - 2.days

        'application_submitted'.tap do |mail_template|
          create(:email, mail_template: mail_template, created_at: yesterday)
          create(:email, mail_template: mail_template, created_at: two_days_ago)
          create(:email, mail_template: mail_template, created_at: two_days_ago, to: 'another_recipient@email.com')
        end
        create(:email, mail_template: 'conditions_met', created_at: two_days_ago)

        expect(described_class.new.data_for_export).to match_array([
          {
            'Email' => 'application_submitted',
            'Send count' => 3,
            'Last sent at' => yesterday.utc,
            'Unique recipients' => 2,
          },
          {
            'Email' => 'conditions_met',
            'Send count' => 1,
            'Last sent at' => two_days_ago.utc,
            'Unique recipients' => 1,
          },
        ])
      end
    end
  end
end
