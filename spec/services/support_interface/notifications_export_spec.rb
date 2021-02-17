require 'rails_helper'

RSpec.describe SupportInterface::NotificationsExport do
  describe '#data_for_export' do
    let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option: course_options.sample) }
    let!(:decided_application_choice) { create(:application_choice, :with_offer, course_option: course_options.sample) }
    let!(:rbd_application_choice) { create(:application_choice, :with_rejection_by_default, course_option: course_options.sample) }
    let!(:withdrawn_application_choice) { create(:application_choice, :withdrawn, course_option: course_options.sample) }
    let!(:interview_application_choice) { create(:application_choice, :with_scheduled_interview, course_option: course_options.sample) }
    let!(:rejected_application_choice) { create(:application_choice, :with_rejection, course_option: course_options.sample) }
    let(:course_options) { courses.map { |course| create(:course_option, course: course) } }
    let(:courses) { create_list(:course, 4, :open_on_apply, provider: provider) }
    let(:provider) { create(:provider) }

    before do
      create(:provider_user, :with_make_decisions, providers: [provider], send_notifications: false)
      create(:provider_user, :with_make_decisions, providers: [provider], send_notifications: true)
      create(:provider_user, providers: [provider], send_notifications: true)
    end

    it_behaves_like 'a data export'

    it 'returns the correct count for user notification related events' do
      expect(described_class.new.data_for_export).to match_array([
        {
          provider_code: provider.code,
          provider_name: provider.name,
          applications_received: 6,
          applications_awaiting_decisions: 2,
          applications_receiving_decisions: 2,
          applications_rbd: 1,
          applications_withdrawn: 1,
          number_of_provider_users: 3,
          users_with_make_decisions: 2,
          users_with_make_decisions_and_notifications_disabled: 1,
          users_with_make_decisions_and_notifications_enabled: 1,
        },
      ])
    end
  end
end
