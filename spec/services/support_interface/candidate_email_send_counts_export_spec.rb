require 'rails_helper'

RSpec.describe SupportInterface::CandidateEmailSendCountsExport do
  describe '#data_for_export' do
    it 'returns a hash of email counts from the emails table' do
      yesterday = Time.zone.yesterday
      two_days_ago = Time.zone.today - 2.days
      most_recent_app_submitted_email = create(:email, mail_template: 'application_submitted', created_at: yesterday)
      create(:email, mail_template: 'application_submitted', created_at: two_days_ago)
      most_recent_conditions_met_email = create(:email, mail_template: 'conditions_met', created_at: two_days_ago)

      expect(described_class.new.data_for_export).to match_array([
        {
          'Email' => 'application_submitted',
          'Send count' => 2,
          'Last sent at' => most_recent_app_submitted_email.created_at,
          'Unique recipients' => 1,
        },
        {
          'Email' => 'conditions_met',
          'Send count' => 1,
          'Last sent at' => most_recent_conditions_met_email.created_at,
          'Unique recipients' => 1,
        },
      ])
    end
  end
end
