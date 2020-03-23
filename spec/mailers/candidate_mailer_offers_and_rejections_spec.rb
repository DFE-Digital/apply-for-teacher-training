require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  include CourseOptionHelpers
  include ViewHelper
  include TestHelpers::MailerSetupHelper

  subject(:mailer) { described_class }

  shared_examples 'a mail with subject and content' do |mail, subject, content|
    let(:email) { described_class.send(mail, @application_choice) }

    it 'sends an email with the correct subject' do
      expect(email.subject).to include(subject)
    end

    content.each do |key, expectation|
      it "sends an email containing the #{key} in the body" do
        expect(email.body).to include(expectation)
      end
    end
  end

  before do
    setup_application
  end

  around do |example|
    Timecop.freeze(Time.zone.local(2020, 2, 11)) do
      example.run
    end
  end

  describe 'send new offer email to candidate' do
    describe '#new_offer_single_offer' do
      it_behaves_like(
        'a mail with subject and content', :new_offer_single_offer,
        'Offer received for Applied Science (Psychology) (3TT5) at Brighthurst Technical College',
        'heading' => 'Dear Bob',
        'decline by default date' => 'Make a decision by 25 February 2020',
        'first_condition' => 'DBS check',
        'second_condition' => 'Pass exams'
      )
    end

    describe '#new_offer_multiple_offers' do
      before do
        provider = build_stubbed(:provider, name: 'Falconholt Technical College')
        other_course_option = build_stubbed(:course_option, course: build_stubbed(:course, name: 'Forensic Science', code: 'E0FO', provider: provider))
        @other_application_choice = @application_form.application_choices.build(
          application_form: @application_form,
          course_option: other_course_option,
          status: :offer,
          offer: { conditions: ['Get a degree'] },
          offered_at: Time.zone.now,
          offered_course_option: other_course_option,
          decline_by_default_at: 5.business_days.from_now,
        )
        @application_form.application_choices = [@application_choice, @other_application_choice]
      end

      it_behaves_like(
        'a mail with subject and content', :new_offer_multiple_offers,
        'Offer received for Applied Science (Psychology) (3TT5) at Brighthurst Technical College',
        'heading' => 'Dear Bob',
        'decline by default date' => 'Make a decision by 25 February 2020',
        'first_condition' => 'DBS check',
        'second_condition' => 'Pass exams',
        'first_offer' => 'Applied Science (Psychology) (3TT5) at Brighthurst Technical College',
        'second_offers' => 'Forensic Science (E0FO) at Falconholt Technical College'
      )
    end

    describe '#new_offer_decisions_pending' do
      before do
        provider = build_stubbed(:provider, name: 'Falconholt Technical College')
        other_course_option = build_stubbed(:course_option, course: build_stubbed(:course, name: 'Forensic Science', code: 'E0FO', provider: provider))
        @other_application_choice = @application_form.application_choices.build(
          application_form: @application_form,
          course_option: other_course_option,
          status: :awaiting_provider_decision,
        )
        @application_form.application_choices = [@application_choice, @other_application_choice]
      end

      it_behaves_like(
        'a mail with subject and content', :new_offer_decisions_pending,
        'Offer received for Applied Science (Psychology) (3TT5) at Brighthurst Technical College',
        'heading' => 'Dear Bob',
        'first_condition' => 'DBS check',
        'second_condition' => 'Pass exams',
        'instructions' => 'You can wait to hear back about your other application(s) before making a decision'
      )
    end
  end

  describe 'application choice rejection emails' do
    def setup_application
      provider = build_stubbed(:provider, name: 'Falconholt Technical College')
      course_option = build_stubbed(:course_option, course: build_stubbed(:course, name: 'Forensic Science', code: 'E0FO', provider: provider))
      @application_form = build_stubbed(:application_form, first_name: 'Tyrell', last_name: 'Wellick')
      @application_choice = @application_form.application_choices.build(
        application_form: @application_form,
        course_option: course_option,
        status: :rejected,
        rejection_reason: 'The application had little detail.',
      )
      @application_form.application_choices = [@application_choice]
    end

    context 'All application choices have been rejected email' do
      it_behaves_like(
        'a mail with subject and content', :application_rejected_all_rejected,
        I18n.t!('candidate_mailer.application_rejected.all_rejected.subject', provider_name: 'Falconholt Technical College'),
        'heading' => 'Dear Tyrell',
        'course name and code' => 'Forensic Science (E0FO)',
        'providers rejection reason' => 'The application had little detail.'
      )
    end

    context 'Application rejected and awaiting further decisions' do
      before do
        provider = build_stubbed(:provider, name: 'Vertapple University')
        course_option = build_stubbed(:course_option, course: build_stubbed(:course, name: 'Law', code: 'UFHG', provider: provider))
        @application_choice_awaiting_provider_decision = @application_form.application_choices.build(
          application_form: @application_form,
          course_option: course_option,
          status: :awaiting_provider_decision,
          rejection_reason: 'The application had little detail.',
        )
      end

      it_behaves_like(
        'a mail with subject and content', :application_rejected_awaiting_decisions,
        I18n.t!('candidate_mailer.application_rejected.awaiting_decisions.subject', provider_name: 'Falconholt Technical College', course_name: 'Forensic Science (E0FO)'),
        'heading' => 'Dear Tyrell',
        'course name and code' => 'Forensic Science (E0FO)',
        'courses they are awaiting decisions' => 'Law (UFHG)',
        'providers they are awaiting decisions' => 'Vertapple University'
      )
    end

    context 'Application rejected and one offer has been made' do
      before do
        FeatureFlag.activate('covid_19')
        provider = build_stubbed(:provider, name: 'Vertapple University')
        course_option = build_stubbed(:course_option, course: build_stubbed(:course, name: 'Law', code: 'UFHG', provider: provider))
        @application_choice_with_offer = @application_form.application_choices.build(
          application_form: @application_form,
          course_option: course_option,
          status: :offer,
          decline_by_default_at: 10.business_days.from_now,
          decline_by_default_days: 10,
        )
      end

      it_behaves_like(
        'a mail with subject and content', :application_rejected_offers_made,
        I18n.t!('candidate_mailer.application_rejected.offers_made.subject', provider_name: 'Falconholt Technical College', dbd_days: 10),
        'heading' => 'Dear Tyrell',
        'course name and code' => 'Forensic Science (E0FO)',
        'other course with an offer ' => 'Law (UFHG)',
        'other provider they got an offer from' => 'Vertapple University',
        'their DBD date' => 'Make a decision about your offer by 25 February 2020',
        'prompt to reply with one offer' => 'You’ve received an offer for a place on',
        'updated covid-19 prompt' => 'If you don’t reply by 25 February 2020 your application will be withdrawn.'
      )
    end

    context 'Application rejected and multiple offers has been made' do
      before do
        FeatureFlag.activate('covid_19')
        setup_application_form_with_two_offers(@application_form)
      end

      it_behaves_like(
        'a mail with subject and content', :application_rejected_offers_made,
        I18n.t!('candidate_mailer.application_rejected.offers_made.subject', provider_name: 'Falconholt Technical College', dbd_days: 10),
        'heading' => 'Dear Tyrell',
        'course name and code' => 'MS Painting (P00)',
        'first course with offer' => 'Code Refactoring (Z00)',
        'first course provider with offer' => 'Wen University',
        'their DBD date' => 'Make a decision about your offers by 25 February 2020',
        'prompt to reply with multiple offers' => 'You’ve received the following offers:',
        'updated covid-19 prompt' => 'If you don’t reply by 25 February 2020 your application will be withdrawn.'
      )
    end
  end

  describe '.changed_offer' do
    before do
      application_form = build_stubbed(:application_form, first_name: 'Tingker Bell')
      provider = build_stubbed(:provider, name: 'Neverland University')
      course_option = build_stubbed(
        :course_option,
        course: build_stubbed(:course, name: 'Flying', code: 'F1Y', provider: provider),
        site: build_stubbed(:site, name: 'Peter School', provider: provider),
      )
      offered_course_option = build_stubbed(
        :course_option,
        course: build_stubbed(:course, name: 'Fighting', code: 'F1G', provider: provider),
        site: build_stubbed(:site, name: 'Pan School', provider: provider),
      )

      @application_choice = build_stubbed(
        :submitted_application_choice,
        course_option: course_option,
        offered_course_option: offered_course_option,
        application_form: application_form,
      )
    end

    it_behaves_like(
      'a mail with subject and content',
      :changed_offer,
      'Neverland University changed the details of your offer',
      'heading' => 'Dear Tingker Bell',
      'previous offer' => 'Flying (F1Y) at Peter School',
      'new offer' => 'Fighting (F1G) at Pan School with Neverland University',
    )
  end
end
