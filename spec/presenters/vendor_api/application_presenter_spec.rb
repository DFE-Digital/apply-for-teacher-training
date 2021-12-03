require 'rails_helper'

RSpec.describe VendorAPI::ApplicationPresenter do
  let(:application_json) { described_class.new(application_choice).as_json }
  let(:attributes) { application_json[:attributes] }
  let(:application_form) { create(:application_form, :minimum_info) }

  describe 'compliance with models that change updated_at' do
    let(:non_uk_application_form) do
      create(:application_form,
             :minimum_info,
             first_nationality: 'Spanish',
             right_to_work_or_study: :yes,
             address_type: :international,
             address_line1: nil)
    end
    let(:non_uk_application_choice) { create(:submitted_application_choice, application_form: non_uk_application_form) }
    let(:application_choice) { create(:submitted_application_choice, :with_completed_application_form) }

    it 'looks at all fields which cause a touch' do
      ApplicationForm::PUBLISHED_FIELDS.each do |field|
        allow(non_uk_application_form).to receive(field).and_call_original
        allow(application_choice.application_form).to receive(field).and_call_original
      end

      described_class.new(application_choice).serialized_json
      described_class.new(non_uk_application_choice).serialized_json

      (ApplicationForm::PUBLISHED_FIELDS - %w[postcode equality_and_diversity]).each do |field|
        expect(non_uk_application_form).to have_received(field).at_least(:once)
      end

      (ApplicationForm::PUBLISHED_FIELDS - %w[international_address right_to_work_or_study_details equality_and_diversity]).each do |field|
        expect(application_choice.application_form).to have_received(field).at_least(:once)
      end
    end

    it 'doesn’t depend on any fields that don’t cause a touch' do
      (ApplicationForm.attribute_names - %w[id created_at updated_at] - ApplicationForm::PUBLISHED_FIELDS).each do |field|
        allow(non_uk_application_form).to receive(field).and_call_original
        allow(application_choice.application_form).to receive(field).and_call_original
      end

      described_class.new(application_choice).serialized_json
      described_class.new(application_choice).serialized_json

      (ApplicationForm.attribute_names - %w[id created_at updated_at] - ApplicationForm::PUBLISHED_FIELDS).each do |field|
        expect(non_uk_application_form).not_to have_received(field)
        expect(application_choice.application_form).not_to have_received(field)
      end
    end
  end

  describe '#as_json' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form: application_form) }

    it 'caches the resulting hash with a specific key' do
      allow(FeatureFlag).to receive(:feature_statuses).and_return({})
      allow(Rails.cache).to receive(:fetch)
      described_class.new(application_choice).as_json

      expect(Rails.cache).to have_received(:fetch).with(CacheKey.generate("#{application_choice.cache_key_with_version}as_json"), expires_in: 1.day)
    end
  end

  describe '#serialized_json' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form: application_form) }

    it 'returns a valid JSON string' do
      serialized_json = described_class.new(application_choice).serialized_json
      expect(serialized_json).to be_a(String)
      expect(JSON.parse(serialized_json)['attributes']).to be_a(Hash)
    end

    it 'caches the serialized JSON string' do
      allow(FeatureFlag).to receive(:feature_statuses).and_return({})
      allow(Rails.cache).to receive(:fetch)

      described_class.new(application_choice).serialized_json

      expect(Rails.cache)
        .to have_received(:fetch).with(CacheKey.generate(application_choice.cache_key_with_version), expires_in: 1.day)
    end
  end

  describe '#status' do
    context 'when the application status is order_withdrawn' do
      let!(:application_choice) { create(:submitted_application_choice, :offer_withdrawn, :with_completed_application_form) }

      it 'returns rejected' do
        expect(attributes[:status]).to eq('rejected')
      end
    end

    context 'when the application status is interviewing' do
      let!(:application_choice) { create(:submitted_application_choice, :interviewing, :with_completed_application_form) }

      it 'returns awaiting_provider_decision' do
        expect(attributes[:status]).to eq('awaiting_provider_decision')
      end
    end

    context 'when the application status is any other status' do
      let!(:application_choice) { create(:submitted_application_choice, :offer, :with_completed_application_form) }

      it 'returns the existing status' do
        expect(attributes[:status]).to eq('offer')
      end
    end
  end

  describe '#personal_statement' do
    let!(:application_choice) { create(:submitted_application_choice, :offer_withdrawn, :with_completed_application_form) }

    it 'formats and returns the personal statement information' do
      personal_statement = "Why do you want to become a teacher?: #{application_choice.application_form.becoming_a_teacher} \n " \
                           "What is your subject knowledge?: #{application_choice.application_form.subject_knowledge}"

      expect(attributes[:personal_statement]).to eq(personal_statement)
    end
  end

  describe '#withdrawal' do
    let(:withdrawn_at) { Time.zone.local(2019, 1, 1, 0, 0, 0) }
    let!(:application_choice) { create(:application_choice, :withdrawn, application_form: application_form, withdrawn_at: withdrawn_at) }

    it 'returns a withdrawal object' do
      expect(attributes[:withdrawal]).to eq({ reason: nil, date: withdrawn_at.iso8601 })
    end
  end

  describe '#rejection' do
    let(:rejected_at) { Time.zone.local(2019, 1, 1, 0, 0, 0) }
    let!(:application_choice) { create(:application_choice, :rejected, application_form: application_form, rejected_at: rejected_at, rejection_reason: 'Course full') }

    it 'returns a rejection object' do
      expect(attributes[:rejection]).to eq({ reason: 'Course full', date: rejected_at.iso8601 })
    end

    it 'returns a rejection object with a truncated reason when the character limit is exceeded' do
      application_choice.rejection_reason = 'Course full' * 65000
      allow(Sentry).to receive(:capture_message)

      application_json

      expect(Sentry).to have_received(:capture_message).with("Rejection.properties.reason truncated for application with id #{application_choice.id} as length exceeded 65535 chars")

      expect(attributes[:rejection][:reason].length).to be(65535)
      expect(attributes[:rejection][:reason]).to end_with(described_class::OMISSION_TEXT)
      expect(attributes[:rejection][:date]).to eq(rejected_at.iso8601)
    end

    context 'when there is a withdrawn offer' do
      let(:withdrawn_at) { Time.zone.local(2019, 1, 1, 0, 0, 0) }
      let(:application_choice) { create(:application_choice, :rejected, application_form: application_form, offer_withdrawn_at: withdrawn_at, offer_withdrawal_reason: 'Course full') }

      it 'returns a rejection object' do
        expect(attributes[:rejection]).to eq({ reason: 'Course full', date: withdrawn_at.iso8601 })
      end
    end

    context 'when there is no feedback' do
      let(:application_choice) { create(:application_choice, :with_rejection_by_default, application_form: application_form, rejected_at: rejected_at) }

      it 'returns a rejection object with a custom rejection reason' do
        expect(attributes[:rejection]).to eq({ reason: 'Not entered', date: rejected_at.iso8601 })
      end
    end
  end

  describe '#contact_details' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form: application_form) }
    let(:application_form) { create(:application_form, :minimum_info, application_form_attributes) }
    let(:application_form_attributes) do
      {
        phone_number: '07700 900 982',
        address_line1: '42',
        address_line2: 'Much Wow Street',
        address_line3: 'London',
        address_line4: 'England',
        country: 'GB',
        postcode: 'SW1P 3BT',
      }
    end

    context 'for UK addresses' do
      it 'returns contact details in correct format' do
        expected_contact_details = application_form_attributes.merge(email: application_form.candidate.email_address)

        expect(attributes[:contact_details]).to eq(expected_contact_details)
      end
    end

    context 'for international addresses' do
      let(:application_form_attributes) do
        {
          phone_number: '07700 900 982',
          address_type: 'international',
          address_line1: '456 Marine Drive',
          address_line2: 'Mumbai',
          address_line3: nil,
          address_line4: nil,
          international_address: '456 Marine Drive, Mumbai',
          country: 'IN',
        }
      end

      it 'returns contact details in correct format' do
        expected_contact_details = {
          phone_number: '07700 900 982',
          address_line1: '456 Marine Drive',
          address_line2: 'Mumbai',
          address_line3: nil,
          address_line4: nil,
          country: 'IN',
        }.merge(email: application_form.candidate.email_address)

        expect(attributes[:contact_details]).to eq(expected_contact_details)
      end
    end

    context 'if no address lines are populated' do
      let(:application_form_attributes) do
        {
          phone_number: '07700 900 982',
          address_type: 'international',
          international_address: '456 Marine Drive, Mumbai',
          address_line1: nil,
          address_line2: nil,
          address_line3: nil,
          address_line4: nil,
          country: 'IN',
        }
      end

      it 'presents the international_address field' do
        expect(attributes[:contact_details]).to eq({
          phone_number: '07700 900 982',
          address_line1: '456 Marine Drive, Mumbai',
          address_line2: nil,
          address_line3: nil,
          address_line4: nil,
          country: 'IN',
          email: application_form.candidate.email_address,
        })
      end
    end
  end

  describe '#references' do
    let(:application_choice) { create(:application_choice, :with_completed_application_form, :with_offer) }

    context 'retrieving references', wip: true do
      let!(:with_feedback_and_selected) { create(:selected_reference, application_form: application_choice.application_form) }
      let!(:with_feedback_but_not_selected) { create(:reference, :feedback_provided, application_form: application_choice.application_form) }
      let!(:refused) { create(:reference, :feedback_refused, application_form: application_choice.application_form) }

      it 'returns references with feedback selected by the candidate', wip: true do
        expect(attributes[:references].map { |reference| reference[:id] }).to include(with_feedback_and_selected.id)
        expect(attributes[:references].map { |reference| reference[:id] }).not_to include(with_feedback_but_not_selected.id)
        expect(attributes[:references].map { |reference| reference[:id] }).not_to include(refused.id)
      end
    end

    context 'safeguarding concerns' do
      before do
        create(:selected_reference, :has_safeguarding_concerns_to_declare, application_form: application_choice.application_form)
        create(:selected_reference, :no_safeguarding_concerns_to_declare, application_form: application_choice.application_form)
      end

      it 'are mapped on the reference object' do
        expect(attributes[:references].map { |reference| reference[:safeguarding_concerns] })
          .to match_array [true, false]
      end
    end
  end

  describe '#offer' do
    context 'when there is no offer' do
      let(:application_choice) { create(:application_choice, :with_completed_application_form, :awaiting_provider_decision) }

      it 'returns nil' do
        expect(attributes[:offer]).to be_nil
      end
    end

    context 'when there is an offer' do
      let(:application_choice) { create(:application_choice, :with_completed_application_form, :with_offer) }

      it 'includes an offer_made_at date for offers' do
        expect(attributes[:offer][:offer_made_at]).to be_present
      end

      it 'includes the offered course' do
        expect(attributes[:offer][:course][:course_code]).to eq(application_choice.current_course_option.course.code)
      end
    end

    context 'when there is an accepted offer' do
      let(:application_choice) { create(:application_choice, :with_completed_application_form, :with_accepted_offer) }

      it 'includes an accepted_at date for accepted offers' do
        expect(attributes[:offer][:offer_accepted_at]).to be_present
      end
    end

    context 'when there is a declined offer' do
      let(:application_choice) { create(:application_choice, :with_completed_application_form, :with_declined_offer) }

      it 'includes a declined_at date for declined offers' do
        expect(attributes[:offer][:offer_declined_at]).to be_present
      end
    end
  end

  describe '#safeguarding_issues_status' do
    let(:application_form) { create(:application_form, :minimum_info, :with_safeguarding_issues_disclosed) }
    let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form: application_form) }

    it 'returns the safeguarding issues status' do
      expect(attributes[:safeguarding_issues_status]).to eq('has_safeguarding_issues_to_declare')
    end
  end

  describe '#safeguarding_issues_details_url' do
    let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form: application_form) }

    context 'if the status is has_safeguarding_issues_to_declare' do
      let(:application_form) { create(:application_form, :minimum_info, :with_safeguarding_issues_disclosed) }

      it 'returns the url' do
        expect(attributes[:safeguarding_issues_details_url])
          .to include("/provider/applications/#{application_choice.id}#criminal-convictions-and-professional-misconduct")
      end
    end

    context 'if the status is no_safeguarding_issues_to_declare' do
      it 'returns nil' do
        expect(attributes[:safeguarding_issues_details_url]).to eq(nil)
      end
    end

    context 'if the status is never_asked' do
      let(:application_form) { create(:application_form, :minimum_info, :with_safeguarding_issues_never_asked) }

      it 'returns nil' do
        expect(attributes[:safeguarding_issues_details_url]).to eq(nil)
      end
    end
  end

  describe '#recruited_at' do
    let!(:application_choice) { create(:application_choice, :with_completed_application_form, :with_recruited) }

    it 'includes the date the candidate was recruited' do
      expect(attributes[:recruited_at]).not_to be_nil
    end
  end
end
