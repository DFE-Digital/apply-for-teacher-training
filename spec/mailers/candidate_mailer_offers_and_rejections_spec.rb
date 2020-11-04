require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  include CourseOptionHelpers
  include TestHelpers::MailerSetupHelper

  subject(:mailer) { described_class }

  shared_examples 'a mail with subject and content' do |mail, subject, content|
    let(:email) { described_class.send(mail, @application_choice) }

    it 'sends an email with the correct subject' do
      expect(email.subject).to include(subject)
    end

    content.each do |key, expectation|
      it "sends an email containing the #{key} in the body" do
        expectation = expectation.call if expectation.respond_to?(:call)
        expect(email.body).to include(expectation)
      end
    end
  end

  before do
    setup_application
    magic_link_stubbing(@application_form.candidate)
  end

  around do |example|
    Timecop.freeze(Time.zone.local(2020, 2, 11)) do
      example.run
    end
  end

  describe '.new_offer_single_offer' do
    it_behaves_like(
      'a mail with subject and content', :new_offer_single_offer,
      'Offer received for Applied Science (Psychology) (3TT5) at Brighthurst Technical College',
      'heading' => 'Dear Bob',
      'decline by default date' => 'Make a decision by 25 February 2020',
      'first_condition' => 'DBS check',
      'second_condition' => 'Pass exams',
      'Days to make an offer' => 'If you do not reply by 25 February 2020',
      'deferral_guidance' => 'Some teacher training providers allow you to defer your offer.'
    )

    context 'when the provider offers the candidate a different course option' do
      before do
        provider = build_stubbed(:provider, name: 'Falconholt Technical College')
        new_course_option = build_stubbed(:course_option, course: build_stubbed(:course, name: 'Forensic Science', code: 'E0FO', provider: provider))

        @application_choice.offered_course_option_id = new_course_option.id

        allow(CourseOption).to receive(:find_by).and_return new_course_option
      end

      it_behaves_like(
        'a mail with subject and content', :new_offer_single_offer,
        'Offer received for Forensic Science (E0FO) at Falconholt Technical College',
        'heading' => 'Dear Bob',
        'decline by default date' => 'Make a decision by 25 February 2020',
        'first_condition' => 'DBS check',
        'second_condition' => 'Pass exams',
        'Days to make an offer' => 'If you do not reply by 25 February 2020',
        'deferral_guidance' => 'Some teacher training providers allow you to defer your offer.'
      )
    end
  end

  describe '.new_offer_multiple_offers' do
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
      'second_offers' => 'Forensic Science (E0FO) at Falconholt Technical College',
      'deferral_guidance' => 'Some teacher training providers allow you to defer your offer.'
    )
  end

  describe '.new_offer_decisions_pending' do
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
      'instructions' => 'You can wait to hear back about your other application(s) before making a decision',
      'deferral_guidance' => 'Some teacher training providers allow you to defer your offer.'
    )
  end

  describe 'rejection emails' do
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

      magic_link_stubbing(@application_form.candidate)
    end

    describe '.application_rejected_all_rejected' do
      it_behaves_like(
        'a mail with subject and content', :application_rejected_all_rejected,
        I18n.t!('candidate_mailer.application_rejected.all_rejected.subject', provider_name: 'Falconholt Technical College'),
        'heading' => 'Dear Tyrell',
        'course name and code' => 'Forensic Science (E0FO)'
      )
    end

    describe '.application_rejected_awaiting_decisions' do
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
  end

  describe '.deferred_offer' do
    before do
      application_form = build_stubbed(:application_form, first_name: 'Harold')
      provider = build_stubbed(:provider, name: 'Jerome Horwitz Elementary School')
      course_option = build_stubbed(
        :course_option,
        course: build_stubbed(:course, name: 'Sport', code: 'SP0', provider: provider, recruitment_cycle_year: 2021),
        site: build_stubbed(:site, provider: provider),
      )

      @application_choice = build_stubbed(
        :application_choice,
        :with_deferred_offer,
        course_option: course_option,
        offered_course_option: course_option,
        application_form: application_form,
        decline_by_default_at: 10.business_days.from_now,
      )

      magic_link_stubbing(application_form.candidate)
    end

    it_behaves_like(
      'a mail with subject and content',
      :deferred_offer,
      'Your offer has been deferred',
      'heading' => 'Dear Harold',
      'name and code for course' => 'Sport (SP0)',
      'name of provider' => 'Jerome Horwitz Elementary School',
      'year of new course' => 'until the next academic year (2022 to 2023)',
    )
  end

  describe '.reinstated_offer' do
    before do
      @application_form = build_stubbed(:application_form, first_name: 'Ron')
      provider = build_stubbed(:provider, name: 'Hogwarts')
      @offered_course_option = build_stubbed(
        :course_option,
        course: build_stubbed(:course, name: 'Potions', code: 'PT5', provider: provider, start_date: Date.new(2020, 9, 15)),
        site: build_stubbed(:site, name: 'The Dungeons', provider: provider),
      )
    end

    describe 'without pending conditions' do
      before do
        @application_choice = build_stubbed(
          :application_choice,
          :with_recruited,
          offered_course_option: @offered_course_option,
          application_form: @application_form,
          decline_by_default_at: 10.business_days.from_now,
          offer_deferred_at: Time.zone.local(2019, 10, 14),
        )

        magic_link_stubbing(@application_form.candidate)
      end

      it_behaves_like(
        'a mail with subject and content',
        :reinstated_offer,
        'You’re due to take up your deferred offer',
        'heading' => 'Dear Ron',
        'provider name' => 'You have an offer from Hogwarts',
        'name and code for course' => 'Potions (PT5)',
        'start date of new course' => 'September 2020',
        'date offer was deferred' => 'This was deferred from last year (October 2019)',
      )
    end

    describe 'with pending conditions' do
      before do
        @application_choice = build_stubbed(
          :application_choice,
          :with_accepted_offer,
          offered_course_option: @offered_course_option,
          application_form: @application_form,
          decline_by_default_at: 10.business_days.from_now,
          offer_deferred_at: Time.zone.local(2019, 10, 14),
        )

        magic_link_stubbing(@application_form.candidate)
      end

      it_behaves_like(
        'a mail with subject and content',
        :reinstated_offer,
        'You’re due to take up your deferred offer',
        'heading' => 'Dear Ron',
        'provider name' => 'You have an offer from Hogwarts',
        'name and code for course' => 'Potions (PT5)',
        'start date of new course' => 'September 2020',
        'date offer was deferred' => 'This was deferred from last year (October 2019)',
        'conditions of offer' => 'Be cool',
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
        decline_by_default_at: 10.business_days.from_now,
      )

      magic_link_stubbing(application_form.candidate)
    end

    it_behaves_like(
      'a mail with subject and content',
      :changed_offer,
      'Offer changed by Neverland University',
      'heading' => 'Dear Tingker Bell',
      'name and code for original course' => 'Flying (F1Y)',
      'name and code for new course' => 'Course: Fighting (F1G)',
      'name of new provider' => 'Provider: Neverland University',
      'location of new offer' => 'Location: Pan School',
      'study mode of new offer' => 'Full time',
    )
  end

  describe 'Deferred offer reminder email' do
    before do
      application_form = build_stubbed(:application_form, first_name: 'Jeff')
      provider = build_stubbed(:provider, name: 'Amazon University')
      course_option = build_stubbed(
        :course_option,
        course: build_stubbed(
          :course,
          name: 'Business',
          code: 'BIZ',
          provider: provider,
          recruitment_cycle_year: RecruitmentCycle.previous_year,
        ),
        site: build_stubbed(:site, provider: provider),
      )

      @application_choice = build_stubbed(
        :application_choice,
        :with_deferred_offer,
        course_option: course_option,
        offered_course_option: course_option,
        application_form: application_form,
        decline_by_default_at: 10.business_days.from_now,
        offer_deferred_at: Time.zone.local(2020, 4, 15, 14),
      )

      magic_link_stubbing(application_form.candidate)
    end

    it_behaves_like(
      'a mail with subject and content', :deferred_offer_reminder,
      I18n.t!('candidate_mailer.deferred_offer_reminder.subject'),
      'heading' => 'Dear Jeff',
      'when offer deferred' => 'On 15 April 2020',
      'provider name' => 'Amazon University',
      'course name and code' => 'Business (BIZ)'
    )
  end
end
