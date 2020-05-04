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
                      I18n.t!('survey_emails.subject.initial'),
                      'heading' => 'Dear Bob',
                      'thank you message' => I18n.t!('survey_emails.thank_you.candidate'),
                      'link to the survey' => I18n.t!('survey_emails.survey_link'))
    end

    context 'when chaser email' do
      it_behaves_like('a mail with subject and content', :survey_chaser_email,
                      I18n.t!('survey_emails.subject.chaser'),
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
          application_choices: [
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
          ],
        )
      end

      it_behaves_like 'a mail with subject and content', :declined_by_default, 'Applications withdrawn automatically', {}
    end
  end

  describe '#decline_by_default_without_rejections' do
    context 'when the covid-19 feature flag' do
      before do
        FeatureFlag.activate('covid_19')
        @application_form = build_stubbed(
          :application_form,
          application_choices: [build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10)],
        )
      end

      it_behaves_like(
        'a mail with subject and content',
        :declined_by_default_without_rejections,
        'You did not respond to your offer: next steps',
        'Reason' => 'You did not respond in time so we declined your',
      )
    end

    context 'when the covid-19 feature flag is off and the apply_again flag is on' do
      before do
        FeatureFlag.activate('apply_again')
        @application_form = build_stubbed(
          :application_form,
          application_choices: [build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10)],
        )
      end

      it_behaves_like(
        'a mail with subject and content',
        :declined_by_default_without_rejections,
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
          application_choices: [
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
          ],
        )
      end

      it_behaves_like(
        'a mail with subject and content',
        :declined_by_default_without_rejections,
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
          application_choices: [
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
          ],
        )
      end

      it_behaves_like(
        'a mail with subject and content',
        :declined_by_default_without_rejections,
        'You did not respond to your offers: next steps',
        'heading' => 'Dear Fred',
        'DBD_days_they_had_to_respond' => '10 working days',
        'still_interested' => 'You didn’t pursue your teacher training application',
      )
    end
  end

  describe '#decline_by_default_with_rejections' do
    context 'when the covid-19 feature flag' do
      before do
        FeatureFlag.activate('covid_19')
        @application_form = build_stubbed(
          :application_form,
          application_choices: [
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
            build_stubbed(:application_choice, status: 'rejected'),
          ],
        )
      end

      it_behaves_like(
        'a mail with subject and content',
        :declined_by_default_with_rejections,
        'You did not respond to your offer: next steps',
        'Reason' => 'You did not respond in time so we declined your',
      )
    end

    context 'when the covid-19 feature flag is off and the apply_again flag is on' do
      before do
        FeatureFlag.activate('apply_again')
        @application_form = build_stubbed(
          :application_form,
          application_choices: [
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
            build_stubbed(:application_choice, status: 'rejected'),
            ],
        )
      end

      it_behaves_like(
        'a mail with subject and content',
        :declined_by_default_with_rejections,
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
          application_choices: [
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
            build_stubbed(:application_choice, status: 'rejected'),
          ],
        )
      end

      it_behaves_like(
        'a mail with subject and content',
        :declined_by_default_with_rejections,
        'You did not respond to your offer: next steps',
        'heading' => 'Dear Fred',
        'DBD_days_they_had_to_respond' => '10 working days',
        'still_interested' => 'If now’s the right time for you',
      )
    end

    context 'when a candidate has 2 offers that were declined by default' do
      before do
        FeatureFlag.activate('apply_again')
        @application_form = build_stubbed(
          :application_form,
          first_name: 'Fred',
          application_choices: [
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
            build_stubbed(:application_choice, status: 'declined', declined_by_default: true, decline_by_default_days: 10),
            build_stubbed(:application_choice, status: 'rejected'),
          ],
        )
      end

      it_behaves_like(
        'a mail with subject and content',
        :declined_by_default_with_rejections,
        'You did not respond to your offers: next steps',
        'heading' => 'Dear Fred',
        'DBD_days_they_had_to_respond' => '10 working days',
        'still_interested' => 'If now’s the right time for you',
      )
    end
  end

  describe '.withdraw_last_application_choice' do
    context 'when a candidate has 1 course choice that was withdrawn' do
      before do
        @application_form = create(
          :application_form,
          first_name: 'Fred',
          application_choices: [
            create(:application_choice, status: 'withdrawn'),
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
end
