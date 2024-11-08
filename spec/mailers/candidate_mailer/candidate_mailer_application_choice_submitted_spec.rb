require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  before do
    magic_link_stubbing(candidate)
  end

  describe '#application_choice_submitted' do
    let(:candidate) { create(:candidate) }
    let(:email) { described_class.application_choice_submitted(application_form.application_choices.first) }

    it_behaves_like(
      'a mail with subject and content',
      'You have submitted your teacher training application',
      'intro' => 'You have submitted an application for',
      'magic link to authenticate' => 'http://localhost:3000/candidate/sign-in/confirm?token=raw_token',
      'dynamic paragraph' => 'Your training provider will contact you if they would like to organise an interview',
    )
  end
end
