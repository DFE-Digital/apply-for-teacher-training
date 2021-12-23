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
      'intro' => 'You have submitted an application for',
      'magic link to authenticate' => 'http://localhost:3000/candidate/sign-in/confirm?token=raw_token',
      'dynamic paragraph' => 'If your training provider decides to progress your application',
      'reject_by_default date' => 5.days.from_now.to_s(:govuk_date),
    )
  end

  describe '.application_submitted_apply_again' do
    let(:application_choice) { build_stubbed(:application_choice, reject_by_default_at: 5.days.from_now) }
    let(:application_form) {
      build_stubbed(:application_form, first_name: 'Olaji',
                                       candidate: candidate,
                                       application_choices: [application_choice])
    }
    let(:email) { mailer.application_submitted_apply_again(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.application_submitted_apply_again.subject'),
      'intro' => 'You have submitted an application for',
      'magic link to authenticate' => 'http://localhost:3000/candidate/sign-in/confirm?token=raw_token',
      'dynamic paragraph' => 'If your training provider decides to progress your application',
      'reject_by_default date' => 5.days.from_now.to_s(:govuk_date),
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
        'dbd date' => "respond by #{10.business_days.from_now.to_s(:govuk_date)}",
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

  describe '#apply_again_call_to_action' do
    let(:email) { described_class.apply_again_call_to_action(application_form) }
    let(:application_choices) { [build_stubbed(:application_choice, status: :rejected)] }

    it_behaves_like(
      'a mail with subject and content',
      'You can still apply for teacher training',
      'content' => 'You can apply for teacher training again if you have not got a place yet',
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
      'greeting' => 'Dear Fred,',
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
      'greeting' => 'Dear Fred,',
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
      'greeting' => 'Dear Fred,',
      'offer_details' => 'You’ve accepted Arithmetic College’s offer to study Mathematics (M101)',
      'course start' => 'September 2021',
    )
  end

  context 'Interview emails' do
    let(:provider)  { create(:provider, name: 'Hogwards') }
    let(:interview) do
      create(:interview,
             date_and_time: Time.zone.local(2021, 1, 15, 9, 30),
             location: 'Hogwarts Castle',
             additional_details: 'Bring your magic wand for the spells test',
             provider: provider)
    end
    let(:application_choice_with_interview) { interview.application_choice }

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
        'Interview arranged - Hogwards',
        'greeting' => 'Dear Fred,',
        'details' => 'You have an interview with Hogwards',
        'interview date and time' => '15 January 2021 at 9:30am',
        'interview location' => 'Hogwarts Castle',
        'additional interview details' => 'Bring your magic wand for the spells test',
      )
    end

    describe '.interview_updated' do
      let(:email) { mailer.interview_updated(application_choice_with_interview, interview) }

      it_behaves_like(
        'a mail with subject and content',
        'Interview details updated - Hogwards',
        'greeting' => 'Dear Fred,',
        'details' => 'Hogwards has updated the details of the interview',
        'interview date and time' => '15 January 2021 at 9:30am',
        'interview location' => 'Hogwarts Castle',
        'additional interview details' => 'Bring your magic wand for the spells test',
      )
    end

    describe '.interview_cancelled' do
      let(:email) { mailer.interview_cancelled(application_choice_with_interview, interview, 'We recruited someone else') }

      it_behaves_like(
        'a mail with subject and content',
        'Interview cancelled - Hogwards',
        'greeting' => 'Dear Fred,',
        'details' => 'Hogwards has cancelled the interview on 15 January 2021 at 9:30am',
        'cancellation reason' => 'We recruited someone else',
      )
    end
  end

  describe '.deadline_reminder' do
    context 'when a candidate is in Apply 1' do
      let(:email) { mailer.eoc_deadline_reminder(application_form) }
      let(:application_form) { build_stubbed(:application_form, phase: 'apply_1', first_name: 'Fred') }

      it_behaves_like(
        'a mail with subject and content',
        'Submit your application before courses fill up',
        'heading' => 'Dear Fred',
        'cycle_details' => "Submit your application as soon as you can to get on a course starting in the #{RecruitmentCycle.current_year} to #{RecruitmentCycle.next_year} academic year:",
        'details' => "The deadline to submit your application is 6pm on #{CycleTimetable.apply_1_deadline.to_s(:govuk_date)}",
      )
    end

    context 'when a candidate is in Apply 2' do
      let(:email) { mailer.eoc_deadline_reminder(application_form) }
      let(:application_form) { build_stubbed(:application_form, phase: 'apply_2', first_name: 'Fred') }

      it_behaves_like(
        'a mail with subject and content',
        'Submit your application before courses fill up',
        'heading' => 'Dear Fred',
        'cycle_details' => "Submit your application as soon as you can to get on a course starting in the #{RecruitmentCycle.current_year} to #{RecruitmentCycle.next_year} academic year:",
        'details' => "The deadline to submit your application is 6pm on #{CycleTimetable.apply_2_deadline.to_s(:govuk_date)}",
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
    before do
      allow(CycleTimetable).to receive(:apply_opens).and_return(Date.new(2021, 10, 13))
      allow(CycleTimetable).to receive(:cycle_year_range).and_return('2022 to 2023')
    end

    context "when the candidate's application was unsubmitted" do
      let(:application_form) { build_stubbed(:application_form, first_name: 'Fred', submitted_at: nil) }
      let(:email) { mailer.new_cycle_has_started(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'Teacher training applications are open - apply for the 2022 to 2023 academic year',
        'greeting' => 'Dear Fred,',
        'academic_year' => '2022 to 2023',
        'details' => 'Applications are open - submit your teacher training application',
      )
    end

    context "when the candidate's application was unsuccessful" do
      let(:application_choice) { build_stubbed(:application_choice, :with_rejection) }
      let(:application_form) { build_stubbed(:application_form, first_name: 'Fred', application_choices: [application_choice]) }
      let(:email) { mailer.new_cycle_has_started(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'Teacher training applications are open - apply for the 2022 to 2023 academic year',
        'greeting' => 'Dear Fred,',
        'academic_year' => '2022 to 2023',
        'details' => 'Applications are open - apply for teacher training again',
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

  describe '.find_has_opened' do
    before do
      allow(CycleTimetable).to receive(:apply_opens).and_return(Date.new(2021, 10, 13))
      allow(CycleTimetable).to receive(:cycle_year_range).and_return('2022 to 2023')
    end

    context "when the candidate's application was unsubmitted" do
      let(:application_form) { build_stubbed(:application_form, first_name: 'Fred', submitted_at: nil) }
      let(:email) { mailer.find_has_opened(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'Find your teacher training course now',
        'greeting' => 'Dear Fred,',
        'academic_year' => '2022 to 2023',
        'details' => 'Find your course and get your application ready:',
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

  describe '.fraud_match_email' do
    context "when the candidate's application was unsubmitted" do
      let(:application_form) { build_stubbed(:application_form, first_name: 'Fred') }
      let(:email) { mailer.fraud_match_email(application_form) }

      it_behaves_like(
        'a mail with subject and content',
        'Duplicate application detected',
        'greeting' => 'Dear Fred,',
        'details' => 'We’ve noticed that you’ve started multiple applications on the DfE’s Apply for teacher training.',
      )
    end
  end
end
