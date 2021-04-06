require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  include TestHelpers::MailerSetupHelper

  subject(:mailer) { described_class }

  let(:candidate) { build_stubbed(:candidate) }
  let!(:application_form) { build_stubbed(:application_form, first_name: 'Bob', candidate: candidate, application_choices: application_choices) }
  let(:provider) { build_stubbed(:provider, name: 'Brighthurst Technical College') }
  let(:course) { build_stubbed(:course, name: 'Applied Science (Psychology)', code: '3TT5', provider: provider) }
  let(:current_course) { build_stubbed(:course, name: 'Primary', code: '33WA', provider: other_provider) }
  let(:course_option) { build_stubbed(:course_option, course: course) }
  let(:current_course_option) { build_stubbed(:course_option, course: current_course) }

  let(:other_provider) { build_stubbed(:provider, name: 'Falconholt Technical College', code: 'X100') }
  let(:other_course) { build_stubbed(:course, name: 'Forensic Science', code: 'E0FO', provider: other_provider) }
  let(:site) { build_stubbed(:site, name: 'Aquaria') }
  let(:other_option) { build_stubbed(:course_option, course: other_course, site: site) }

  let(:offer) { build_stubbed(:application_choice, :with_offer, course_option: course_option) }
  let(:awaiting_decision) { build_stubbed(:application_choice, :awaiting_provider_decision, course_option: other_option, current_course_option: other_option) }
  let(:interviewing) { build_stubbed(:application_choice, :awaiting_provider_decision, status: :interviewing, course_option: other_option, current_course_option: other_option) }

  let(:application_choices) { [] }

  before do
    magic_link_stubbing(candidate)
  end

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe '.new_offer_single_offer' do
    let(:email) { mailer.new_offer_single_offer(application_choices.first) }
    let(:application_choices) { [offer] }

    before do
      allow(CourseOption).to receive(:find_by).with(id: offer.current_course_option_id).and_return(offer.current_course_option)
    end

    it_behaves_like(
      'a mail with subject and content',
      'Make a decision: successful application for Brighthurst Technical College',
      'heading' => 'Dear Bob',
      'decline by default date' => "Make a decision by #{10.business_days.from_now.to_s(:govuk_date)}",
      'first_condition' => 'Be cool',
      'deferral_guidance' => 'Some teacher training providers allow you to defer your offer.',
    )

    context 'when the provider offers the candidate a different course option' do
      let(:other_course) { build_stubbed(:course, name: 'Computer Science', code: 'X0FO', provider: other_provider) }
      let(:other_option) { build_stubbed(:course_option, course: other_course) }
      let(:offer) { build_stubbed(:application_choice, :with_offer, current_course_option_id: other_option.id, course_option: course_option, current_course_option: other_option) }

      it_behaves_like(
        'a mail with subject and content',
        'Make a decision: successful application for Falconholt Technical College',
        'heading' => 'Dear Bob',
        'course and provider' => 'offer from Falconholt Technical College to study Computer Science (X0FO)',
        'decline by default date' => "Make a decision by #{10.business_days.from_now.to_s(:govuk_date)}",
        'deferral_guidance' => 'Some teacher training providers allow you to defer your offer.',
      )
    end
  end

  describe '.new_offer_multiple_offers' do
    let(:email) { mailer.new_offer_multiple_offers(application_choices.first) }
    let(:other_offer) { build_stubbed(:application_choice, :with_offer, course_option: other_option) }
    let(:application_choices) { [offer, other_offer] }

    it_behaves_like(
      'a mail with subject and content',
      'Make a decision: successful application for Brighthurst Technical College',
      'heading' => 'Dear Bob',
      'decline by default date' => "Make a decision by #{10.business_days.from_now.to_s(:govuk_date)}",
      'first_condition' => 'Be cool',
      'first_offer' => 'Applied Science (Psychology) (3TT5) at Brighthurst Technical College',
      'second_offers' => 'Forensic Science (E0FO) at Falconholt Technical College',
      'deferral_guidance' => 'Some teacher training providers allow you to defer your offer.',
    )
  end

  describe '.new_offer_decisions_pending' do
    let(:email) { mailer.new_offer_decisions_pending(application_choices.first) }
    let(:application_choices) { [offer, awaiting_decision] }

    it_behaves_like(
      'a mail with subject and content',
      'Successful application for Brighthurst Technical College',
      'heading' => 'Dear Bob',
      'first_condition' => 'Be cool',
      'instructions' => 'You can wait to hear back about your other application(s) before making a decision',
      'deferral_guidance' => 'Some teacher training providers allow you to defer your offer.',
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

    let(:rejected) { build_stubbed(:application_choice, status: :rejected, course_option: other_option, current_course_option: other_option, structured_rejection_reasons: rejection_reasons) }

    describe '.application_rejected_all_applications_rejected' do
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
    end

    describe '.application_rejected_one_offer_one_awaiting_decision' do
      let(:email) { mailer.application_rejected_one_offer_one_awaiting_decision(application_choices.first) }

      context 'with an awaiting decision application' do
        let(:application_choices) { [rejected, offer, awaiting_decision] }

        it_behaves_like(
          'a mail with subject and content',
          I18n.t!('candidate_mailer.application_rejected_one_offer_one_awaiting_decision.subject',
                  provider_name: 'Brighthurst Technical College'),
          'heading' => 'Dear Bob',
          'course name and code' => 'Applied Science (Psychology)',
          'qualifications rejection heading' => 'Qualifications',
          'qualifications rejection content' => 'Bad qualifications',
          'other application details' => 'You have an offer and are waiting for a decision about another course',
          'application with offer' => 'You have an offer from Brighthurst Technical College to study Applied Science (Psychology)',
          'application awaiting decision' => 'to make a decision about your application to study Forensic Science',
          'decision day' => "has until #{40.business_days.from_now.to_s(:govuk_date)} to make a decision",
        )
      end

      context 'with an interviewing application' do
        let(:application_choices) { [rejected, offer, interviewing] }

        it_behaves_like(
          'a mail with subject and content',
          I18n.t!('candidate_mailer.application_rejected_one_offer_one_awaiting_decision.subject',
                  provider_name: 'Brighthurst Technical College'),
          'heading' => 'Dear Bob',
          'course name and code' => 'Applied Science (Psychology)',
          'qualifications rejection heading' => 'Qualifications',
          'qualifications rejection content' => 'Bad qualifications',
          'other application details' => 'You have an offer and are waiting for a decision about another course',
          'application with offer' => 'You have an offer from Brighthurst Technical College to study Applied Science (Psychology)',
          'application awaiting decision' => 'to make a decision about your application to study Forensic Science',
          'decision day' => "has until #{40.business_days.from_now.to_s(:govuk_date)} to make a decision",
        )
      end
    end

    describe '.application_rejected_awaiting_decision_only' do
      let(:email) { mailer.application_rejected_awaiting_decision_only(application_choices.first) }
      let(:application_choices) { [rejected, awaiting_decision, interviewing] }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.application_rejected_awaiting_decision_only.subject'),
        'heading' => 'Dear Bob',
        'course name and code' => 'Forensic Science (E0FO)',
        'rejection reasons' => 'Bad qualifications',
        'other application details' => "You're waiting for decisions",
        'first application' => 'Falconholt Technical College to study Forensic Science',
        'decision day' => "They should make their decisions by #{40.business_days.from_now.to_s(:govuk_date)}",
      )
    end

    describe '.application_rejected_offers_only' do
      let(:email) { mailer.application_rejected_offers_only(application_choices.first) }
      let(:application_choices) { [rejected, offer, offer] }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.application_rejected_offers_only.subject', date: 10.business_days.from_now.to_s(:govuk_date)),
        'heading' => 'Dear Bob',
        'course name and code' => 'Forensic Science (E0FO)',
        'rejection reasons' => 'Do not refer to yourself in the third person',
        'other application details' => 'You’re not waiting for any other decisions.',
        'first application details' => 'Brighthurst Technical College to study Applied Science (Psychology)',
        'respond by date' => "The offers will automatically be withdrawn if you do not respond by #{10.business_days.from_now.to_s(:govuk_date)}",
      )
    end
  end

  describe 'feedback_received_for_application_rejected_by_default' do
    let(:email) { mailer.feedback_received_for_application_rejected_by_default(application_choices.first) }
    let(:application_choices) { [build_stubbed(:application_choice, :with_rejection_by_default_and_feedback, course_option: course_option, current_course_option: course_option, rejection_reason: 'I\'m so happy')] }

    it_behaves_like(
      'a mail with subject and content',
      'Feedback on your application for Brighthurst Technical',
      'heading' => 'Dear Bob',
      'provider name' => 'Brighthurst Technical College did not respond in time',
      'name and code for course' => 'Applied Science (Psychology) (3TT5)',
      'feedback' => 'I\'m so happy',
    )
  end

  describe '.deferred_offer' do
    let(:email) { mailer.deferred_offer(application_choices.first) }
    let(:application_choices) { [offer] }

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
    let(:application_choice) { build_stubbed(:application_choice, :with_deferred_offer, course_option: other_option, current_course_option: other_option, offer_deferred_at: Time.zone.local(2019, 10, 3)) }
    let(:other_course) do
      build_stubbed :course, name: 'Forensic Science',
                             code: 'E0FO',
                             provider: other_provider,
                             start_date: Time.zone.local(2020, 6, 5)
    end

    before do
      magic_link_stubbing(application_form.candidate)
    end

    it_behaves_like(
      'a mail with subject and content',
      'You’re due to take up your deferred offer',
      'heading' => 'Dear Bob',
      'provider name' => 'You have an offer from Falconholt Technical College',
      'name and code for course' => 'Forensic Science (E0FO)',
      'start date of new course' => 'June 2020',
      'date offer was deferred' => 'This was deferred from last year (October 2019)',
    )

    describe 'with pending conditions' do
      it_behaves_like(
        'a mail with subject and content',
        'You’re due to take up your deferred offer',
        'heading' => 'Dear Bob',
        'provider name' => 'You have an offer from Falconholt Technical College',
        'name and code for course' => 'Forensic Science (E0FO)',
        'start date of new course' => 'June 2020',
        'date offer was deferred' => 'This was deferred from last year (October 2019)',
        'conditions of offer' => 'Be cool',
      )
    end
  end

  describe '.changed_offer' do
    let(:email) { mailer.changed_offer(application_choices.first) }
    let(:application_choice) { build_stubbed(:submitted_application_choice, course_option: course_option, current_course_option: other_option, decline_by_default_at: 10.business_days.from_now) }
    let(:application_choices) { [application_choice] }

    it_behaves_like(
      'a mail with subject and content',
      'Brighthurst Technical College',
      'heading' => 'Dear Bob',
      'name and code for original course' => 'Applied Science (Psychology) (3TT5)',
      'name and code for new course' => 'Course: Forensic Science (E0FO)',
      'name of new provider' => 'Provider: Falconholt Technical College',
      'location of new offer' => 'Location: Aquaria',
      'study mode of new offer' => 'Full time',
    )
  end

  describe 'Deferred offer reminder email' do
    let(:email) { mailer.deferred_offer_reminder(application_choices.first) }
    let(:application_choice) { build_stubbed(:application_choice, :with_deferred_offer, course_option: other_option, current_course_option: other_option, offer_deferred_at: Time.zone.local(2020, 4, 15)) }
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
