require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.candidate_invite' do
    it 'renders the content for a providers invite' do
      candidate = create(:candidate, email_address: 'candidate@email.address')
      application_form = create(:application_form,
                                :minimum_info,
                                candidate:,
                                first_name: 'Joe')
      pool_invite = create(:pool_invite, candidate:, application_form:)

      email = described_class.candidate_invite(pool_invite)

      expect(email.to).to eq(['candidate@email.address'])
      expect(email.subject).to include('You’ve been invited to apply for teacher training')
      expect(email.body).to have_text('Dear Joe,')
      expect(email.body).to have_text(
        "#{pool_invite.course.provider.name} has reviewed your details and would like to invite you to submit an application to:",
      )
      expect(email.body).to have_text pool_invite.course.name_and_code
      expect(email.body).to have_text('Course length: 1 year')
      expect(email.body).to have_text("Age range: #{pool_invite.course.age_range}")
      expect(email.body).to have_text("Qualification: #{pool_invite.course.qualifications_to_s}")
      expect(email.body).to have_text("Start date: #{pool_invite.course.start_date.to_fs(:month_and_year)}")

      expect(email.body).to have_text("[Accept or decline this invitation](#{edit_candidate_interface_invite_url(pool_invite)})")

      expect(email.body).to have_text('What happens if you do not respond')
      expect(email.body).to have_text(
        'If you do not accept or decline this invitation, and you receive another one, providers will no longer be able to find you in searches or invite you to their courses.',
      )
      expect(email.body).to have_text(
        'You are receiving this email because you chose to share your application details with training providers.',
      )
      expect(email.body).to have_text(
        "[You can change your preferences](#{new_candidate_interface_pool_opt_in_url})",
      )
    end
  end
end
