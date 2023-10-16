require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  subject(:mailer) { described_class }

  let(:candidate) { build_stubbed(:candidate) }
  let!(:application_form) { build_stubbed(:application_form, first_name: 'Bob', candidate:, application_choices:) }
  let(:provider) { build_stubbed(:provider, name: 'Brighthurst Technical College') }
  let(:course) { build_stubbed(:course, name: 'Applied Science (Psychology)', code: '3TT5', provider:) }
  let(:current_course) { build_stubbed(:course, name: 'Primary', code: '33WA', provider: other_provider) }
  let(:course_option) { build_stubbed(:course_option, course:) }
  let(:current_course_option) { build_stubbed(:course_option, course: current_course) }

  let(:other_provider) { build_stubbed(:provider, name: 'Falconholt Technical College', code: 'X100') }
  let(:other_course) { build_stubbed(:course, name: 'Forensic Science', code: 'E0FO', provider: other_provider) }
  let(:site) { build_stubbed(:site, name: 'Aquaria') }
  let(:other_option) { build_stubbed(:course_option, course: other_course, site:) }

  let(:offer) { build_stubbed(:offer, conditions: [build_stubbed(:text_condition, description: 'Be cool')]) }
  let(:other_offer) { build_stubbed(:offer, conditions: [build_stubbed(:text_condition, description: 'Be even cooler')]) }
  let(:application_choice_with_offer) { build_stubbed(:application_choice, :offered, offer:, course_option:) }
  let(:awaiting_decision) { build_stubbed(:application_choice, :awaiting_provider_decision, course_option: other_option, current_course_option: other_option) }
  let(:interviewing) { build_stubbed(:application_choice, :awaiting_provider_decision, status: :interviewing, course_option: other_option, current_course_option: other_option) }

  let(:application_choices) { [] }

  before do
    magic_link_stubbing(candidate)
  end

  describe '.new_offer_single_offer' do
    let(:email) { mailer.new_offer_single_offer(application_choices.first) }
    let(:application_choices) { [application_choice_with_offer] }

    before do
      allow(CourseOption).to receive(:find_by).with(id: application_choice_with_offer.current_course_option_id).and_return(application_choice_with_offer.current_course_option)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Successful application for Brighthurst Technical College',
      'heading' => 'Dear Bob',
      'decline by default date' => "Respond by #{10.business_days.from_now.to_fs(:govuk_date)}",
      'first_condition' => 'Be cool',
      'deferral_guidance' => 'You can defer your offer and start your course a year later.',
    )

    context 'when the provider offers the candidate a different course option' do
      let(:other_course) { build_stubbed(:course, name: 'Computer Science', code: 'X0FO', provider: other_provider) }
      let(:other_option) { build_stubbed(:course_option, course: other_course) }
      let(:application_choice_with_offer) { build_stubbed(:application_choice, :offered, offer:, current_course_option: other_option, course_option:) }

      it_behaves_like(
        'a mail with subject and content',
        'Successful application for Falconholt Technical College',
        'heading' => 'Dear Bob',
        'course and provider' => 'offer from Falconholt Technical College to study Computer Science (X0FO)',
        'decline by default date' => "Respond by #{10.business_days.from_now.to_fs(:govuk_date)}",
        'deferral_guidance' => 'You can defer your offer and start your course a year later.',
      )
    end
  end

  describe '.new_offer_multiple_offers' do
    let(:email) { mailer.new_offer_multiple_offers(application_choices.first) }
    let(:application_choice_with_other_offer) { build_stubbed(:application_choice, :offered, offer: other_offer, course_option: other_option) }
    let(:application_choices) { [application_choice_with_offer, application_choice_with_other_offer] }

    it_behaves_like(
      'a mail with subject and content',
      'Successful application for Brighthurst Technical College',
      'heading' => 'Dear Bob',
      'decline by default date' => "Respond by #{10.business_days.from_now.to_fs(:govuk_date)}",
      'first_condition' => 'Be cool',
      'first_offer' => 'Applied Science (Psychology) (3TT5) at Brighthurst Technical College',
      'second_offers' => 'Forensic Science (E0FO) at Falconholt Technical College',
      'deferral_guidance' => 'You can defer your offer and start your course a year later.',
    )
  end

  describe '.new_offer_decisions_pending' do
    let(:email) { mailer.new_offer_decisions_pending(application_choices.first) }
    let(:application_choices) { [application_choice_with_offer, awaiting_decision] }

    it_behaves_like(
      'a mail with subject and content',
      'Successful application for Brighthurst Technical College',
      'heading' => 'Dear Bob',
      'instructions' => 'You can wait to hear back about your other application(s) before accepting or declining any offers.',
      'deferral_guidance' => 'You can defer your offer and start your course a year later.',
    )
  end

  describe 'rejection emails' do
    let(:future_applications) { 'Yes' }
    let(:rejection_reasons) do
      {
        quality_of_application_y_n: 'Yes',
        quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge],
        quality_of_application_personal_statement_what_to_improve: 'Do not refer to yourself in the third person',
        quality_of_application_subject_knowledge_what_to_improve: 'Write in the first person',
        qualifications_y_n: 'Yes',
        qualifications_other_details: 'Bad qualifications',
        qualifications_which_qualifications: %w[no_english_gcse other],
        interested_in_future_applications_y_n: future_applications,
      }
    end

    let(:rejected) do
      build_stubbed(
        :application_choice,
        status: :rejected,
        course_option: other_option,
        current_course_option: other_option,
        structured_rejection_reasons: rejection_reasons,
        rejection_reasons_type: 'reasons_for_rejection',
      )
    end

    describe '.application_rejected_all_applications_rejected', continuous_applications: false do
      let(:email) { mailer.application_rejected_all_applications_rejected(application_choices.first) }

      let(:application_choices) { [rejected] }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.application_rejected_all_applications_rejected.subject', provider_name: 'Falconholt Technical College'),
        'heading' => 'Dear Bob',
        'course name and code' => 'Forensic Science (E0FO)',
        'rejection reason heading' => 'Quality of application',
        'rejection reason content' => 'Write in the first person',
        'qualifications rejection heading' => 'Qualifications',
        'qualifications rejection content' => 'Bad qualifications',
        'link to course on find' => 'https://www.find-postgraduate-teacher-training.service.gov.uk/course/X100/E0FO#section-entry',
      )

      it 'includes future applications section' do
        expect(email.body).to include('Future applications')
        expect(email.body).to include('would be interested in future applications from you.')
      end

      context 'when future applications question has not been given' do
        let(:future_applications) { nil }

        it 'does not include future applications section' do
          expect(email.body).not_to include('Future applications')
        end
      end

      context 'when no main structured reasons for rejection were given' do
        let(:rejection_reasons) do
          {
            why_are_you_rejecting_this_application: 'You could not correctly guess the number of jelly beans in the jar',
            other_advice_or_feedback_y_n: 'Yes',
            other_advice_or_feedback_details: 'There were actually 1567 jelly beans in the jar',
          }
        end

        it 'includes the other feedback section' do
          expect(email.body).to include('Reasons why your application was unsuccessful')
          expect(email.body).to include(rejection_reasons[:why_are_you_rejecting_this_application])
        end

        it 'includes the additional advice section' do
          expect(email.body).to include('Additional advice')
          expect(email.body).to include(rejection_reasons[:other_advice_or_feedback_details])
        end
      end

      context 'when it is before the apply_2_deadline' do
        before do
          allow(CycleTimetable).to receive(:between_cycles_apply_2?).and_return(false)
        end

        it 'informs the candidate they can apply again this year' do
          expect(email.body).to include('If now’s the right time for you, you can still apply for teacher training again this year.')
        end
      end

      context 'when it is after the apply_2_deadline' do
        before do
          allow(CycleTimetable).to receive_messages(between_cycles_apply_2?: true, apply_reopens: Time.zone.local(RecruitmentCycle.current_year, 10, 12, 9))
          allow(RecruitmentCycle).to receive(:next_year).and_return(RecruitmentCycle.next_year)
        end

        it 'informs the candidate they can apply again next year' do
          expect(email.body).to include("You can apply again for courses starting in the #{RecruitmentCycle.next_year} to #{RecruitmentCycle.next_year + 1} academic year.")
          expect(email.body).to include('All you need to do is:')
          expect(email.body).to include("9am on 12 October #{RecruitmentCycle.current_year}")
        end
      end
    end

    describe '.application_rejected_awaiting_decision_only', continuous_applications: false do
      let(:email) { mailer.application_rejected_awaiting_decision_only(application_choices.first) }
      let(:application_choices) { [rejected, awaiting_decision, interviewing] }

      TestSuiteTimeMachine.travel_temporarily_to(mid_cycle(2023)) do
        it_behaves_like(
          'a mail with subject and content',
          I18n.t!('candidate_mailer.application_rejected_awaiting_decision_only.subject'),
          'heading' => 'Dear Bob',
          'course name and code' => 'Forensic Science (E0FO)',
          'rejection reasons' => 'Bad qualifications',
          'other application details' => 'You’re waiting for decisions',
          'first application' => 'Falconholt Technical College to study Forensic Science',
          'decision day' => "They should make their decisions by #{40.business_days.from_now.to_fs(:govuk_date)}",
        )
      end
    end

    describe '.application_rejected_offers_only', continuous_applications: false do
      let(:email) { mailer.application_rejected_offers_only(application_choices.first) }
      let(:application_choices) { [rejected, application_choice_with_offer, application_choice_with_offer] }

      TestSuiteTimeMachine.travel_temporarily_to(mid_cycle(2023)) do
        it_behaves_like(
          'a mail with subject and content',
          I18n.t!('candidate_mailer.application_rejected_offers_only.subject', date: 10.business_days.from_now.to_fs(:govuk_date)),
          'heading' => 'Dear Bob',
          'course name and code' => 'Forensic Science (E0FO)',
          'rejection reasons' => 'Do not refer to yourself in the third person',
          'other application details' => 'You’re not waiting for any other decisions.',
          'first application details' => 'Brighthurst Technical College to study Applied Science (Psychology)',
          'respond by date' => "will be automatically declined if you do not respond by #{10.business_days.from_now.to_fs(:govuk_date)}",
        )
      end
    end
  end

  describe '.feedback_received_for_application_rejected_by_default' do
    let(:application_choices) { [build_stubbed(:application_choice, :rejected_by_default_with_feedback, course_option:, current_course_option: course_option, rejection_reason: 'I\'m so happy')] }

    context 'candidate has been awarded a place on a course or has applied again since' do
      let(:email) { mailer.feedback_received_for_application_rejected_by_default(application_choices.first, true) }

      it_behaves_like(
        'a mail with subject and content',
        'Feedback on your application for Brighthurst Technical College',
        'heading' => 'Dear Bob',
        'provider name' => 'Brighthurst Technical College',
        'name and code for course' => 'Applied Science (Psychology) (3TT5)',
        'feedback' => 'I\'m so happy',
      )

      it 'encourages candidate to apply again' do
        expect(email.body).to include('use your feedback to strengthen your application and apply again')
      end
    end

    context 'candidate did not get a place on any of their courses and has not applied again since' do
      let(:email) { mailer.feedback_received_for_application_rejected_by_default(application_choices.first, false) }

      it_behaves_like(
        'a mail with subject and content',
        'Feedback on your application for Brighthurst Technical College',
        'heading' => 'Dear Bob',
        'provider name' => 'Brighthurst Technical College',
        'name and code for course' => 'Applied Science (Psychology) (3TT5)',
        'feedback' => 'I\'m so happy',
      )

      it 'does not encourage candidate to apply again' do
        expect(email.body).not_to include('If this feedback was useful, consider using it to strengthen your application and apply again:')
      end
    end
  end

  describe '.deferred_offer' do
    let(:email) { mailer.deferred_offer(application_choices.first) }
    let(:application_choices) { [application_choice_with_offer] }

    before do
      magic_link_stubbing(application_form.candidate)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Your offer has been deferred',
      'heading' => 'Dear Bob',
      'name and code for course' => 'Applied Science (Psychology) (3TT5)',
      'name of provider' => 'Brighthurst Technical College',
      'year of new course' => "until the next academic year (#{RecruitmentCycle.next_year} to #{RecruitmentCycle.next_year + 1})",
    )
  end

  describe '.reinstated_offer' do
    let(:email) { mailer.reinstated_offer(application_choices.first) }
    let(:application_choices) { [application_choice] }
    let(:application_choice) { build_stubbed(:application_choice, :offer_deferred, offer:, course_option: other_option, current_course_option: other_option, offer_deferred_at: Time.zone.local(2019, 10, 3)) }
    let(:other_course) do
      build_stubbed(:course, name: 'Forensic Science',
                             code: 'E0FO',
                             provider: other_provider,
                             start_date: Time.zone.local(2020, 6, 5))
    end

    before do
      magic_link_stubbing(application_form.candidate)
    end

    describe 'with an unconditional offer' do
      before do
        allow(application_choice.offer).to receive(:conditions).and_return([])
      end

      it_behaves_like(
        'a mail with subject and content',
        'Your deferred offer to study Forensic Science (E0FO) has been confirmed by Falconholt Technical College',
        'heading' => 'Dear Bob',
        'provider name' => 'Falconholt Technical College has confirmed your deferred offer to study',
        'name and code for course' => 'Forensic Science (E0FO)',
        'start date of new course' => 'June 2020',
        'course starts text' => 'The course starts',
      )

      it 'does not refer to conditions' do
        expect(email.body).not_to include('condition')
      end
    end

    describe 'with pending conditions' do
      before do
        allow(application_choice.offer).to receive(:conditions)
          .and_return([build_stubbed(:text_condition, status: :pending, description: 'GCSE Maths grade 4 (C) or above, or equivalent')])
      end

      it_behaves_like(
        'a mail with subject and content',
        'Your deferred offer to study Forensic Science (E0FO) has been confirmed by Falconholt Technical College',
        'heading' => 'Dear Bob',
        'provider name' => 'Falconholt Technical College has confirmed your deferred offer to study',
        'name and code for course' => 'Forensic Science (E0FO)',
        'start date of new course' => 'June 2020',
        'conditions section' => 'You still need to meet the following condition',
        'conditions of offer' => 'GCSE Maths grade 4 (C) or above, or equivalent',
        'course starts text' => 'The course starts',
      )
    end

    describe 'with met conditions' do
      before do
        allow(application_choice.offer).to receive(:conditions)
          .and_return([build_stubbed(:text_condition, status: :met, description: 'GCSE Maths grade 4 (C) or above, or equivalent')])
      end

      it_behaves_like(
        'a mail with subject and content',
        'Your deferred offer to study Forensic Science (E0FO) has been confirmed by Falconholt Technical College',
        'heading' => 'Dear Bob',
        'provider name' => 'Falconholt Technical College has confirmed your deferred offer to study',
        'name and code for course' => 'Forensic Science (E0FO)',
        'start date of new course' => 'June 2020',
        'course starts text' => 'The course starts',
      )

      it 'does not refer to conditions' do
        expect(email.body).not_to include('condition')
      end
    end
  end

  describe '.conditions_not_met' do
    let(:email) { mailer.conditions_not_met(application_choice) }
    let(:application_choice) do
      build_stubbed(:application_choice, :conditions_not_met,
                    course_option:, current_course_option: other_option,
                    offer: build_stubbed(:offer, conditions: [build_stubbed(:text_condition, :unmet, description: 'Be cool')]),
                    decline_by_default_at: 10.business_days.from_now)
    end
    let(:application_choices) { [application_choice] }

    it_behaves_like(
      'a mail with subject and content',
      'You did not meet the offer conditions for Forensic Science (E0FO) at Falconholt Technical College',
      'greeting' => 'Hello Bob',
      'course status' => 'Your application for Forensic Science (E0FO) has been unsuccessful',
      'reason' => 'Falconholt Technical College has said that you did not meet these offer conditions:',
      'conditions' => 'Be cool',
      'next steps' => 'Unfortunately, you will not be able to join the course. Contact Falconholt Technical College if you need further advice.',
    )
  end

  describe '.conditions_met' do
    let(:email) { mailer.conditions_met(application_choices.first) }
    let(:application_choice) { build_stubbed(:application_choice, :course_changed_after_offer, course_option:, current_course_option: other_option, decline_by_default_at: 10.business_days.from_now) }
    let(:application_choices) { [application_choice] }

    before do
      allow(application_choice.current_course_option.course).to receive(:start_date)
        .and_return(Time.zone.local(2049, 6, 5))
    end

    it_behaves_like(
      'a mail with subject and content',
      'You’ve met your conditions to study Forensic Science (E0FO) at Falconholt Technical College',
      'heading' => 'Dear Bob',
      'title' => 'you’ve met the conditions of your offer',
      'provider name' => 'Falconholt Technical College',
      'start date' => 'June 2049',
      'contact info' => 'Contact Falconholt Technical College',
    )
  end

  describe '.changed_offer' do
    let(:email) { mailer.changed_offer(application_choices.first) }
    let(:application_choices) { [application_choice] }

    context 'an unconditional offer' do
      let(:application_choice) { build_stubbed(:application_choice, :awaiting_provider_decision, :course_changed_after_offer, course_option:, current_course_option: other_option, decline_by_default_at: 10.business_days.from_now, offer: build_stubbed(:unconditional_offer)) }

      it_behaves_like(
        'a mail with subject and content',
        'Offer changed for Applied Science (Psychology) (3TT5)',
        'heading' => 'Hello Bob',
        'name for original course' => 'Applied Science (Psychology)',
        'name for new course' => 'Course: Forensic Science (E0FO)',
        'name of new provider' => 'Training provider: Falconholt Technical College',
        'location of new offer' => 'Location: Aquaria',
        'study mode of new offer' => 'Full time',
        'unconditional' => 'Your offer does not have any conditions',
      )
    end

    context 'an offer with conditions' do
      let(:application_choice) { build_stubbed(:application_choice, :awaiting_provider_decision, :course_changed_after_offer, offer:, course_option:, current_course_option: other_option, decline_by_default_at: 10.business_days.from_now) }

      it_behaves_like(
        'a mail with subject and content',
        'Offer changed for Applied Science (Psychology) (3TT5)',
        'heading' => 'Hello Bob',
        'name for original course' => 'Applied Science (Psychology)',
        'name for new course' => 'Course: Forensic Science (E0FO)',
        'name of new provider' => 'Training provider: Falconholt Technical College',
        'location of new offer' => 'Location: Aquaria',
        'study mode of new offer' => 'Full time',
        'first condition' => 'Be cool',
      )
    end
  end

  describe 'Deferred offer reminder email' do
    let(:email) { mailer.deferred_offer_reminder(application_choices.first) }
    let(:application_choice) { build_stubbed(:application_choice, :offer_deferred, course_option: other_option, current_course_option: other_option, offer_deferred_at: Time.zone.local(2020, 4, 15)) }
    let(:application_choices) { [application_choice] }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.deferred_offer_reminder.subject'),
      'heading' => 'Dear Bob',
      'when offer deferred' => 'On 15 April 2020',
      'provider and course name' => 'Falconholt Technical College deferred your offer to study Forensic Science (E0FO)',
    )
  end
end
