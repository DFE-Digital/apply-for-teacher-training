require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.invites_chaser' do
    it 'renders the content for a invite chaser' do
      candidate = create(:candidate, email_address: 'candidate@email.address')
      application_form = create(:application_form,
                                :minimum_info,
                                candidate:,
                                first_name: 'Joe')
      create(:candidate_preference, application_form:)
      pool_invites = create_list(:pool_invite, 2, :sent_to_candidate, candidate:, application_form:)

      email = described_class.invites_chaser(pool_invites)

      expect(email.to).to eq(['candidate@email.address'])
      expect(email.subject).to include('You will no longer be invited to teacher training courses')
      expect(email.body).to have_text('Dear Joe,')
      expect(email.body).to have_text(
        'You have not accepted or declined your invitations from training providers to apply to their courses.',
      )
      expect(email.body).to have_text(
        'Because you have not responded, providers can no longer find you in searches or invite you to their courses.',
      )
      expect(email.body).to have_text(
        'This will not affect any applications you have already submitted or plan to submit.',
      )
      expect(email.body).to have_text(
        "[Accept of decline your invitations](#{candidate_interface_invites_url})",
      )
      expect(email.body).to have_text(
        'to let providers find you in searches and invite you to their courses again.',
      )
      expect(email.body).to have_text(
        'You are receiving this email because you chose to share your application details with training providers.',
      )
      expect(email.body).to have_text(
        "[You can change your preferences](#{candidate_interface_draft_preference_publish_preferences_url(application_form.published_preference)})",
      )
    end
  end
end
