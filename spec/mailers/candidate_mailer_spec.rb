require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe '.application_submitted' do
    let(:candidate) { build_stubbed(:candidate) }
    let(:application_form) { build_stubbed(:application_form, support_reference: 'SUPPORT-REFERENCE', candidate: candidate) }
    let(:mail) { mailer.application_submitted(application_form) }

    before do
      allow(Encryptor).to receive(:encrypt).with(candidate.id).and_return('example_encrypted_id')
      mail.deliver_later
    end

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('candidate_mailer.application_submitted.subject'))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include('Application submitted')
    end

    it 'sends an email containing the support reference' do
      expect(mail.body.encoded).to include('SUPPORT-REFERENCE')
    end

    it 'sends an email containing RBD time limit' do
      rbd_time_limit = "to make an offer within #{TimeLimitConfig.limits_for(:reject_by_default).first.limit} working days"
      expect(mail.body.encoded).to include(rbd_time_limit)
    end

    context 'when the edit_application feature flag is on' do
      before { FeatureFlag.activate('edit_application') }

      it 'sends an email containing the remaining time to edit' do
        edit_by_time_limit = "You have #{TimeLimitConfig.limits_for(:edit_by).first.limit} working days to edit"
        expect(mail.body.encoded).to include(edit_by_time_limit)
      end
    end

    context 'when the improved_expired_token_flow feature flag is on' do
      before { FeatureFlag.activate('improved_expired_token_flow') }

      it 'sends an email containing a link to sign in and id' do
        expect(mail.body.encoded).to include(candidate_interface_sign_in_url(u: 'example_encrypted_id'))
      end
    end

    context 'when the improved_expired_token_flow feature flag is off' do
      before { FeatureFlag.deactivate('improved_expired_token_flow') }

      it 'sends an email containing a link to sign in without id' do
        expect(mail.body.encoded).to include(candidate_interface_sign_in_url)
        expect(mail.body.encoded).not_to include(candidate_interface_sign_in_url(u: 'example_encrypted_id'))
      end
    end
  end

  describe '.chase_reference' do
    let(:application_form) { create(:completed_application_form, references_count: 1, with_gces: true) }
    let(:reference) { application_form.application_references.first }
    let(:mail) { mailer.chase_reference(reference) }

    before { mail.deliver_later }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('candidate_mailer.chase_reference.subject', referee_name: reference.name))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include("Dear #{application_form.first_name}")
    end

    it 'sends an email containing the referee email' do
      expect(mail.body.encoded).to include(reference.email_address)
    end
  end

  describe 'Send survey email' do
    let(:application_form) { build_stubbed(:application_form) }

    context 'when initial email' do
      let(:mail) { mailer.survey_email(application_form) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('survey_emails.subject.initial'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include("Dear #{application_form.first_name}")
      end

      it 'sends an email with the correct thank you message' do
        expect(mail.body.encoded).to include(t('survey_emails.thank_you.candidate'))
      end

      it 'sends an email with the link to the survey' do
        expect(mail.body.encoded).to include(t('survey_emails.survey_link'))
      end
    end

    context 'when chaser email' do
      let(:mail) { mailer.survey_chaser_email(application_form) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('survey_emails.subject.chaser'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include("Dear #{application_form.first_name}")
      end

      it 'sends an email with the link to the survey' do
        expect(mail.body.encoded).to include(t('survey_emails.survey_link'))
      end
    end
  end

  describe 'Send request for new referee email' do
    let(:reference) { build_stubbed(:reference, name: 'Scott Knowles') }
    let(:application_form) do
      build_stubbed(
        :application_form,
        first_name: 'Tyrell',
        last_name: 'Wellick',
        application_references: [reference],
      )
    end

    context 'when referee has not responded' do
      let(:mail) { mailer.new_referee_request(application_form, reference) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('new_referee_request.not_responded.subject', referee_name: 'Scott Knowles'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include('Dear Tyrell')
      end

      it 'sends an email saying referee has not responded' do
        explanation = mail.body.encoded.gsub("\r", '')

        expect(explanation).to include(t('new_referee_request.not_responded.explanation', referee_name: 'Scott Knowles'))
      end
    end

    context 'when referee has refused' do
      let(:mail) { mailer.new_referee_request(application_form, reference, reason: :refused) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('new_referee_request.refused.subject', referee_name: 'Scott Knowles'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include('Dear Tyrell')
      end

      it 'sends an email saying referee has refused' do
        explanation = mail.body.encoded.gsub("\r", '')

        expect(explanation).to include(t('new_referee_request.refused.explanation', referee_name: 'Scott Knowles'))
      end
    end

    context 'when email address of referee has bounced' do
      let(:mail) { mailer.new_referee_request(application_form, reference, reason: :email_bounced) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('new_referee_request.email_bounced.subject', referee_name: 'Scott Knowles'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include('Dear Tyrell')
      end

      it 'sends an email saying referee email bounced' do
        explanation = mail.body.encoded.gsub("\r", '')

        expect(explanation).to include(t('new_referee_request.email_bounced.explanation', referee_name: 'Scott Knowles', referee_email: reference.email_address))
      end
    end
  end

  describe '.application_sent_to_provider' do
    let(:application_choice) { build_stubbed(:application_choice, reject_by_default_days: '40') }
    let(:application_form) do
      build_stubbed(
        :application_form,
        first_name: 'Tyrell',
        last_name: 'Wellick',
        application_choices: [application_choice],
      )
    end

    context 'when initial email' do
      let(:mail) { mailer.application_sent_to_provider(application_form) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include('Your application is being considered')
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include('Dear Tyrell')
      end

      it 'sends an email with the correct amount of working days the provider has to respond' do
        expect(mail.body.encoded).to include("We’ve asked them to make a final decision within #{application_choice.reject_by_default_days} working days.")
      end

      it 'sends an email with candidate sign in url' do
        expect(mail.body.encoded).to include(candidate_interface_sign_in_url)
      end
    end
  end

  describe 'send new offer email to candidate' do
    around do |example|
      Timecop.freeze(Time.zone.local(2020, 2, 11)) do
        example.run
      end
    end

    def setup_application
      @candidate = build_stubbed(:candidate)
      @application_form = build_stubbed(
        :application_form,
        support_reference: 'SUPPORT-REFERENCE',
        candidate: @candidate,
        first_name: 'Bob',
      )
      course_option = build_stubbed(:course_option)
      @application_choice = @application_form.application_choices.build(
        id: 123,
        application_form: @application_form,
        course_option: course_option,
        status: :offer,
        offer: { conditions: ['DBS check', 'Pass exams'] },
        offered_at: Time.zone.now,
        offered_course_option: course_option,
        decline_by_default_at: 10.business_days.from_now,
      )
    end

    describe '#new_offer_single_offer' do
      before do
        setup_application
        @mail = mailer.new_offer_single_offer(@application_choice)
        @mail.deliver_later
      end

      it 'sends an email with the correct greeting' do
        expect(@mail.body.encoded).to include('Dear Bob')
      end

      it 'sends an email with the correct subject' do
        expect(@mail.subject).to include("Offer received for #{@application_choice.course_option.course.name} (#{@application_choice.course_option.course.code}) at #{@application_choice.course_option.course.provider.name}")
      end

      it 'sends an email with the correct decline by default date' do
        expect(@mail.body.encoded).to include('Make a decision by 25 February 2020')
      end

      it 'sends an email with the correct conditions' do
        expect(@mail.body.encoded).to include('DBS check')
        expect(@mail.body.encoded).to include('Pass exams')
      end
    end

    describe '#new_offer_multiple_offers' do
      before do
        setup_application
        other_course_option = build_stubbed(:course_option)
        @other_application_choice = @application_form.application_choices.build(
          id: 456,
          application_form: @application_form,
          course_option: other_course_option,
          status: :offer,
          offer: { conditions: ['Get a degree'] },
          offered_at: Time.zone.now,
          offered_course_option: other_course_option,
          decline_by_default_at: 5.business_days.from_now,
        )
        @application_form.id = nil
        @application_form.application_choices = [@application_choice, @other_application_choice]
        @mail = mailer.new_offer_multiple_offers(@application_choice)
        @mail.deliver_later
      end

      it 'sends an email with the correct greeting' do
        expect(@mail.body.encoded).to include('Dear Bob')
      end

      it 'sends an email with the correct subject' do
        expect(@mail.subject).to include("Offer received for #{@application_choice.course_option.course.name} (#{@application_choice.course_option.course.code}) at #{@application_choice.course_option.course.provider.name}")
      end

      it 'sends an email with the correct decline by default date' do
        expect(@mail.body.encoded).to include('Make a decision by 25 February 2020')
      end

      it 'sends an email with the correct conditions' do
        expect(@mail.body.encoded).to include('DBS check')
        expect(@mail.body.encoded).to include('Pass exams')
      end

      it 'sends an email with the correct list of offers' do
        expect(@mail.body.encoded).to include("#{@application_choice.course_option.course.name} (#{@application_choice.course_option.course.code}) at #{@application_choice.course_option.course.provider.name}")
        expect(@mail.body.encoded).to include("#{@other_application_choice.course_option.course.name} (#{@other_application_choice.course_option.course.code}) at #{@other_application_choice.course_option.course.provider.name}")
      end
    end

    describe '#new_offer_decisions_pending' do
      before do
        setup_application
        other_course_option = build_stubbed(:course_option)
        @other_application_choice = @application_form.application_choices.build(
          id: 456,
          application_form: @application_form,
          course_option: other_course_option,
          status: :awaiting_provider_decision,
        )
        @application_form.id = nil
        @application_form.application_choices = [@application_choice, @other_application_choice]
        @mail = mailer.new_offer_decisions_pending(@application_choice)
        @mail.deliver_later
      end

      it 'sends an email with the correct greeting' do
        expect(@mail.body.encoded).to include('Dear Bob')
      end

      it 'sends an email with the correct subject' do
        expect(@mail.subject).to include("Offer received for #{@application_choice.course_option.course.name} (#{@application_choice.course_option.course.code}) at #{@application_choice.course_option.course.provider.name}")
      end

      it 'sends an email with the correct conditions' do
        expect(@mail.body.encoded).to include('DBS check')
        expect(@mail.body.encoded).to include('Pass exams')
      end

      it 'sends an email with the correct instructions' do
        expect(@mail.body.encoded).to include('You can wait to hear back about your other application(s) before making a decision')
      end
    end
  end

  describe 'application choice rejection emails' do
    around do |example|
      Timecop.freeze(Time.zone.local(2020, 2, 11)) do
        example.run
      end
    end

    def setup_application
      @provider = create(:provider, name: 'Gorse')
      @course = create(:course, provider: @provider)
      @application_form = create(:application_form, first_name: 'Tyrell', last_name: 'Wellick')
      course_option = create(:course_option, course: @course)
      @application_choice = create(:application_choice,
                                   course_option: course_option,
                                   status: :rejected,
                                   application_form: @application_form,
                                   rejection_reason: rejection_reason)
    end

    let(:rejection_reason) { 'The application had little detail.' }

    context 'All application choices have been rejected email' do
      let(:mail) { mailer.application_rejected_all_rejected(@application_choice) }

      before do
        setup_application
        mail.deliver_later
      end

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('application_choice_rejected_email.subject.all_rejected', provider_name: @provider.name))
      end

      it 'sends an email with the correct course name and code' do
        expect(mail.body.encoded).to include(@course.name_and_code)
      end

      it 'sends an email with the providers rejection reason' do
        expect(mail.body.encoded).to include(@application_choice.rejection_reason)
      end

      it 'sends an email with a link to GIT' do
        expect(mail.body.encoded).to include(t('application_choice_rejected_email.git.url'))
      end

      it 'sends an email with GITs phone number' do
        expect(mail.body.encoded).to include(t('application_choice_rejected_email.git.phone_number'))
      end

      it 'sends an email with the BAT email address' do
        expect(mail.body.encoded).to include(t('application_choice_rejected_email.bat.url'))
      end
    end

    context 'Application rejected and awaiting further decisions' do
      let(:mail) { mailer.application_rejected_awaiting_decisions(@application_choice) }

      before do
        setup_application
        @application_choice2 = create(:application_choice, status: :awaiting_provider_decision, application_form: @application_form)
        mail.deliver_later
      end


      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('application_choice_rejected_email.subject.awaiting_decisions',
                                          provider_name: @provider.name,
                                          course_name: @course.name_and_code))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include("Dear #{@application_form.first_name}")
      end

      it 'sends an email with the correct course name and code' do
        expect(mail.body.encoded).to include(@course.name_and_code)
      end

      it 'sends an emails informing the candidate which courses they are awaiting decisions on' do
        expect(mail.body.encoded).to include(@application_choice2.course.name)
      end

      it 'sends an emails informing the candidate which providers they are awaiting decisions on' do
        expect(mail.body.encoded).to include(@application_choice2.provider.name)
      end

      it 'sends an email with the BAT email address' do
        expect(mail.body.encoded).to include(t('application_choice_rejected_email.bat.url'))
      end
    end

    context 'Application rejected and one offer has been made' do
      let(:mail) { mailer.application_rejected_offers_made(@application_choice) }

      before do
        setup_application
        @application_choice2 = create(:application_choice,
                                      status: :offer,
                                      application_form: @application_form,
                                      decline_by_default_at: 10.business_days.from_now,
                                      decline_by_default_days: 10)
        mail.deliver_later
      end

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('application_choice_rejected_email.subject.offers_made',
                                          provider_name: @provider.name,
                                          dbd_days: @application_choice2.decline_by_default_days))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include("Dear #{@application_form.first_name}")
      end

      it 'sends an email with the correct course name and code' do
        expect(mail.body.encoded).to include(@course.name_and_code)
      end

      it 'sends an emails informing the candidate of the name of the course they got an offer from' do
        expect(mail.body.encoded).to include(@application_choice2.course.name)
      end

      it 'sends an emails informing the candidate of the name of the provider they got an offer from' do
        expect(mail.body.encoded).to include(@application_choice2.provider.name)
      end

      it 'sends an emails informing the candidate of their DBD date' do
        expect(mail.body.encoded).to include('Make a decision about your offer by 25 February 2020')
      end

      it 'sends an email with the BAT email address' do
        expect(mail.body.encoded).to include(t('application_choice_rejected_email.bat.url'))
      end
    end

    context 'Application rejected and multiple offers has been made' do
      let(:mail) { mailer.application_rejected_offers_made(@application_choice) }

      before do
        setup_application
        @application_choice2 = create(:application_choice,
                                      status: :offer,
                                      application_form: @application_form,
                                      decline_by_default_at: 10.business_days.from_now,
                                      decline_by_default_days: 10)

        @application_choice3 = create(:application_choice,
                                      status: :offer,
                                      application_form: @application_form,
                                      decline_by_default_at: 8.business_days.from_now,
                                      decline_by_default_days: 10)
        mail.deliver_later
      end

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('application_choice_rejected_email.subject.offers_made',
                                          provider_name: @provider.name,
                                          dbd_days: @application_choice2.decline_by_default_days))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include("Dear #{@application_form.first_name}")
      end

      it 'sends an email with the correct course name and code' do
        expect(mail.body.encoded).to include(@course.name_and_code)
      end

      it 'sends an emails informing the candidate of the name of the first course they got an offer from' do
        expect(mail.body.encoded).to include(@application_choice2.course.name)
      end

      it 'sends an emails informing the candidate of the name of the first provider they got an offer from' do
        expect(mail.body.encoded).to include(@application_choice2.provider.name)
      end

      it 'sends an emails informing the candidate of the name of the second course they got an offer from' do
        expect(mail.body.encoded).to include(@application_choice3.course.name)
      end

      it 'sends an emails informing the candidate of the name of the second provider they got an offer from' do
        expect(mail.body.encoded).to include(@application_choice3.provider.name)
      end

      it 'sends an emails informing the candidate of their DBD date' do
        expect(mail.body.encoded).to include('Make a decision about your offers by 25 February 2020')
      end

      it 'sends an email with the BAT email address' do
        expect(mail.body.encoded).to include(t('application_choice_rejected_email.bat.url'))
      end
    end
  end
end
