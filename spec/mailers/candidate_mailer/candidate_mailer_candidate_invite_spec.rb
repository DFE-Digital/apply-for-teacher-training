require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.candidate_invites' do
    describe 'email subject' do
      context 'when there is only one provider' do
        it 'reflects the number of providers' do
          candidate = create(:candidate, email_address: 'candidate@email.address')
          _application_form = create(:application_form,
                                     :minimum_info,
                                     candidate:,
                                     first_name: 'Joe')
          pool_invite = create(:pool_invite, candidate:)

          email = described_class.candidate_invites(candidate, pool_invite)

          expect(email.to).to eq(['candidate@email.address'])
          expect(email.subject).to include('A provider has invited you to apply for teacher training')
          expect(email.body).to have_text('Dear Joe,')
          expect(email.body).to have_content pool_invite.course.provider.name
          expect(email.body).to have_content pool_invite.course.name_and_code
        end
      end
    end
  end
end
