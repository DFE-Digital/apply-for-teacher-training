require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.reference_received' do
    let(:email) { described_class.reference_received(referee) }

    let(:referee) { create(:reference, :feedback_provided, application_form:, name: 'Scott Knowles') }

    context 'when the candidate is pending conditions' do
      let(:application_choices) { [create(:application_choice, :pending_conditions, course_option:)] }

      it 'includes content related to pending conditions' do
        expect(email.body).to include('Arithmetic College has received a reference for you from Scott Knowles')
        expect(email.body).to include('You can sign into your account to check the progress of your reference requests and offer conditions.')
      end
    end

    context 'when the candidate is recruited' do
      let(:application_choices) { [create(:application_choice, :recruited, course_option: course_option)] }

      it 'does not inlude content related to pending conditions' do
        expect(email.body).to include('Arithmetic College has received a reference for you from Scott Knowles')
        expect(email.body).to include('You can sign into your account to check the progress of your reference requests.')
      end
    end
  end
end
