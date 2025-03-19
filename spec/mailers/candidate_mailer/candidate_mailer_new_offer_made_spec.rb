require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.new_offer_made well in advance of the decline by default date' do
    let(:current_timetable) { RecruitmentCycleTimetable.current_timetable }
    let(:application_choices) do
      [build_stubbed(
        :application_choice,
        :offered,
        status: 'offer',
        current_course_option: course_option,
      )]
    end
    let(:email) { described_class.new_offer_made(application_form.application_choices.first) }

    before do
      TestSuiteTimeMachine.travel_permanently_to(current_timetable.apply_opens_at)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Successful application for Arithmetic College',
      'greeting' => 'Hello Fred',
      'offer_details' => 'Congratulations! You have an offer from Arithmetic College to study Mathematics (M101)',
      'contact' => 'Contact Arithmetic College if you have any questions about this',
      'sign in link' => 'Sign in to your account to respond to your offer',
    )

    it 'does not render offer deadline text' do
      expect(email.body).not_to include "If you want to accept this offer, you must do so by #{I18n.l(current_timetable.decline_by_default_at.to_date, format: :no_year)}. If you have not responded by then, the offer will be automatically declined on your behalf."
    end
  end

  describe '.new_offer_made within 4 weeks of decline by default date' do
    let(:current_timetable) { RecruitmentCycleTimetable.current_timetable }
    let(:email) { described_class.new_offer_made(application_form.application_choices.first) }
    let(:application_choices) do
      [build_stubbed(
        :application_choice,
        :offered,
        status: 'offer',
        current_course_option: course_option,
      )]
    end

    before do
      TestSuiteTimeMachine.travel_permanently_to(current_timetable.decline_by_default_at - 3.weeks)
    end

    it 'renders essential checks and deadline reminder text' do
      expect(email.body).to include 'An enhanced disclosure and barring service (DBS) check. This is a criminal records check to make sure it is safe for you to work with children. If you are from outside of the UK and Ireland then the training provider will request a criminal records check from your home country.'
      expect(email.body).to include 'A fitness to train to teach check. These are questions to check your ability to meet teaching standards, both physically and mentally.'
      expect(email.body).to include "If you want to accept this offer, you must do so by #{I18n.l(current_timetable.decline_by_default_at.to_date, format: :no_year)}. If you have not responded by then, the offer will be automatically declined on your behalf."
    end
  end
end
