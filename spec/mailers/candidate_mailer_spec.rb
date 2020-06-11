require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  include CourseOptionHelpers
  include TestHelpers::MailerSetupHelper

  subject(:mailer) { described_class }

  shared_examples 'a mail with subject and content' do |mail, subject, content|
    let(:email) { described_class.send(mail, @application_form) }

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
    magic_link_stubbing(@candidate)
  end

  describe '.application_submitted' do
    let(:mail) { mailer.application_submitted(@application_form) }

    it_behaves_like(
      'a mail with subject and content',
      :application_submitted,
      I18n.t!('candidate_mailer.application_submitted.subject'),
      'heading' => 'Application submitted',
      'support reference' => 'SUPPORT-REFERENCE',
      'RBD time limit' => "to make an offer within #{TimeLimitConfig.limits_for(:reject_by_default).first.limit} working days",
      'magic link to authenticate' => 'http://localhost:3000/candidate/authenticate?token=raw_token&u=encrypted_id',
    )

    context 'when the covid-19 feature flag is on' do
      before { FeatureFlag.activate('covid_19') }

      it_behaves_like(
        'a mail with subject and content',
        :application_submitted,
        I18n.t!('candidate_mailer.application_submitted.subject'),
        'RBD time limit' => 'Due to the impact of coronavirus, it might take some time for providers to get back to you.',
      )
    end
  end

  describe 'Send survey email' do
    context 'when initial email' do
      it_behaves_like('a mail with subject and content', :survey_email,
                      'Was applying for teacher training easy?',
                      'heading' => 'Dear Bob',
                      'link to the survey' => I18n.t!('survey_emails.survey_link'))
    end

    context 'when chaser email' do
      it_behaves_like('a mail with subject and content', :survey_chaser_email,
                      'We’d love to hear from you about your teacher training application',
                      'heading' => 'Dear Bob',
                      'link to the survey' => I18n.t!('survey_emails.survey_link'))
    end
  end

  describe '.application_sent_to_provider' do
    context 'when initial email' do
      it_behaves_like(
        'a mail with subject and content', :application_sent_to_provider,
        'Your application is being considered',
        'heading' => 'Dear Bob',
        'working days the provider has to respond' => '10 working days',
        'magic link to authenticate' => 'http://localhost:3000/candidate/authenticate?token=raw_token&u=encrypted_id'
      )
    end

    context 'when the covid-19 feature flag is on' do
      before { FeatureFlag.activate('covid_19') }

      it_behaves_like(
        'a mail with subject and content', :application_sent_to_provider,
        'Your application is being considered',
        'time frame provider has to respond' => "They’ll be in touch with you if they want to arrange an interview.\r\n\r\nDue to the impact of coronavirus, this may take some time."
      )
    end
  end

  describe 'Candidate decision chaser email' do
    context 'when the covid-19 feature flag is on' do
      before { FeatureFlag.activate('covid_19') }

      it_behaves_like(
        'a mail with subject and content', :chase_candidate_decision,
        I18n.t!('chase_candidate_decision_email.subject_singular'),
        'Date to resbond by' => "Respond by #{10.business_days.from_now.to_s(:govuk_date).strip}"
      )
    end

    context 'when a candidate has one appication choice with offer' do
      it_behaves_like(
        'a mail with subject and content', :chase_candidate_decision,
        I18n.t!('chase_candidate_decision_email.subject_singular'),
        'heading' => 'Dear Bob',
        'days left to respond' => "#{TimeLimitConfig.limits_for(:chase_candidate_before_dbd).first.limit} working days",
        'dbd date' => 10.business_days.from_now.to_s(:govuk_date).strip,
        'course name and code' => 'Applied Science (Psychology)',
        'provider name' => 'Brighthurst Technical College'
      )
    end

    context 'when a candidate has multiple application choices with offer' do
      before do
        setup_application_form_with_two_offers(@application_form)
      end

      it_behaves_like(
        'a mail with subject and content', :chase_candidate_decision,
        I18n.t!('chase_candidate_decision_email.subject_plural'),
        'first course with offer' => 'MS Painting',
        'first course provider with offer' => 'Wen University',
        'second course with offer' => 'Code Refactoring',
        'second course provider with offer' => 'Ting University'
      )
    end
  end

  describe '.decline_by_default' do
    context 'when the covid-19 feature flag is on' do
      before do
        FeatureFlag.activate('covid_19')
        @application_form = build_stubbed(
          :application_form,
          first_name: 'Fred',
          application_choices: [build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10)],
        )
      end

      it_behaves_like(
        'a mail with subject and content', :declined_by_default,
        'Application withdrawn automatically',
        'Reason' => 'because you didn’t respond in time.'
      )
    end

    context 'when a candidate has 1 offer that was declined' do
      before do
        @application_form = build_stubbed(
          :application_form,
          first_name: 'Fred',
          candidate: @candidate,
          application_choices: [
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
          ],
        )
      end

      it_behaves_like(
        'a mail with subject and content',
        :declined_by_default,
        'Application withdrawn automatically',
        'heading' => 'Dear Fred',
        'days left to respond' => '10 working days',
      )
    end

    context 'when a candidate has 2 or 3 offers that were declined' do
      before do
        @application_form = build_stubbed(
          :application_form,
          first_name: 'Fred',
          candidate: @candidate,
          application_choices: [
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
          ],
        )
      end

      it_behaves_like 'a mail with subject and content', :declined_by_default, 'Applications withdrawn automatically', {}
    end
  end

  context 'when the covid-19 feature flag is on and the apply again flag is on' do
    before do
      FeatureFlag.activate('covid_19')
      FeatureFlag.activate('apply_again')
      @application_form = build_stubbed(
        :application_form,
        candidate: @candidate,
        application_choices: [build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10)],
      )
    end

    it_behaves_like(
      'a mail with subject and content',
      :declined_by_default,
      'You did not respond to your offer: next steps',
      'Reason' => 'You did not respond in time so we declined your',
    )
  end

  context 'when the covid-19 feature flag is off and the apply_again flag is on' do
    before do
      FeatureFlag.activate('apply_again')
      @application_form = build_stubbed(
        :application_form,
        first_name: 'Fred',
        candidate: @candidate,
        application_choices: [build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10)],
      )
    end

    it_behaves_like(
      'a mail with subject and content',
      :declined_by_default,
      'You did not respond to your offer: next steps',
      'Reason' => 'You did not respond within',
    )
  end

  context 'when a candidate has 1 offer that was declined by default' do
    before do
      FeatureFlag.activate('apply_again')
      @application_form = build_stubbed(
        :application_form,
        first_name: 'Fred',
        candidate: @candidate,
        application_choices: [
          build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
        ],
      )
    end

    it_behaves_like(
      'a mail with subject and content',
      :declined_by_default,
      'You did not respond to your offer: next steps',
      'heading' => 'Dear Fred',
      'DBD_days_they_had_to_respond' => '10 working days',
      'still_interested' => 'You didn’t pursue your teacher training application',
    )
  end

  context 'when a candidate has 2 offers that were declined by default' do
    before do
      FeatureFlag.activate('apply_again')
      @application_form = build_stubbed(
        :application_form,
        first_name: 'Fred',
        candidate: @candidate,
        application_choices: [
          build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
          build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
        ],
      )
    end

    it_behaves_like(
      'a mail with subject and content',
      :declined_by_default,
      'You did not respond to your offers: next steps',
      'heading' => 'Dear Fred',
      'DBD_days_they_had_to_respond' => '10 working days',
      'still_interested' => 'You didn’t pursue your teacher training application',
    )
  end

  context 'when a candidate has 1 offer that was declined by default and a rejection' do
    before do
      FeatureFlag.activate('apply_again')
      @application_form = build_stubbed(
        :application_form,
        first_name: 'Fred',
        candidate: @candidate,
        application_choices: [
          build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
          build_stubbed(:application_choice, status: 'rejected'),
        ],
      )
    end

    it_behaves_like(
      'a mail with subject and content',
      :declined_by_default,
      'You did not respond to your offer: next steps',
      'heading' => 'Dear Fred',
      'DBD_days_they_had_to_respond' => '10 working days',
      'still_interested' => 'If now’s the right time for you',
    )
  end

  context 'when a candidate has 2 offers that were declined by default and a rejection' do
    before do
      FeatureFlag.activate('apply_again')
      @application_form = build_stubbed(
        :application_form,
        first_name: 'Fred',
        candidate: @candidate,
        application_choices: [
          build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
          build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
          build_stubbed(:application_choice, status: 'rejected'),
        ],
      )
    end

    it_behaves_like(
      'a mail with subject and content',
      :declined_by_default,
      'You did not respond to your offers: next steps',
      'heading' => 'Dear Fred',
      'DBD_days_they_had_to_respond' => '10 working days',
      'still_interested' => 'If now’s the right time for you',
    )
  end

  describe '.withdraw_last_application_choice' do
    context 'when a candidate has 1 course choice that was withdrawn' do
      before do
        @application_form = build_stubbed(
          :application_form,
          first_name: 'Fred',
          candidate: @candidate,
          application_choices: [
            build_stubbed(:application_choice, status: 'withdrawn'),
          ],
        )
      end

      it_behaves_like(
        'a mail with subject and content',
        :withdraw_last_application_choice,
        'You’ve withdrawn your application: next steps',
        'heading' => 'Dear Fred',
        'application_withdrawn' => 'You’ve withdrawn your application',
      )
    end

    context 'when a candidate has 2 or 3 offers that were declined' do
      before do
        @application_form = build_stubbed(
          :application_form,
          first_name: 'Fred',
          candidate: @candidate,
          application_choices: [
            build_stubbed(:application_choice, status: 'withdrawn'),
            build_stubbed(:application_choice, status: 'withdrawn'),
          ],
        )
      end

      it_behaves_like(
        'a mail with subject and content',
        :withdraw_last_application_choice,
        'You’ve withdrawn your applications: next steps',
        'application_withdrawn' => 'You’ve withdrawn your application',
      )
    end
  end

  describe '.decline_last_application_choice' do
    let(:email) { described_class.decline_last_application_choice(@application_form.application_choices.first) }

    before do
      @application_form = build_stubbed(
        :application_form,
        first_name: 'Fred',
        candidate: @candidate,
        application_choices: [
          build_stubbed(:application_choice, status: 'declined'),
        ],
      )
    end

    it 'has the right subject and content' do
      expect(email.subject).to eq 'You’ve declined an offer: next steps'
      expect(email).to have_content 'Dear Fred'
      expect(email).to have_content 'declined your offer to study'
    end
  end

  describe '#apply_again_call_to_action' do
    it 'has the correct subject and content' do
      application_form = build_stubbed(
        :application_form,
        first_name: 'Fred',
        candidate: @candidate,
        application_choices: [
          build_stubbed(
            :application_choice,
            status: 'rejected',
            course_option: build_stubbed(
              :course_option,
              course: build_stubbed(
                :course,
                name: 'Mathematics',
                code: 'M101',
                provider: build_stubbed(
                  :provider,
                  name: 'Cholbury College',
                ),
              ),
            ),
          ),
        ],
      )
      email = described_class.apply_again_call_to_action(application_form)

      expect(email.subject).to eq 'You can still apply for teacher training'
      expect(email.body).to include('Dear Fred,')
      expect(email.body).to include('You can apply for teacher training again if you have not got a place yet')
    end
  end

  describe '.chase_reference_again' do
    let(:email) { described_class.chase_reference_again(@referee) }

    before do
      @referee = build_stubbed(:reference, application_form: @application_form)
    end

    it 'has the right subject and content' do
      expect(email.subject).to eq "Give new referee as soon as possible: #{@referee.name} has not responded"
      expect(email).to have_content 'Dear Bob'
      expect(email).to have_content "We have not had a reference from #{@referee.name} yet."
    end
  end

  describe '#course_unavailable_notification' do
    def build_stubbed_application_form
      build_stubbed(
        :application_form,
        first_name: 'Fred',
        candidate: @candidate,
        application_choices: [
          build_stubbed(
            :application_choice,
            status: 'awaiting_references',
            course_option: build_stubbed(
              :course_option,
              vacancy_status: :no_vacancies,
              site: build_stubbed(
                :site,
                name: 'West Wilford School',
              ),
              course: build_stubbed(
                :course,
                name: 'Mathematics',
                code: 'M101',
                provider: build_stubbed(
                  :provider,
                  name: 'Bilberry College',
                ),
              ),
            ),
          ),
        ],
      )
    end

    context 'when the selected course option has no vacancies and there are no other locations/study modes available' do
      it 'has the correct subject and content' do
        application_form = build_stubbed_application_form
        application_choice = application_form.application_choices.first
        email = described_class.course_unavailable_notification(
          application_choice,
          :course_full,
        )

        expect(email.subject).to eq 'There are no more places for Mathematics (M101) at Bilberry College: update your course choice now'
        expect(email.body).to include('Dear Fred,')
        expect(email.body).to include('There are no more places for Mathematics (M101) at Bilberry College')
      end
    end

    context 'when the selected course has been withdrawn' do
      it 'has the correct subject and content' do
        application_form = build_stubbed_application_form
        application_choice = application_form.application_choices.first
        email = described_class.course_unavailable_notification(
          application_choice,
          :course_withdrawn,
        )

        expect(email.subject).to eq('Mathematics (M101) at Bilberry College is not running anymore: update your course choice now')
        expect(email.body).to include('Dear Fred,')
        expect(email.body).to include('Your course is not running anymore')
        expect(email.body).to include('Bilberry College is not running Mathematics (M101) anymore.')
      end
    end

    context 'when the selected course option has no vacancies and but there are other locations available' do
      it 'has the correct subject and content' do
        application_form = build_stubbed_application_form
        application_choice = application_form.application_choices.first
        email = described_class.course_unavailable_notification(
          application_choice,
          :location_full,
        )

        expect(email.subject).to eq 'There are no more places at your choice of location for Mathematics (M101) at Bilberry College: update your course choice now'
        expect(email.body).to include('Dear Fred,')
        expect(email.body).to include('There are no more places at West Wilford School for Mathematics (M101) at Bilberry College')
      end
    end

    context 'when the selected course option has no vacancies and but there are other study modes available at the same location' do
      it 'has the correct subject and content' do
        application_form = build_stubbed_application_form
        application_choice = application_form.application_choices.first
        email = described_class.course_unavailable_notification(
          application_choice,
          :study_mode_full,
        )

        expect(email.subject).to eq 'There are no more full time places for Mathematics (M101) at Bilberry College: update your course choice now'
        expect(email.body).to include('Dear Fred,')
        expect(email.body).to include('There are no more full time places for Mathematics (M101) at Bilberry College')
      end
    end
  end
end
