require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.candidate_invites' do
    describe 'email subject' do
      context 'when there are more than one different providers' do
        it 'reflects the number of providers' do
          application_form = create(:application_form, :minimum_info)
          candidate = application_form.candidate
          pool_invite_1 = create(:pool_invite, candidate:, provider: create(:provider))
          pool_invite_2 = create(:pool_invite, candidate:, provider: create(:provider))

          email = described_class.candidate_invites([
            pool_invite_1,
            pool_invite_2,
          ])

          expect(email.subject).to include('2 providers have invited you to apply for teacher training')
        end
      end

      context 'when there is only one provider' do
        it 'reflects the number of providers' do
          application_form = create(:application_form, :minimum_info)
          candidate = application_form.candidate
          provider = create(:provider)
          pool_invite_1 = create(:pool_invite, candidate:, provider:)
          pool_invite_2 = create(:pool_invite, candidate:, provider:)

          email = described_class.candidate_invites([
            pool_invite_1,
            pool_invite_2,
          ])

          expect(email.subject).to include('A provider has invited you to apply for teacher training')
        end
      end
    end

    it 'sends the details of all invites' do
      candidate = create(:candidate, email_address: 'candidate@email.address')
      _application_form = create(:application_form,
                                 :minimum_info,
                                 candidate:,
                                 first_name: 'Joe')
      pool_invites = create_list(:pool_invite, 2, candidate:)

      email = described_class.candidate_invites(pool_invites)

      expect(email.to).to eq(['candidate@email.address'])
      expect(email.body).to have_text('Dear Joe,')

      pool_invites.each do |invite|
        expect(email.body).to have_content invite.course.provider.name
        expect(email.body).to have_content invite.course.name_and_code
        # expect(email.body).to have_content invite.course.start_date.strftime('%-d %B %Y')
        # expect(email.body).to have_content candidate_interface_course_invite_url(invite)
      end
    end
  end
end
