require 'rails_helper'
RSpec.describe RefereeMailer, type: :mailer do
  subject(:mailer) { described_class }

  let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR }
  let(:application_form) { build_stubbed(:application_form, first_name: 'Elliot', last_name: 'Alderson', application_choices:, recruitment_cycle_year: recruitment_cycle_year) }
  let(:reference) do
    build_stubbed(:reference, name: 'Jane',
                              email_address: 'jane@education.gov.uk',
                              application_form:)
  end
  let(:application_choices) { [build_stubbed(:application_choice)] }
  let(:course_option) { create(:course_option, course: create(:course, provider: create(:provider, name: 'University of Warwick'))) }

  before do
    allow(reference).to receive(:refresh_feedback_token!).and_return('raw_token')
  end

  describe 'Send request reference email' do
    let(:email) { mailer.reference_request_email(reference) }

    it 'sends an email with a link to the reference form' do
      expect(email.body).to include('/reference?token=raw_token')
    end

    it 'sends a request with a Notify reference' do
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'example_env' do
        email.deliver_now
      end

      expect(email[:reference].value).to start_with("example_env-reference_request-#{reference.id}")
    end

    context 'when the new references flow is active' do
      let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1 }
      let(:application_choices) { [create(:application_choice, :with_accepted_offer, course_option:)] }

      before do
        FeatureFlag.activate(:new_references_flow)
      end

      it_behaves_like(
        'a mail with subject and content',
        I18n.t('referee_mailer.reference_request.subject.new', candidate_name: 'Elliot Alderson'),
        'heading' => 'Dear Jane',
        'details' => 'Elliot Alderson has accepted an offer from University of Warwick for a place on a teacher training course',
        'guidance' => 'confirm how you know them and how long you’ve known them for',
        'further guidance' => 'whether you have any concerns about them working with children',
      )

      it 'adds additional guidance for academic references' do
        reference.referee_type = :academic

        expect(email.body).to include('for example about their academic performance')
      end

      it 'adds additional guidance for character references' do
        reference.referee_type = :character

        expect(email.body).to include('for example about activities you’ve done together')
      end

      %i[professional school_based].each do |referee_type|
        it "adds additional guidance for #{referee_type} references" do
          reference.referee_type = referee_type

          expect(email.body).to include('for example about their role and responsibilities at work')
        end
      end
    end
  end

  describe 'Send chasing reference email' do
    let(:email) { mailer.reference_request_chaser_email(application_form, reference) }

    it 'sends an email with a link to the reference form' do
      expect(email.body).to include('/reference?token=raw_token')
    end

    context 'when the new references flow is active' do
      let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1 }
      let(:application_choices) { [create(:application_choice, :with_accepted_offer, course_option:)] }

      before do
        FeatureFlag.activate(:new_references_flow)
      end

      it_behaves_like(
        'a mail with subject and content',
        I18n.t('referee_mailer.reference_request.subject.new', candidate_name: 'Elliot Alderson'),
        'heading' => 'Dear Jane',
        'details' => 'Elliot Alderson has accepted an offer from University of Warwick for a place on a teacher training course',
        'guidance' => 'confirm how you know them and how long you’ve known them for',
        'further guidance' => 'whether you have any concerns about them working with children',
      )
    end
  end

  describe 'Send reference confirmation email' do
    let(:email) { mailer.reference_confirmation_email(application_form, reference) }

    it 'sends an email to the provided referee' do
      expect(email.to).to include(reference.email_address)
    end

    it_behaves_like(
      'a mail with subject and content',
      I18n.t('reference_confirmation_email.subject', candidate_name: 'Elliot Alderson'),
      'heading' => 'Dear Jane',
    )
  end

  describe 'Send reference cancelled email' do
    let(:email) { mailer.reference_cancelled_email(reference) }

    it 'sends an email to the provided referee' do
      expect(email.to).to include(reference.email_address)
    end

    it_behaves_like(
      'a mail with subject and content',
      I18n.t('reference_cancelled_email.subject', candidate_name: 'Elliot Alderson'),
      'heading' => 'Dear Jane',
    )
  end

  describe 'Send reference_request_chase_again_email email' do
    let(:email) { mailer.reference_request_chase_again_email(reference) }

    it 'sends an email to the provided referee' do
      expect(email.to).to include('jane@education.gov.uk')
    end

    it_behaves_like(
      'a mail with subject and content',
      I18n.t('referee_mailer.reference_request.subject.old', candidate_name: 'Elliot Alderson'),
      'heading' => 'Dear Jane',
      'reference link' => '/reference?token=raw_token',
    )

    context 'when the new references flow is active' do
      let(:recruitment_cycle_year) { ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1 }
      let(:application_choices) { [create(:application_choice, :with_accepted_offer, course_option:)] }

      before do
        FeatureFlag.activate(:new_references_flow)
      end

      it_behaves_like(
        'a mail with subject and content',
        I18n.t('referee_mailer.reference_request.subject.new', candidate_name: 'Elliot Alderson'),
        'heading' => 'Dear Jane',
        'details' => 'Elliot Alderson has accepted an offer from University of Warwick for a place on a teacher training course',
        'guidance' => 'confirm how you know them and how long you’ve known them for',
        'further guidance' => 'whether you have any concerns about them working with children',
      )
    end
  end
end
