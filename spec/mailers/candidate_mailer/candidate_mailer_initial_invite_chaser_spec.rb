require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.initial_invite_chaser' do
    it 'renders the content for a providers invite' do
      candidate = create(:candidate, email_address: 'candidate@email.address')
      application_form = create(:application_form,
                                :minimum_info,
                                candidate:,
                                first_name: 'Joe')
      pool_invite = create(:pool_invite, candidate:, application_form:)

      email = described_class.initial_invite_chaser(pool_invite)

      expect(email.to).to eq(['candidate@email.address'])
      expect(email.subject).to include('You’ve been invited to apply for teacher training')
      expect(email.body).to have_text('Dear Joe,')
      expect(email.body).to have_text(
        'You have received an invitation from training providers to apply to their course:',
      )

      expect(email.body).to have_text("[Accept or decline this invitation](#{edit_candidate_interface_invite_url(pool_invite)})")

      expect(email.body).to have_text('What happens if you do not respond')
      expect(email.body).to have_text(
        'If you do not accept or decline this invitation, providers will no longer be able to find you in searches or invite you to their courses.',
      )
      expect(email.body).to have_text(
        'This will not affect any applications you have already submitted or plan to submit.',
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
