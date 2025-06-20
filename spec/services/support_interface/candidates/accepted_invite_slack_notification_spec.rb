require 'rails_helper'

RSpec.describe SupportInterface::Candidates::AcceptedInviteSlackNotification do
  include Rails.application.routes.url_helpers

  let(:invite) { create(:pool_invite) }
  let(:application_form) { create(:application_form) }

  describe '.call' do
    it 'sends slack notification' do
      allow(SlackNotificationWorker).to receive(:perform_async)

      described_class.call(
        invite:,
        application_form:,
      )

      message = "Candidate ID <#{support_interface_application_form_url(application_form)}|#{application_form.candidate_id}> " \
                'has just been recruited following an invitation from ' \
                "<#{support_interface_provider_url(invite.provider)}|#{invite.provider.name}> " \
                "to <#{support_interface_course_url(invite.course)}|#{invite.course.name}> :clapclap-e:\n"

      expect(SlackNotificationWorker).to have_received(:perform_async).with(
        message,
        nil,
        '#sd_find_a_candidate_2025',
        ENV['FIND_AND_APPLY_SLACK_URL'],
      )
    end
  end
end
