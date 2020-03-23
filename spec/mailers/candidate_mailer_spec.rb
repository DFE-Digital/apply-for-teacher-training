require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  include CourseOptionHelpers
  include ViewHelper
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
  end

  describe '.application_submitted' do
    let(:mail) { mailer.application_submitted(@application_form) }

    before do
      allow(Encryptor).to receive(:encrypt).with(@candidate.id).and_return('example_encrypted_id')
    end

    it_behaves_like('a mail with subject and content', :application_submitted,
                    I18n.t!('candidate_mailer.application_submitted.subject'),
                    'heading' => 'Application submitted',
                    'support reference' => 'SUPPORT-REFERENCE',
                    'RBD time limit' => "to make an offer within #{TimeLimitConfig.limits_for(:reject_by_default).first.limit} working days")

    context 'when the edit_application feature flag is on' do
      before { FeatureFlag.activate('edit_application') }

      it_behaves_like('a mail with subject and content', :application_submitted,
                      I18n.t!('candidate_mailer.application_submitted.subject'),
                      'edit by time limit' => "You have #{TimeLimitConfig.limits_for(:edit_by).first.limit} working days to edit")
    end

    context 'when the improved_expired_token_flow feature flag is on' do
      before { FeatureFlag.activate('improved_expired_token_flow') }

      it_behaves_like('a mail with subject and content', :application_submitted,
                      I18n.t!('candidate_mailer.application_submitted.subject'),
                      'link to sign in and id' => 'http://localhost:3000/candidate/sign-in?u=example_encrypted_id')
    end

    context 'when the improved_expired_token_flow feature flag is off' do
      before { FeatureFlag.deactivate('improved_expired_token_flow') }

      it_behaves_like('a mail with subject and content', :application_submitted,
                      I18n.t!('candidate_mailer.application_submitted.subject'),
                      'link to sign in and id' => 'http://localhost:3000/candidate/sign-in')
    end

    context 'when the covid-19 feature flag is on' do
      before { FeatureFlag.activate('covid_19') }

      it_behaves_like('a mail with subject and content', :application_submitted,
                      I18n.t!('candidate_mailer.application_submitted.subject'),
                      'RBD time limit' => 'Due to the impact of coronavirus, it might take some time for providers to get back to you.')
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
        'sign in url' => 'http://localhost:3000/candidate/sign-in'
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
end
