require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  before do
    magic_link_stubbing(candidate)
  end

  describe '.chase_reference_again' do
    let(:email) { described_class.chase_reference_again(referee) }
    let(:application_choices) { [create(:application_choice, :pending_conditions, course_option:)] }
    let(:candidate) { create(:candidate) }
    let(:referee) { create(:reference, name: 'Jolyne Doe', application_form:) }

    it_behaves_like(
      'a mail with subject and content',
      'Jolyne Doe has not replied to your request for a reference',
      'sign_in_link' => '/candidate/account?utm_source=test',
      'reminder' => 'Arithmetic College needs to check your references before they can confirm your place on the course.',
    )
  end
end
