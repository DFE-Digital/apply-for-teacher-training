require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper
  let(:email) { described_class.chase_reference(referee) }

  describe '.chase_reference' do
    let(:referee) { create(:reference, name: 'Jolyne Doe', application_form:) }
    let(:application_choices) { [create(:application_choice, :pending_conditions, course_option:)] }

    it_behaves_like(
      'a mail with subject and content',
      'Jolyne Doe has not replied to your request for a reference',
      'heading' => 'They have not replied yet',
      'description' => 'You asked Jolyne Doe for a reference for your teacher training application. They have not replied yet.',
      'provider must check' => 'Arithmetic College must check your references before they can confirm your place on the course. Contact them if you need help getting references or choosing who to ask.',
    )
  end
end
