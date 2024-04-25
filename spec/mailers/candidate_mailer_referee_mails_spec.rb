require 'rails_helper'

RSpec.describe CandidateMailer do
  subject(:mailer) { described_class }

  before do
    TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.apply_opens(ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR))
  end

  let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR }
  let(:application_choice) { create(:application_choice) }
  let(:application_form) { create(:completed_application_form, :with_gcses, recruitment_cycle_year: recruitment_cycle_year, application_references: references, references_count: references.count, application_choices: [application_choice]) }
  let(:reference) { create(:reference, name: 'Scott Knowles') }
  let(:references) { [reference] }
  let(:course_option) do
    create(
      :course_option,
      course: create(
        :course,
        name: 'Mathematics',
        code: 'M101',
        start_date: Time.zone.local(2021, 9, 6),
        provider: create(
          :provider,
          name: 'Arithmetic College',
        ),
      ),
    )
  end

  describe '.chase_reference' do
    let(:referee) { create(:reference, name: 'Jolyne Doe', application_form: application_form) }
    let(:email) { mailer.chase_reference(referee) }
    let(:application_choice) { create(:application_choice, :pending_conditions, course_option: course_option) }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.chase_reference.subject', referee_name: 'Jolyne Doe'),
      'heading' => 'They have not replied yet',
      'description' => 'You asked Jolyne Doe for a reference for your teacher training application. They have not replied yet.',
      'provider must check' => 'Arithmetic College must check your references before they can confirm your place on the course. Contact them if you need help getting references or choosing who to ask.',
    )
  end

  describe '.new_referee_request' do
    let(:referee) { create(:reference, name: 'Jolyne Doe', application_form: application_form) }
    let(:email) { mailer.send(:new_referee_request, referee, reason:) }
    let(:application_choice) { create(:application_choice, :pending_conditions, course_option: course_option) }

    context 'when referee has not responded' do
      let(:reason) { :not_responded }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.new_referee_request.not_responded.subject', referee_name: 'Jolyne Doe'),
        'heading' => 'They have not replied yet',
        'description' => 'You asked Jolyne Doe for a reference for your teacher training application. They have not replied yet.',
        'urgency' => 'It is important that Arithmetic College receives your references as soon as possible.',
      )
    end

    context 'when referee has refused' do
      let(:reason) { :refused }
      let(:application_choice) { create(:application_choice, :pending_conditions, course_option: course_option) }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.new_referee_request.refused.subject', referee_name: 'Jolyne Doe'),
        body: 'Jolyne Doe has said that they’re unable to give you a reference.',
        'urgency' => 'It is important that Arithmetic College receives your references as soon as possible.',
      )
    end

    context 'when email address of referee has bounced' do
      let(:reason) { :email_bounced }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.new_referee_request.email_bounced.subject', referee_name: 'Jolyne Doe'),
        body: 'Your request did not reach Jolyne Doe',
        'reminder' => 'You asked Jolyne Doe for a reference for your teacher training application.',
      )
    end
  end

  describe '.reference_received' do
    let(:email) do
      mailer.send(
        :reference_received,
        application_form.application_references.creation_order.first,
      )
    end
    let(:reference) do
      build(:reference, :feedback_provided, name: 'Scott Knowles')
    end

    context 'when the candidate is pending conditions' do
      let(:application_choice) { create(:application_choice, :pending_conditions, course_option: course_option) }

      it 'includes content relating to the new flow' do
        expect(email.body).to include('Arithmetic College has received a reference for you from Scott Knowles')
        expect(email.body).to include('You can sign into your account to check the progress of your reference requests and offer conditions.')
      end
    end

    context 'when the candidate is recruited' do
      let(:application_choice) { create(:application_choice, :recruited, course_option: course_option) }

      it 'includes content relating to the new flow' do
        expect(email.body).to include('Arithmetic College has received a reference for you from Scott Knowles')
        expect(email.body).to include('You can sign into your account to check the progress of your reference requests.')
      end
    end
  end
end
