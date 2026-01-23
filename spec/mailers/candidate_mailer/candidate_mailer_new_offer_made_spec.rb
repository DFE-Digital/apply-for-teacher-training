require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.new_offer_made well in advance of the decline by default date' do
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
      'greeting' => 'Hello Fred Freddy',
      'offer_details' => 'Congratulations! You have an offer from Arithmetic College to study Mathematics (M101)',
      'contact' => 'Contact Arithmetic College if you have any questions about this',
      'sign in link' => 'Sign in to your account to respond to your offer',
    )

    it 'contains the content instructing the candidate to review their offer' do
      expect(email.body).to include('Reviewing your offer')
      expect(email.body).to include(
        'You can wait to hear back from any other courses you have submitted applications to before accepting this offer. It\'s important that you accept the offer that is right for you, so take time to review your options.',
      )
    end

    it 'does not render offer deadline text' do
      expect(email.body).not_to include "If you want to accept this offer, you must do so by #{current_timetable.decline_by_default_at.to_fs(:govuk_time_first_no_year_date_time)}. If you have not responded by then, the offer will be automatically declined on your behalf."
    end

    context 'when the offer has a reference condition' do
      let(:application_choice) { create(:application_choice, current_course_option: create(:course_option)) }
      let(:offer) { create(:offer, :with_reference_condition, application_choice:) }
      let(:application_choices) { [offer.application_choice] }
      let(:provider) { offer.provider }

      it 'contains the reference condition' do
        expect(email.body).to include('References')
        expect(email.body).to include('You will also need to provide satisfactory references.')
        expect(email.body).to include("#{provider.name} has requested the following:")
        expect(email.body).to include('Provide 2 references')
      end
    end
  end

  describe '.new_offer_made within 4 weeks of decline by default date' do
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
      expect(email.body).to include "If you want to accept this offer, you must do so by #{current_timetable.decline_by_default_at.to_fs(:govuk_time_first_no_year_date_time)}. If you have not responded by then, the offer will be automatically declined on your behalf."
    end
  end

  describe '.new_offer_made with ske conditions' do
    let(:email) { described_class.new_offer_made(application_form.application_choices.first) }
    let(:application_choices) do
      [build_stubbed(
        :application_choice,
        :offered,
        status: 'offer',
        current_course_option: course_option,
        offer: build(:offer, :with_ske_conditions),
      )]
    end

    it 'renders essential checks and deadline reminder text' do
      expect(email.body).to include 'An enhanced disclosure and barring service (DBS) check. This is a criminal records check to make sure it is safe for you to work with children. If you are from outside of the UK and Ireland then the training provider will request a criminal records check from your home country.'
      expect(email.body).to include 'A fitness to train to teach check. These are questions to check your ability to meet teaching standards, both physically and mentally.'
      expect(email.body).to include 'You will need to meet the following conditions:'
      expect(email.body).to include 'Successful completion of an 8-week Mathematics subject knowledge enhancement course'
    end
  end
end
