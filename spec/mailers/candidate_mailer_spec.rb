require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  include TestHelpers::MailerSetupHelper

  subject(:mailer) { described_class }

  let(:application_form) do
    build_stubbed(:application_form, first_name: 'Fred',
                                     candidate: candidate,
                                     application_choices: application_choices)
  end
  let(:candidate) { build_stubbed(:candidate) }
  let(:application_choices) { [build_stubbed(:application_choice)] }
  let(:dbd_application) { build_stubbed(:application_choice, :dbd) }
  let(:course_option) do
    build_stubbed(
      :course_option,
      course: build_stubbed(
        :course,
        name: 'Mathematics',
        code: 'M101',
        start_date: Time.zone.local(2021, 9, 6),
        provider: build_stubbed(
          :provider,
          name: 'Arithmetic College',
        ),
      ),
    )
  end

  before do
    magic_link_stubbing(candidate)
  end

  describe '.application_submitted' do
    let(:application_choice) { build_stubbed(:application_choice, reject_by_default_at: 5.days.from_now) }
    let(:application_form) {
      build_stubbed(:application_form, first_name: 'Jimbo',
                                       candidate: candidate,
                                       application_choices: [application_choice])
    }
    let(:email) { mailer.application_submitted(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.application_submitted.subject'),
      'intro' => 'You’ve submitted an application for',
      'magic link to authenticate' => 'http://localhost:3000/candidate/sign-in/confirm?token=raw_token',
      'dynamic paragraph' => 'Your training provider will be in touch if they would like to organise an interview',
      'reject_by_default date' => 5.days.from_now.to_fs(:govuk_date),
    )
  end

  describe 'Candidate decision chaser email' do
    let(:email) { mailer.chase_candidate_decision(application_form) }
    let(:offer) do
      build_stubbed(:application_choice, :with_offer,
                    sent_to_provider_at: Time.zone.today,
                    course_option: course_option)
    end
    let(:course_option) do
      build_stubbed(:course_option, course: build_stubbed(:course,
                                                          name: 'Applied Science (Psychology)',
                                                          code: '3TT5', provider: provider))
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
        build_stubbed(:application_choice, :with_offer,
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
          allow(CycleTimetable).to receive(:between_cycles_apply_2?).and_return(true)
          allow(CycleTimetable).to receive(:apply_opens).and_return(Date.new(2021, 10, 13))
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
    let(:email) { mailer.withdraw_last_application_choice(application_form) }

    context 'when a candidate has 1 course choice that was withdrawn' do
      let(:application_choices) { [build_stubbed(:application_choice, status: 'withdrawn')] }

      it_behaves_like(
        'a mail with subject and content',
        'You’ve withdrawn your application: next steps',
        'heading' => 'Dear Fred',
        'application_withdrawn' => 'You’ve withdrawn your application',
      )
    end

    context 'when a candidate has 2 or 3 offers that were declined' do
      let(:application_choices) { [build_stubbed(:application_choice, :withdrawn), build_stubbed(:application_choice, :withdrawn)] }

      it_behaves_like(
        'a mail with subject and content',
        'You’ve withdrawn your applications: next steps',
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
    let(:email) { described_class.chase_reference_again(referee) }
    let(:referee) { build_stubbed(:reference, name: 'Jolyne Doe', application_form: application_form) }
    let(:application_choices) { [] }

    it_behaves_like(
      'a mail with subject and content',
      'Jolyne Doe has not responded yet',
      'magic_link' => '/candidate/sign-in/confirm?token=raw_token',
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
        course_option: course_option,
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
    let(:email) { described_class.offer_accepted(application_form.application_choices.first) }
    let(:application_choices) do
      [build_stubbed(
        :application_choice,
        status: 'pending_conditions',
        course_option: course_option,
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

  describe '.conditions_statuses_changed' do
    let(:met_conditions) { [build_stubbed(:offer_condition, text: 'Do a cool trick')] }
    let(:pending_conditions) { [build_stubbed(:offer_condition, text: 'Go to the moon')] }
    let(:previously_met_conditions) { [build_stubbed(:offer_condition, text: 'Evidence of degree')] }
    let(:email) do
      described_class.conditions_statuses_changed(
        application_form.application_choices.first,
        met_conditions,
        pending_conditions,
        previously_met_conditions,
      )
    end
    let(:application_choices) do
      [build_stubbed(:application_choice, status: 'pending_conditions', course_option: course_option, current_course_option: course_option)]
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
    let(:offer) do
      build_stubbed(:application_choice, :with_offer,
                    sent_to_provider_at: Time.zone.today,
                    course_option: course_option)
    end
    let(:application_choices) { [offer] }
    let(:email) do
      described_class.reinstated_offer(
        application_form.application_choices.first,
      )
    end

    it_behaves_like(
      'a mail with subject and content',
      'Your deferred offer has been confirmed',
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
        course_option: course_option,
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
    let(:application_choice_with_interview) { build_stubbed(:application_choice, course_option: course_option) }

    let(:interview) do
      build_stubbed(:interview,
                    date_and_time: Time.zone.local(2021, 1, 15, 9, 30),
                    location: 'Hogwarts Castle',
                    additional_details: 'Bring your magic wand for the spells test',
                    provider: provider,
                    application_choice: application_choice_with_interview)
    end

    before do
      build_stubbed(:application_form,
                    first_name: 'Fred',
                    candidate: candidate,
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
      )
    end

    describe '.interview_updated' do
      let(:email) { mailer.interview_updated(application_choice_with_interview, interview) }

      it_behaves_like(
        'a mail with subject and content',
        'Interview details updated for Mathematics (M101)',
        'greeting' => 'Dear Fred',
        'details' => 'The details of your interview for Mathematics (M101) have been updated.',
        'interview date' => '15 January 2021',
        'interview time' => '9:30am',
        'interview location' => 'Hogwarts Castle',
        'additional interview details' => 'Bring your magic wand for the spells test',
      )
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
        original_course_option: original_course_option,
        course_option: current_course_option,
        current_course_option: current_course_option,
        site: site,
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
          provider: provider,
        ),
        site: site,
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
             provider: provider)
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

  describe '.new_cycle_has_started' do
    Timecop.freeze(2021, 10, 12) do
      context "when the candidate's application was unsubmitted" do
        let(:application_form) { build_stubbed(:application_form, first_name: 'Fred', submitted_at: nil) }
        let(:email) { mailer.new_cycle_has_started(application_form) }

        it_behaves_like(
          'a mail with subject and content',
          'Teacher training applications are open - apply for the 2022 to 2023 academic year',
          'greeting' => 'Dear Fred',
          'academic_year' => '2022 to 2023',
          'details' => 'Applications are now open',
        )
      end

      context "when the candidate's application was unsuccessful" do
        let(:application_choice) { build_stubbed(:application_choice, :with_rejection) }
        let(:application_form) { build_stubbed(:application_form, first_name: 'Fred', application_choices: [application_choice]) }
        let(:email) { mailer.new_cycle_has_started(application_form) }

        it_behaves_like(
          'a mail with subject and content',
          'Teacher training applications are open - apply for the 2022 to 2023 academic year',
          'greeting' => 'Dear Fred',
          'academic_year' => '2022 to 2023',
          'details' => 'Applications are now open - apply for teacher training again.',
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
  end

  describe '.find_has_opened' do
    Timecop.freeze(2021, 10, 12) do
      context "when the candidate's application was unsubmitted" do
        let(:application_form) { build_stubbed(:application_form, first_name: 'Fred', submitted_at: nil) }
        let(:email) { mailer.find_has_opened(application_form) }

        it_behaves_like(
          'a mail with subject and content',
          'Find your teacher training course now',
          'greeting' => 'Dear Fred',
          'academic_year' => '2022 to 2023',
          'details' => 'Find your courses:',
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
  end

  describe '.duplicate_match_email' do
    context 'when the candidate has submitted applications' do
      let(:application_form) { build_stubbed(:application_form, :minimum_info, first_name: 'Fred') }
      let(:email) { mailer.duplicate_match_email(application_form, true) }

      it_behaves_like(
        'a mail with subject and content',
        'Duplicate application detected',
        'greeting' => 'Dear Fred',
        'details' => 'You’ve created more than one account on Apply for teacher training.',
        'dynamic content' => 'As you have already submitted an application, the account with the unsubmitted application will be locked.',
      )
    end

    context 'when the candidate has not submitted any applications' do
      let(:application_form) { build_stubbed(:application_form, first_name: 'Fred') }
      let(:email) { mailer.duplicate_match_email(application_form, false) }

      it_behaves_like(
        'a mail with subject and content',
        'Duplicate application detected',
        'greeting' => 'Dear Fred',
        'details' => 'You’ve created more than one account on Apply for teacher training.',
        'dynamic content' => 'Your access to the account you set up most recently will be removed.',
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
    context 'with no references at all' do
      let(:application_form) { build_stubbed(:application_form, :minimum_info, first_name: 'Fred') }
      let(:email) { mailer.nudge_unsubmitted_with_incomplete_references(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'Get 2 references to submit your teacher training application',
        'greeting' => 'Dear Fred',
        'content' => 'You have not requested your teacher training references yet.',
      )
    end

    context 'with 1 requested reference' do
      let(:application_form) do
        create(
          :application_form,
          :minimum_info,
          first_name: 'Fred',
          application_references: [create(:reference, :feedback_requested)],
        )
      end
      let(:email) { mailer.nudge_unsubmitted_with_incomplete_references(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'Request another reference for your teacher training application',
        'greeting' => 'Dear Fred',
        'content' => 'You’ve requested one of your teacher training references.',
      )
    end

    context 'with 1 received reference' do
      let(:application_form) do
        create(
          :application_form,
          :minimum_info,
          first_name: 'Fred',
          application_references: [create(:reference, :feedback_provided)],
        )
      end
      let(:email) { mailer.nudge_unsubmitted_with_incomplete_references(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'Request another reference for your teacher training application',
        'greeting' => 'Dear Fred',
        'content' => 'You’ve received a teacher training reference, but you’ll need one more before you can submit your application.',
      )
    end
  end

  describe '.nudge_unsubmitted_with_incomplete_courses' do
    let(:application_form) { build_stubbed(:application_form, :minimum_info, first_name: 'Fred') }
    let(:email) { mailer.nudge_unsubmitted_with_incomplete_courses(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Get help choosing a teacher training course',
      'greeting' => 'Dear Fred',
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
end
