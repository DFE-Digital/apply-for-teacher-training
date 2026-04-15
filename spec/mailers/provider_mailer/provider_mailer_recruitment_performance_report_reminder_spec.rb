require 'rails_helper'

RSpec.describe ProviderMailer do
  describe 'recruitment_performance_report_reminder' do
    let(:provider_user) { create(:provider_user, first_name: 'John', last_name: 'Smith') }

    let(:email) do
      described_class.recruitment_performance_report_reminder(provider_user)
    end

    before do
      allow(provider_user).to receive(:generate_token_for).with(:unsubscribe_link).and_return('abc123')
    end

    it_behaves_like(
      'a mail with subject and content',
      'Your weekly recruitment performance report is now available - manage teacher training applications',
      'salutation' => 'Dear John Smith',
      'heading' => 'Your weekly recruitment performance report is now available.',
      'view your recruitment date' =>
        "You can now view your recruitment data for the #{RecruitmentCycleTimetable.current_timetable.cycle_range_name} initial teacher training (ITT) cycle in the Manage teacher training service.",
      'stay informed' => 'To help you stay informed, we’ll also send a monthly email reminder prompting you to review the report.',
      'login to view' => 'Log in to Manage to view your latest report.',
      'reports url' => 'http://localhost:3000/provider/reports',
      'whats included' => 'What’s included in the report',
      'report compares' => 'The report compares your recruitment data for this cycle with the same point in the previous cycle. It also includes national-level data.',
      'find information on' =>
        /- Number of candidates who have submitted applications\s+- Number of candidates with an offer\s+- Proportion of candidates with an offer\s+- Number of candidates who have accepted an offer\s+- Number of deferrals\s+- Number of candidates rejected\s+- Proportion of candidates waiting more than 30 days for a response/,
      'unsubscribe' => 'Unsubscribe from reminder emails like this one](http://localhost:3000/provider/unsubscribe-from-emails/abc123). You will still receive essential updates about applications.',
      'unsubscribe_link' => 'http://localhost:3000/provider/unsubscribe-from-emails/abc123',
      'footer' => 'Get help, report a problem or give feedback',
    )
  end
end
