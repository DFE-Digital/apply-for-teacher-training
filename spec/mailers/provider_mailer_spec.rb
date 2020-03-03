require 'rails_helper'

RSpec.describe ProviderMailer, type: :mailer do
  include CourseOptionHelpers

  shared_examples 'a provider mail with subject and content' do |mail, subject, content|
    let(:email) do
      mail == :account_created ? ProviderMailer.send(mail, @provider_user) : ProviderMailer.send(mail, @provider_user, @application_choice)
    end

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
    provider = create(:provider, :with_signed_agreement, code: 'ABC')
    course = create(:course, provider: provider, name: 'Computer Science', code: '6IND')
    site = create(:site, provider: provider)
    @course_option = create(:course_option, course: course, site: site)
    @application_choice = create(:submitted_application_choice,
                                 course_option: @course_option,
                                 reject_by_default_at: Time.zone.now + 40.days,
                                 reject_by_default_days: 123,
                                 application_form:
                                 create(
                                   :completed_application_form,
                                   first_name: 'Harry',
                                   last_name: 'Potter',
                                  ))
    @provider_user = @application_choice.provider.provider_users.first
    @provider_user.update(first_name: 'Johny', last_name: 'English')
    @application_choice.application_form.update(submitted_at: Time.zone.now - 5.days)
  end

  describe 'Send account created email' do
    it_behaves_like('a provider mail with subject and content', :account_created,
                    I18n.t!('provider_account_created.email.subject'),
                    'provider name' => 'Dear Johny English',
                    'sign in path' => '/provider/sign-in')
  end

  describe 'Send application submitted email' do
    it_behaves_like('a provider mail with subject and content', :application_submitted,
                    I18n.t!('provider_application_submitted.email.subject',
                            course_name_and_code: 'Computer Science (6IND)'),
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'reject by default days' => 'after 123 working days',
                    'link to the application' => 'http://localhost:3000/provider/applications/')
  end

  describe 'Send application rejected by default email' do
    it_behaves_like('a provider mail with subject and content', :application_rejected_by_default,
                    I18n.t!('provider_application_rejected_by_default.email.subject',
                            candidate_name: 'Harry Potter'),
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'submission date' => (Time.zone.now - 5.days).to_s(:govuk_date).strip,
                    'reject by default days' => 'within 123 working days')
  end

  describe 'Send provider decision chaser email' do
    it_behaves_like('a provider mail with subject and content', :chase_provider_decision,
                    I18n.t!('provider_application_waiting_for_decision.email.subject',
                            candidate_name: 'Harry Potter'),
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)',
                    'time to respond' => "Only #{TimeLimitConfig.limits_for(:chase_provider_before_rbd).first.limit} working days left to respond",
                    'submission date' => (Time.zone.now - 5.days).to_s(:govuk_date).strip,
                    'reject by default at' => (Time.zone.now + 40.days).to_s(:govuk_date).strip,
                    'link to the application' => 'http://localhost:3000/provider/applications/')
  end

  describe '.offer_accepted' do
    it_behaves_like('a provider mail with subject and content', :offer_accepted,
                    'Harry Potter has accepted your offer',
                    'provider name' => 'Dear Johny English',
                    'course name and code' => 'Computer Science (6IND)')
  end

  describe '.declined_by_default' do
    it_behaves_like('a provider mail with subject and content', :declined_by_default,
                    'Harry Potter’s application withdrawn automatically',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')
  end

  describe 'Send email when the application withdrawn' do
    it_behaves_like('a provider mail with subject and content', :application_withrawn,
                    'Harry Potter withdrew their application',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')
  end

  describe '.declined' do
    it_behaves_like('a provider mail with subject and content', :declined,
                    'Harry Potter declined an offer',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Harry Potter',
                    'course name and code' => 'Computer Science (6IND)')
  end
end
