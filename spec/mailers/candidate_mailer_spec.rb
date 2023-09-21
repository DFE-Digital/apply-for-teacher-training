require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

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
  let(:dbd_application) { build_stubbed(:application_choice, :declined_by_default) }
  let(:application_choices) { [build_stubbed(:application_choice)] }
  let(:candidate) { create(:candidate) }
  let(:application_form) do
    build_stubbed(:application_form, first_name: 'Fred',
                                     candidate:,
                                     recruitment_cycle_year:,
                                     application_choices:)
  end
  let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR }

  before do
    magic_link_stubbing(candidate)
  end

  it_behaves_like 'mailer previews', CandidateMailerPreview

  subject(:mailer) { described_class }

  describe '.application_submitted' do
    let(:application_choice) { build_stubbed(:application_choice, reject_by_default_at: 5.days.from_now) }
    let(:application_form) {
      build_stubbed(:application_form, first_name: 'Jimbo',
                                       candidate:,
                                       application_choices: [application_choice])
    }
    let(:email) { mailer.application_submitted(application_form) }

    context 'when not continuous applications', continuous_applications: false do
      TestSuiteTimeMachine.travel_temporarily_to(mid_cycle(2023)) do
        it_behaves_like(
          'a mail with subject and content',
          I18n.t!('candidate_mailer.application_submitted.subject'),
          'intro' => 'You’ve submitted an application for',
          'magic link to authenticate' => 'http://localhost:3000/candidate/sign-in/confirm?token=raw_token',
          'dynamic paragraph' => 'Your training provider will contact you if they would like to organise an interview',
          'reject_by_default date' => 5.days.from_now.to_fs(:govuk_date),
        )
      end
    end

    context 'when continuous applications', :continuous_applications do
      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.application_submitted.subject'),
        'intro' => 'You’ve submitted an application for',
        'magic link to authenticate' => 'http://localhost:3000/candidate/sign-in/confirm?token=raw_token',
        'dynamic paragraph' => 'Your training provider will contact you if they would like to organise an interview',
      )
    end
  end

  describe '.application_rejected' do
    let(:application_choice) { build_stubbed(:application_choice, :rejected, rejection_reason: 'Missing your English GCSE', course_option:) }
    let(:application_form) {
      build_stubbed(:application_form,
                    candidate:,
                    application_choices: [application_choice])
    }
    let(:email) { mailer.application_rejected(application_choice) }

    before { allow(EmailLogInterceptor).to receive(:generate_reference).and_return('fake-ref-123') }

    context 'when the candidate receives a rejection and continuous applications', :continuous_applications do
      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.application_rejected.subject'),
        'intro' => 'Thank you for your application to study Mathematics at Arithmetic College',
        'rejection reasons' => 'Missing your English GCSE',
      )
    end
  end

  describe 'Candidate decision chaser email' do
    let(:email) { mailer.chase_candidate_decision(application_form) }
    let(:offer) do
      build_stubbed(:application_choice, :offered,
                    sent_to_provider_at: Time.zone.today,
                    course_option:)
    end
    let(:course_option) do
      build_stubbed(:course_option, course: build_stubbed(:course,
                                                          name: 'Applied Science (Psychology)',
                                                          code: '3TT5', provider:))
    end
    let(:provider) { build_stubbed(:provider, name: 'Brighthurst Technical College') }

    context 'when a candidate has one appication choice with offer' do
      let(:application_choices) { [offer] }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.chase_candidate_decision.subject_singular'),
        'heading' => 'Dear Fred',
        'dbd date' => "respond by #{10.business_days.from_now.to_fs(:govuk_date)}",
        'course name and code' => ' Applied Science (Psychology)',
        'provider name' => 'Brighthurst Technical College',
      )
    end

    context 'when a candidate has multiple application choices with offer' do
      let(:second_offer) do
        build_stubbed(:application_choice, :offered,
                      sent_to_provider_at: Time.zone.today,
                      course_option: second_course_option)
      end
      let(:second_course_option) do
        build_stubbed(:course_option, course: build_stubbed(:course,
                                                            name: 'Code Refactoring',
                                                            code: 'CRF5',
                                                            provider: other_provider))
      end
      let(:other_provider) { build_stubbed(:provider, name: 'Ting University') }
      let(:application_choices) { [offer, second_offer] }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.chase_candidate_decision.subject_plural'),
        'first course with offer' => 'Applied Science (Psychology)',
        'first course provider with offer' => 'Brighthurst Technical College',
        'second course with offer' => 'Code Refactoring',
        'second course provider with offer' => 'Ting University',
      )
    end
  end

  describe '.decline_by_default' do
    let(:email) { mailer.declined_by_default(application_form) }

    context 'when a candidate has 1 offer that was declined' do
      let(:application_choices) { [dbd_application] }

      it_behaves_like(
        'a mail with subject and content',
        'You did not respond to your offer: next steps',
        'heading' => 'Dear Fred',
        'days left to respond' => '10 working days',
      )
    end

    context 'when a candidate has 2 or 3 offers that were declined' do
      let(:application_choices) { [dbd_application, dbd_application] }

      it_behaves_like 'a mail with subject and content', 'You did not respond to your offers: next steps', {}
    end

    context 'when a candidate has 1 offer that was declined by default and a rejection' do
      let(:application_choices) { [dbd_application, build_stubbed(:application_choice, status: 'rejected')] }

      context 'when it is before the apply_2_deadline' do
        before do
          allow(CycleTimetable).to receive(:between_cycles_apply_2?).and_return(false)
        end

        it_behaves_like(
          'a mail with subject and content',
          'You did not respond to your offer: next steps',
          'heading' => 'Dear Fred',
          'DBD_days_they_had_to_respond' => '10 working days',
          'still_interested' => 'If now’s the right time for you',
        )
      end

      context 'when it is after the apply_2_deadline' do
        before do
          allow(CycleTimetable).to receive_messages(between_cycles_apply_2?: true, apply_opens: Date.new(2021, 10, 13))
          allow(RecruitmentCycle).to receive(:next_year).and_return(2022)
        end

        it_behaves_like(
          'a mail with subject and content',
          'You did not respond to your offer: next steps',
          'heading' => 'Dear Fred',
          'DBD_days_they_had_to_respond' => '10 working days',
          'apply_next_cycle' => 'You can apply again for courses starting in the 2022 to 2023 academic year.',
        )
      end
    end

    context 'when a candidate has 2 offers that were declined by default and a rejection' do
      let(:application_choices) { [dbd_application, dbd_application, build_stubbed(:application_choice, status: 'rejected')] }

      before do
        allow(CycleTimetable).to receive(:between_cycles_apply_2?).and_return(false)
      end

      it_behaves_like(
        'a mail with subject and content',
        'You did not respond to your offers: next steps',
        'heading' => 'Dear Fred',
        'DBD_days_they_had_to_respond' => '10 working days',
        'still_interested' => 'If now’s the right time for you',
      )
    end

    context 'when a candidate has 1 offer that was declined and it awaiting another decision' do
      let(:application_choices) { [dbd_application, build_stubbed(:application_choice, status: 'awaiting_provider_decision')] }

      it_behaves_like(
        'a mail with subject and content',
        'Application withdrawn automatically',
        'heading' => 'Dear Fred',
        'days left to respond' => '10 working days',
      )
    end

    context 'when a candidate has 2 offers that was declined and it awaiting another decision' do
      let(:application_choices) { [dbd_application, dbd_application, build_stubbed(:application_choice, status: 'awaiting_provider_decision')] }

      it_behaves_like(
        'a mail with subject and content',
        'Applications withdrawn automatically',
        'heading' => 'Dear Fred',
        'days left to respond' => '10 working days',
      )
    end
  end

  describe '.withdraw_last_application_choice' do
    let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR }
    let(:application_form_with_references) do
      create(:application_form, first_name: 'Fred',
                                recruitment_cycle_year: recruitment_cycle_year,
                                application_choices: application_choices,
                                application_references: [referee1, referee2])
    end
    let(:referee1) { create(:reference, name: 'Jenny', feedback_status: :feedback_requested) }
    let(:referee2) { create(:reference, name: 'Luke',  feedback_status: :feedback_requested) }
    let(:email) { mailer.withdraw_last_application_choice(application_form_with_references) }

    context 'when a candidate has 1 course choice that was withdrawn' do
      let(:application_choices) { [create(:application_choice, status: 'withdrawn')] }

      it_behaves_like(
        'a mail with subject and content',
        'You’ve withdrawn your application',
        'heading' => 'Hello Fred',
        'application_withdrawn' => 'You’ve withdrawn your application',
      )
    end

    context 'when new reference flow is active' do
      let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1 }
      let(:application_choices) { [create(:application_choice, status: 'withdrawn')] }

      it_behaves_like(
        'a mail with subject and content',
        'You’ve withdrawn your application',
        'heading' => 'Hello Fred',
        'application_withdrawn' => 'You’ve withdrawn your application',
        'reference details' => 'we’ve contacted these people to say they do not need to give a reference:',
        'first referee' => 'Jenny',
        'second referee' => 'Luke',
      )
    end

    context 'when a candidate has 2 or 3 offers that were withdrawn' do
      let(:application_choices) { [create(:application_choice, :withdrawn), create(:application_choice, :withdrawn)] }

      it_behaves_like(
        'a mail with subject and content',
        'You’ve withdrawn your applications',
        'application_withdrawn' => 'You’ve withdrawn your application',
      )
    end
  end

  describe '.decline_last_application_choice' do
    let(:email) { described_class.decline_last_application_choice(application_form.application_choices.first) }
    let(:application_choices) { [build_stubbed(:application_choice, status: :declined)] }

    it_behaves_like(
      'a mail with subject and content',
      'You’ve declined an offer: next steps',
      'greeting' => 'Dear Fred',
      'content' => 'declined your offer to study',
    )
  end

  describe '.chase_reference_again' do
    let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1 }
    let(:email) { described_class.chase_reference_again(referee) }
    let(:application_choices) { [create(:application_choice, :pending_conditions, course_option: course_option)] }
    let(:application_form) { create(:application_form, recruitment_cycle_year: recruitment_cycle_year, application_choices: application_choices, candidate: candidate) }
    let(:referee) { create(:reference, name: 'Jolyne Doe', application_form: application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Jolyne Doe has not replied to your request for a reference',
      'magic_link' => '/candidate/sign-in/confirm?token=raw_token',
      'reminder' => 'Arithmetic College needs to check your references before they can confirm your place on the course.',
    )
  end

  describe '.offer_withdrawn' do
    let(:email) { described_class.offer_withdrawn(application_form.application_choices.first) }
    let(:course_option) do
      build_stubbed(
        :course_option,
        course: build_stubbed(
          :course,
          name: 'Mathematics',
          code: 'M101',
          provider: build_stubbed(
            :provider,
            name: 'Arachnid College',
          ),
        ),
      )
    end
    let(:application_choices) do
      [build_stubbed(
        :application_choice,
        status: 'offer_withdrawn',
        offer_withdrawal_reason: 'You lied to us about secretly being Spiderman',
        course_option:,
        current_course_option: course_option,
      )]
    end

    it_behaves_like(
      'a mail with subject and content',
      'Offer withdrawn by Arachnid College',
      'greeting' => 'Dear Fred',
      'offer details' => 'Arachnid College has withdrawn their offer for you to study Mathematics (M101)',
      'withdrawal reason' => 'You lied to us about secretly being Spiderman',
    )
  end

  describe '.offer_accepted' do
    let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1 }
    let(:email) { described_class.offer_accepted(application_form.application_choices.first) }
    let(:application_choices) do
      [build_stubbed(
        :application_choice,
        status: 'pending_conditions',
        course_option:,
        current_course_option: course_option,
      )]
    end

    it_behaves_like(
      'a mail with subject and content',
      'You’ve accepted Arithmetic College’s offer to study Mathematics (M101)',
      'greeting' => 'Dear Fred',
      'offer_details' => 'You’ve accepted Arithmetic College’s offer to study Mathematics (M101)',
      'course start' => 'September 2021',
    )

    it 'includes reference text' do
      expect(email.body).to include('you’ve met your offer conditions')
      expect(email.body).to include('check the progress of your reference requests')
    end
  end

  describe '.conditions_statuses_changed' do
    let(:met_conditions) { [build_stubbed(:text_condition, description: 'Do a cool trick')] }
    let(:pending_conditions) { [build_stubbed(:text_condition, description: 'Go to the moon')] }
    let(:previously_met_conditions) { [build_stubbed(:text_condition, description: 'Evidence of degree')] }
    let(:email) do
      described_class.conditions_statuses_changed(
        application_form.application_choices.first,
        met_conditions,
        pending_conditions,
        previously_met_conditions,
      )
    end
    let(:application_choices) do
      [build_stubbed(:application_choice, status: 'pending_conditions', course_option:, current_course_option: course_option)]
    end

    it_behaves_like(
      'a mail with subject and content',
      'Arithmetic College has updated the status of your conditions for Mathematics (M101)',
      'greeting' => 'Dear Fred',
      'met_condition_text' => 'They’ve marked the following condition as met:',
      'met_conditions' => 'Do a cool trick',
      'pending_condition_text' => 'They’ve marked the following condition as pending:',
      'pending_conditions' => 'Go to the moon',
      'previously_met_condition_text' => 'The following condition still needs to be met:',
      'previously_met_conditions' => 'Evidence of degree',
    )
  end

  describe '.reinstated_offer' do
    let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1 }
    let(:offer) do
      build_stubbed(:application_choice, :offered,
                    sent_to_provider_at: Time.zone.today,
                    offer: build_stubbed(:offer, conditions: [build_stubbed(:text_condition, description: 'Be cool')]),
                    course_option:)
    end
    let(:application_choices) { [offer] }
    let(:email) do
      described_class.reinstated_offer(
        application_form.application_choices.first,
      )
    end

    it_behaves_like(
      'a mail with subject and content',
      'Your deferred offer to study Mathematics (M101) has been confirmed by Arithmetic College',
      'greeting' => 'Dear Fred',
      'details' => 'Arithmetic College has confirmed your deferred offer to study',
      'pending condition text' => 'You still need to meet the following condition',
      'pending condition' => 'Be cool',
    )
  end

  describe '.unconditional_offer_accepted' do
    let(:email) { described_class.unconditional_offer_accepted(application_form.application_choices.first) }
    let(:application_choices) do
      [build_stubbed(
        :application_choice,
        status: 'pending_conditions',
        course_option:,
        current_course_option: course_option,
      )]
    end

    it_behaves_like(
      'a mail with subject and content',
      'You’ve accepted Arithmetic College’s offer to study Mathematics (M101)',
      'greeting' => 'Dear Fred',
      'offer_details' => 'You’ve accepted Arithmetic College’s offer to study Mathematics (M101)',
      'course start' => 'September 2021',
    )
  end

  context 'Interview emails' do
    let(:provider) { create(:provider, name: 'Hogwards') }
    let(:application_choice_with_interview) { build_stubbed(:application_choice, course_option:) }

    let(:interview) do
      build_stubbed(:interview,
                    date_and_time: Time.zone.local(2021, 1, 15, 9, 30),
                    location: 'Hogwarts Castle',
                    additional_details: 'Bring your magic wand for the spells test',
                    provider:,
                    application_choice: application_choice_with_interview)
    end

    before do
      build_stubbed(:application_form,
                    first_name: 'Fred',
                    candidate:,
                    application_choices: [application_choice_with_interview])
    end

    describe '.new_interview' do
      let(:email) { mailer.new_interview(application_choice_with_interview, interview) }

      it_behaves_like(
        'a mail with subject and content',
        'Interview arranged for Mathematics (M101)',
        'greeting' => 'Dear Fred',
        'details' => 'Hogwards has arranged an interview with you for Mathematics (M101).',
        'interview date' => '15 January 2021',
        'interview time' => '9:30am',
        'interview location' => 'Hogwarts Castle',
        'additional interview details' => 'Bring your magic wand for the spells test',
        'TTA header' => 'Prepare for your interview',
        'TTA content' => 'Do you have a teacher training adviser yet?',
        'TTA link' => 'Get a teacher training adviser',
      )
    end

    describe '.interview_updated' do
      let(:previous_course) { create(:course, name: 'Geography', code: 'G100') }

      let(:email) { mailer.interview_updated(application_choice_with_interview, interview, previous_course) }

      context 'when the course has been updated' do
        it_behaves_like(
          'a mail with subject and content',
          'Interview details updated for Geography (G100)',
          'greeting' => 'Dear Fred',
          'details' => 'The details of your interview for Geography (G100) have been updated.',
          'interview with new course details' => 'The interview is with Hogwards.',
          'new course' => 'It’s now for Mathematics (M101).',
          'interview date' => '15 January 2021',
          'interview time' => '9:30am',
          'interview location' => 'Hogwarts Castle',
          'additional interview details' => 'Bring your magic wand for the spells test',
        )
      end

      context 'when course is not changed and previous course is nil' do
        let(:previous_course) { nil }
        let(:email) { mailer.interview_updated(application_choice_with_interview, interview, previous_course) }

        it 'the email does not contain any new course details' do
          expect(email.body).not_to include('It’s now for Mathematics (M101).')
        end
      end

      context 'when additional details is nil' do
        it 'the email does not contain any additional details' do
          interview.additional_details = nil
          expect(email.body).not_to include('Bring your magic wand for the spells test')
          expect(email.body).not_to include('Additional details:')
        end
      end
    end

    describe '.interview_cancelled' do
      let(:email) { mailer.interview_cancelled(application_choice_with_interview, interview, 'We recruited someone else') }

      it_behaves_like(
        'a mail with subject and content',
        'Interview cancelled - Hogwards',
        'greeting' => 'Dear Fred',
        'details' => 'Hogwards has cancelled your interview on 15 January 2021 at 9:30am',
        'cancellation reason' => 'We recruited someone else',
      )
    end
  end

  describe '.change_course' do
    let(:application_choice) do
      create(
        :application_choice,
        original_course_option:,
        course_option: current_course_option,
        current_course_option:,
        site:,
        application_form: create(:application_form, first_name: 'Fred'),
      )
    end
    let(:email) { mailer.change_course(application_choice, original_course_option) }
    let(:original_course_option) do
      create(
        :course_option,
        course: create(
          :course,
          name: 'Mathematics',
          code: 'M101',
        ),
      )
    end
    let(:current_course_option) do
      create(
        :course_option,
        course: create(
          :course,
          :part_time,
          name: 'Geography',
          code: 'H234',
          provider:,
        ),
        site:,
      )
    end
    let(:site) do
      create(:site,
             name: 'First Road',
             code: 'F34',
             address_line1: 'Fountain Street',
             address_line2: 'Morley',
             address_line3: 'Leeds',
             postcode: 'LS27 OPD',
             provider:)
    end

    let(:provider) do
      create(:provider,
             name: 'Best Training',
             code: 'B54')
    end

    it_behaves_like(
      'a mail with subject and content',
      'Course details changed for Mathematics (M101)',
      'greeting' => 'Dear Fred',
      'old course' => 'The details of your application to study Mathematics (M101) have been changed',
      'new details' => 'The new details are:',
      'provider' => 'Training provider: Best Training',
      'course' => 'Course: Geography (H234)',
      'location' => 'Location: First Road',
      'study mode' => 'Full time or part time: Part time',
    )
  end

  describe '.deadline_reminder' do
    context 'when a candidate is in Apply 1' do
      let(:email) { mailer.eoc_deadline_reminder(application_form) }
      let(:application_form) { build_stubbed(:application_form, phase: 'apply_1', first_name: 'Fred') }

      it_behaves_like(
        'a mail with subject and content',
        'Submit your teacher training application before courses fill up',
        'heading' => 'Dear Fred',
        'cycle_details' => "as soon as you can to get on a course starting in the #{RecruitmentCycle.current_year} to #{RecruitmentCycle.next_year} academic year.",
        'details' => "The deadline to submit your application is 6pm on #{CycleTimetable.apply_1_deadline.to_fs(:govuk_date)}",
      )
    end

    context 'when a candidate is in Apply 2' do
      let(:email) { mailer.eoc_deadline_reminder(application_form) }
      let(:application_form) { build_stubbed(:application_form, phase: 'apply_2', first_name: 'Fred') }

      it_behaves_like(
        'a mail with subject and content',
        'Submit your teacher training application before courses fill up',
        'heading' => 'Dear Fred',
        'cycle_details' => "as soon as you can to get on a course starting in the #{RecruitmentCycle.current_year} to #{RecruitmentCycle.next_year} academic year.",
        'details' => "The deadline to submit your application is 6pm on #{CycleTimetable.apply_2_deadline.to_fs(:govuk_date)}",
      )
    end

    context 'when a candidate has not provided a first name' do
      let(:email) { mailer.eoc_deadline_reminder(application_form) }
      let(:application_form) { build_stubbed(:application_form, first_name: nil) }

      it 'does not include a `Dear` heading' do
        expect(email.body).not_to include('Dear')
      end
    end
  end

  describe '.new_cycle_has_started', time: mid_cycle do
    context "when the candidate's application was unsubmitted" do
      let(:application_form) { build_stubbed(:application_form, first_name: 'Fred', submitted_at: nil) }
      let(:email) { mailer.new_cycle_has_started(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        "Apply for teacher training starting in the #{CycleTimetable.current_year} to #{CycleTimetable.next_year} academic year",
        'greeting' => 'Dear Fred',
        'academic_year' => "#{CycleTimetable.current_year} to #{CycleTimetable.next_year}",
        'details' => 'Courses can fill up quickly, so apply as soon as you’re ready.',
      )
    end

    context "when the candidate's application was unsuccessful" do
      let(:application_choice) { build_stubbed(:application_choice, :rejected) }
      let(:application_form) { build_stubbed(:application_form, first_name: 'Fred', application_choices: [application_choice]) }
      let(:email) { mailer.new_cycle_has_started(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        "Apply for teacher training starting in the #{CycleTimetable.current_year} to #{CycleTimetable.next_year} academic year",
        'greeting' => 'Dear Fred',
        'academic_year' => "#{CycleTimetable.current_year} to #{CycleTimetable.next_year}",
        'details' => 'Training providers offer places on courses as people apply throughout the year. Courses stay open until they are full.',
      )
    end

    context 'when a candidate has not provided a first name' do
      let(:email) { mailer.new_cycle_has_started(application_form) }
      let(:application_form) { build_stubbed(:application_form, first_name: nil) }

      it 'does not include a `Dear` heading' do
        expect(email.body).not_to include('Dear')
      end
    end
  end

  describe '.find_has_opened', time: after_find_opens do
    context "when the candidate's application was unsubmitted" do
      let(:application_form) { build_stubbed(:application_form, first_name: 'Fred', submitted_at: nil) }
      let(:email) { mailer.find_has_opened(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'Find your teacher training course now',
        'greeting' => 'Dear Fred',
        'academic_year' => "#{CycleTimetable.current_year} to #{CycleTimetable.next_year}",
        'details' => 'Find your courses',
      )
    end

    context 'when a candidate has not provided a first name' do
      let(:email) { mailer.find_has_opened(application_form) }
      let(:application_form) { build_stubbed(:application_form, first_name: nil) }

      it 'does not include a `Dear` heading' do
        expect(email.body).not_to include('Dear')
      end
    end
  end

  describe '.duplicate_match_email' do
    context 'when the candidate has a duplicate account regardless of whether it is submitted or unsubmitted' do
      let(:application_form) { build_stubbed(:application_form, :minimum_info, first_name: 'Fred') }
      let(:email) { mailer.duplicate_match_email(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'You created more than one account to apply for teacher training',
        'greeting' => 'Dear Fred',
        'details' => 'You created more than one account to apply for teacher training. Your accounts have been locked.',
      )
    end
  end

  describe '.nudge_unsubmitted' do
    let(:application_form) { build_stubbed(:application_form, :minimum_info, first_name: 'Fred') }
    let(:email) { mailer.nudge_unsubmitted(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Get last-minute advice about your teacher training application',
      'greeting' => 'Dear Fred',
    )
  end

  describe '.nudge_unsubmitted_with_incomplete_references' do
    context 'when the references section has not been completed' do
      let(:application_form) { build_stubbed(:application_form, :minimum_info, first_name: 'Fred') }
      let(:email) { mailer.nudge_unsubmitted_with_incomplete_references(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'Give details of 2 people who can give references',
        'greeting' => 'Hello Fred',
        'content' => 'You have not completed the references section of your teacher training application yet',
      )
    end
  end

  describe '.nudge_unsubmitted_with_incomplete_courses' do
    let(:application_form) { build_stubbed(:application_form, :minimum_info, first_name: 'Fred') }
    let(:email) { mailer.nudge_unsubmitted_with_incomplete_courses(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Get help choosing a teacher training course',
      'greeting' => 'Hello Fred',
    )
  end

  describe 'click-tracking' do
    let(:application_form) { build_stubbed(:application_form, :minimum_info, first_name: 'Fred') }
    let(:email) { mailer.nudge_unsubmitted(application_form) }

    before { allow(EmailLogInterceptor).to receive(:generate_reference).and_return('fake-ref-123') }

    it 'adds header to email containing notify reference' do
      expect(email.header[:reference]&.value).to eq('fake-ref-123')
    end

    it 'appends the notify reference as a `utm_source` url param on links within the email body' do
      expect(email.body).to include('utm_source=fake-ref-123')
    end
  end

  describe 'utm parameters' do
    let(:application_form) { build_stubbed(:application_form, :minimum_info, first_name: 'Fred', phase: 'apply_1') }
    let(:email) { mailer.eoc_deadline_reminder(application_form) }

    it 'adds utm parameters to GIT links within email body in production' do
      allow(HostingEnvironment).to receive(:environment_name).and_return('production')

      expect(email.body).to include('utm_source=apply-for-teacher-training.service.gov.uk')
      expect(email.body).to include('utm_medium=referral')
      expect(email.body).to include('utm_campaign=eoc_deadline_reminder')
      expect(email.body).to include('utm_content=apply_1')
    end
  end
end
