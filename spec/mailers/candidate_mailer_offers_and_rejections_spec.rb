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
      'Make a decision: successful application for Brighthurst Technical College',
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
        'Make a decision: successful application for Falconholt Technical College',
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
      'Make a decision: successful application for Brighthurst Technical College',
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
      'Successful application for Brighthurst Technical College',
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
        structured_rejection_reasons: {
          quality_of_application_y_n: 'Yes',
          quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge],
          quality_of_application_personal_statement_what_to_improve: 'Do not refer to yourself in the third person',
          quality_of_application_subject_knowledge_what_to_improve: 'Write in the first person',
        },
      )
      @application_form.application_choices = [@application_choice]

      magic_link_stubbing(@application_form.candidate)
    end

    describe '.application_rejected_all_applications_rejected' do
      it_behaves_like(
        'a mail with subject and content', :application_rejected_all_applications_rejected,
        I18n.t!('candidate_mailer.application_rejected_all_applications_rejected.subject',
                provider_name: 'Falconholt Technical College'),
        'heading' => 'Dear Tyrell',
        'course name and code' => 'Forensic Science (E0FO)',
        'rejection reason heading' => 'Quality of application',
        'rejection reason content' => 'Write in the first person'
      )
    end

    describe '.application_rejected_one_offer_one_awaiting_decision' do
      before do
        reasons_for_rejection = {
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_what_did_the_candidate_do: %w[other],
          candidate_behaviour_other: 'Bad language',
          candidate_behaviour_what_to_improve: 'Do not swear',
        }
        provider = build_stubbed(:provider, name: 'Falconholt Technical College')
        course_option = build_stubbed(:course_option,
                                      course: build_stubbed(:course, name: 'Forensic Science', code: 'E0FO', provider: provider))
        course_option2 = build_stubbed(:course_option,
                                       course: build_stubbed(:course, name: 'Computer Science', provider: provider))

        @application_form = FactoryBot.build_stubbed(
          :application_form,
          first_name: 'Tyrell',
          last_name: 'Wellick',
          candidate: @application_form.candidate,
          application_choices: [
            FactoryBot.build_stubbed(
              :application_choice,
              status: :rejected,
              application_form: @application_form,
              course_option: course_option,
              structured_rejection_reasons: reasons_for_rejection,
            ),
            FactoryBot.build_stubbed(
              :application_choice,
              :with_offer,
              application_form: @application_form,
              course_option: course_option,
            ),
            FactoryBot.build_stubbed(
              :application_choice,
              application_form: @application_form,
              reject_by_default_at: Time.zone.local(2021, 1, 17),
              status: :awaiting_provider_decision,
              course_option: course_option2,
            ),
          ],
        )
        @application_choice = @application_form.application_choices.first
      end

      it_behaves_like(
        'a mail with subject and content', :application_rejected_one_offer_one_awaiting_decision,
        I18n.t!('candidate_mailer.application_rejected_one_offer_one_awaiting_decision.subject',
                provider_name: 'Falconholt Technical College'),
        'heading' => 'Dear Tyrell',
        'course name and code' => 'Forensic Science (E0FO)',
        'rejection reason heading' => 'Something you did',
        'rejection reason content' => 'Bad language',
        'other application details' => 'You have an offer and are waiting for a decision about another course',
        'application with offer' => 'You have an offer from Falconholt Technical College to study Forensic Science',
        'application awaiting decision' => 'to make a decision about your application to study Computer Science',
        'decision day' => 'has until 17 January 2021 to make a decision'
      )
    end

    describe '.application_rejected_awaiting_decision_only' do
      before do
        reasons_for_rejection = {
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_what_did_the_candidate_do: %w[other],
          candidate_behaviour_other: 'Bad language',
          candidate_behaviour_what_to_improve: 'Do not swear',
        }
        provider = build_stubbed(:provider, name: 'Falconholt Technical College')
        course_option = build_stubbed(:course_option,
                                      course: build_stubbed(:course, name: 'Forensic Science', code: 'E0FO', provider: provider))
        course_option2 = build_stubbed(:course_option,
                                       course: build_stubbed(:course, name: 'Computer Science', provider: provider))

        @application_form = FactoryBot.build_stubbed(
          :application_form,
          first_name: 'Tyrell',
          last_name: 'Wellick',
          candidate: @application_form.candidate,
          application_choices: [
            FactoryBot.build_stubbed(
              :application_choice,
              status: :rejected,
              application_form: @application_form,
              course_option: course_option,
              structured_rejection_reasons: reasons_for_rejection,
            ),
            FactoryBot.build_stubbed(
              :application_choice,
              status: :awaiting_provider_decision,
              reject_by_default_at: Time.zone.local(2021, 1, 17),
              application_form: @application_form,
              course_option: course_option,
            ),
            FactoryBot.build_stubbed(
              :application_choice,
              application_form: @application_form,
              reject_by_default_at: Time.zone.local(2021, 1, 14),
              status: :awaiting_provider_decision,
              course_option: course_option2,
            ),
          ],
        )
        @application_choice = @application_form.application_choices.first
      end

      it_behaves_like(
        'a mail with subject and content', :application_rejected_awaiting_decision_only,
        I18n.t!('candidate_mailer.application_rejected_awaiting_decision_only.subject'),
        'heading' => 'Dear Tyrell',
        'course name and code' => 'Forensic Science (E0FO)',
        'rejection reason heading' => 'Something you did',
        'rejection reason content' => 'Bad language',
        'other application details' => "You're waiting for decisions",
        'first application' => 'Falconholt Technical College to study Forensic Science',
        'second application' => 'Falconholt Technical College to study Computer Science',
        'decision day' => 'They should make their decisions by 17 January 2021'
      )
    end

    describe '.application_rejected_offers_only' do
      before do
        reasons_for_rejection = {
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_what_did_the_candidate_do: %w[other],
          candidate_behaviour_other: 'Bad language',
          candidate_behaviour_what_to_improve: 'Do not swear',
        }
        provider = build_stubbed(:provider, name: 'Falconholt Technical College')
        course_option = build_stubbed(:course_option,
                                      course: build_stubbed(:course, name: 'Forensic Science', code: 'E0FO', provider: provider))
        course_option2 = build_stubbed(:course_option,
                                       course: build_stubbed(:course, name: 'Computer Science', provider: provider))

        @application_form = FactoryBot.build_stubbed(
          :application_form,
          first_name: 'Tyrell',
          last_name: 'Wellick',
          candidate: @application_form.candidate,
          application_choices: [
            FactoryBot.build_stubbed(
              :application_choice,
              status: :rejected,
              application_form: @application_form,
              course_option: course_option,
              structured_rejection_reasons: reasons_for_rejection,
            ),
            FactoryBot.build_stubbed(
              :application_choice,
              :with_offer,
              decline_by_default_at: 5.days.from_now,
              application_form: @application_form,
              course_option: course_option,
            ),
            FactoryBot.build_stubbed(
              :application_choice,
              :with_offer,
              decline_by_default_at: 10.days.from_now,
              application_form: @application_form,
              course_option: course_option2,
            ),
          ],
        )
        @application_choice = @application_form.application_choices.first
      end

      it_behaves_like(
        'a mail with subject and content', :application_rejected_offers_only,
        I18n.t!('candidate_mailer.application_rejected_offers_only.subject', date: '16 February 2020'),
        'heading' => 'Dear Tyrell',
        'course name and code' => 'Forensic Science (E0FO)',
        'rejection reason heading' => 'Something you did',
        'rejection reason content' => 'Bad language',
        'other application details' => 'You’re not waiting for any other decisions.',
        'first application details' => 'Falconholt Technical College to study Forensic Science',
        'second application details' => 'Falconholt Technical College to study Computer Science',
        'respond by date' => 'The offers will automatically be withdrawn if you do not respond by 16 February 2020'
      )
    end
  end

  describe 'feedback_received_for_application_rejected_by_default' do
    before do
      @application_form = build_stubbed(:application_form, first_name: 'Kurt')
      provider = build_stubbed(:provider, name: 'Geffen Records')
      @offered_course_option = build_stubbed(
        :course_option,
        course: build_stubbed(:course, name: 'Nevermind', code: 'NV4', provider: provider, start_date: Date.new(2020, 9, 15)),
        site: build_stubbed(:site, name: 'Lithium', provider: provider),
      )
      @application_choice = build_stubbed(
        :application_choice,
        :with_rejection_by_default,
        offered_course_option: @offered_course_option,
        application_form: @application_form,
        rejection_reason: 'I\'m so happy',
        rejected_at: Time.zone.today,
      )
    end

    it_behaves_like(
      'a mail with subject and content',
      :feedback_received_for_application_rejected_by_default,
      'Feedback on your application for Geffen Records',
      'heading' => 'Dear Kurt',
      'provider name' => 'Geffen Records did not respond in time',
      'name and code for course' => 'Nevermind (NV4)',
      'feedback' => 'I\'m so happy',
    )
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
