require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.course_invite' do
    let(:application_form) { create(:application_form, :minimum_info) }
    let(:candidate) { application_form.candidate }
    let(:pool_invite) { create(:pool_invite, candidate:) }
    let(:email) { described_class.course_invite(pool_invite) }

    context 'when candidate has opted out of publishing preferences' do
      it 'they see the link to opt back in' do
        create(:candidate_preference, candidate:, pool_status: 'opt_out')
        expect(email.body).to have_content edit_candidate_interface_pool_opt_in_url(candidate.published_preferences.last)
      end
    end

    context 'when candidate does not have any published preferences' do
      it 'they see the link to create preferences' do
        expect(email.body).to have_content new_candidate_interface_pool_opt_in_url
      end
    end

    context 'when has opted in and has published preferences' do
      it 'they see the link to update their preferences' do
        create(:candidate_preference, candidate:, pool_status: 'opt_in')
        expect(email.body).to have_content candidate_interface_draft_preference_publish_preferences_url(candidate.published_preferences.last)
      end
    end
  end
end
