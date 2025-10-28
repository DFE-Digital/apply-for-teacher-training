require 'rails_helper'

RSpec.describe 'ApplicationPresenter' do
  let(:version) { '1.0' }
  let(:application_presenter) { VendorAPI::ApplicationPresenter }
  let(:application_json) { application_presenter.new(version, application_choice).as_json }
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
    let(:non_uk_application_choice) { create(:application_choice, :awaiting_provider_decision, application_form: non_uk_application_form) }
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, :with_completed_application_form) }

    let(:non_uk_fields) do
      ApplicationForm::PUBLISHED_FIELDS - %w[becoming_a_teacher postcode equality_and_diversity immigration_status]
    end
    let(:uk_fields) do
      ApplicationForm::PUBLISHED_FIELDS - %w[becoming_a_teacher international_address right_to_work_or_study_details equality_and_diversity immigration_status]
    end

    it 'looks at all fields which cause a touch' do
      ApplicationForm::PUBLISHED_FIELDS.each do |field|
        allow(non_uk_application_form).to receive(field).and_call_original
        allow(application_choice.application_form).to receive(field).and_call_original
      end

      application_presenter.new(version, application_choice).serialized_json
      application_presenter.new(version, non_uk_application_choice).serialized_json

      non_uk_fields.each do |field|
        expect(non_uk_application_form).to have_received(field).at_least(:once)
      end

      uk_fields.each do |field|
        expect(application_choice.application_form).to have_received(field).at_least(:once)
      end
    end

    # recruitment_cycle_year added to method expectations because we must call it on the form to check for continuous applications
    it 'doesn’t depend on any fields that don’t cause a touch', :aggregate_failures do
      (ApplicationForm.attribute_names - %w[id created_at updated_at recruitment_cycle_year] - ApplicationForm::PUBLISHED_FIELDS).each do |field|
        allow(non_uk_application_form).to receive(field).and_call_original
        allow(application_choice.application_form).to receive(field).and_call_original
      end

      application_presenter.new(version, application_choice).serialized_json
      application_presenter.new(version, application_choice).serialized_json

      (ApplicationForm.attribute_names - %w[id created_at updated_at recruitment_cycle_year] - ApplicationForm::PUBLISHED_FIELDS).each do |field|
        expect(non_uk_application_form).not_to have_received(field)
        expect(application_choice.application_form).not_to have_received(field)
      end
    end
  end

  describe '#as_json' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form:) }

    it 'caches the resulting hash with a specific key' do
      allow(FeatureFlag).to receive(:feature_statuses).and_return({})
      allow(Rails.cache).to receive(:fetch)
      application_presenter.new(version, application_choice).as_json
      expected_key = "vendor_api-1.0-#{application_choice.cache_key_with_version}-as_json"

      expect(Rails.cache).to have_received(:fetch).with(expected_key, expires_in: 1.day)
    end
  end

  describe '#serialized_json' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form:) }

    it 'returns a valid JSON string' do
      serialized_json = application_presenter.new(version, application_choice).serialized_json
      expect(serialized_json).to be_a(String)
      expect(JSON.parse(serialized_json)['attributes']).to be_a(Hash)
    end

    it 'caches the serialized JSON string' do
      allow(FeatureFlag).to receive(:feature_statuses).and_return({})
      allow(Rails.cache).to receive(:fetch)
      application_presenter.new(version, application_choice).serialized_json
      expected_key = "vendor_api-1.0-#{application_choice.cache_key_with_version}"

      expect(Rails.cache).to have_received(:fetch).with(expected_key, expires_in: 1.day)
    end
  end

  describe '#status' do
    context 'when the application status is order_withdrawn' do
      let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, :with_completed_application_form, :offer_withdrawn) }

      it 'returns rejected' do
        expect(attributes[:status]).to eq('rejected')
      end
    end

    context 'when the application status is interviewing' do
      let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, :interviewing, :with_completed_application_form) }

      it 'returns awaiting_provider_decision' do
        expect(attributes[:status]).to eq('awaiting_provider_decision')
      end
    end

    context 'when the application status is any other status' do
      let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, :with_completed_application_form, :offered) }

      it 'returns the existing status' do
        expect(attributes[:status]).to eq('offer')
      end
    end
  end

  describe '#personal_statement' do
    let(:choice_personal_statement) { 'choice statement' }
    let(:application_choice) { create(:application_choice, :with_completed_application_form, personal_statement: choice_personal_statement) }

    it 'returns the choice personal statement' do
      expect(attributes[:personal_statement]).to eq(choice_personal_statement)
    end
  end

  describe '#references' do
    context 'when accepted offer' do
      let(:application_choice) do
        create(:application_choice, :with_completed_application_form, :accepted)
      end
      let!(:reference) do
        create(:reference, :feedback_provided, application_form: application_choice.application_form)
      end

      it 'returns references' do
        expect(
          attributes[:references].map { |reference| reference[:id] },
        ).to include(reference.id)
      end

      it 'does not return any reference status' do
        expect(
          attributes[:references].map { |reference| reference[:status] },
        ).to all(be_nil)
      end
    end

    context 'when pre offer' do
      let(:application_choice) do
        create(:application_choice, :with_completed_application_form, :offered)
      end
      let!(:reference) do
        create(:reference, application_form: application_choice.application_form)
      end

      it 'returns empty references' do
        expect(attributes[:references]).to eq([])
      end
    end
  end

  describe '#safeguarding_issues_status' do
    let(:application_form) { create(:application_form, :minimum_info, :with_safeguarding_issues_disclosed) }
    let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form:) }

    it 'returns the safeguarding issues status' do
      expect(attributes[:safeguarding_issues_status]).to eq('has_safeguarding_issues_to_declare')
    end
  end

  describe '#safeguarding_issues_details_url' do
    let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form:) }

    context 'if the status is has_safeguarding_issues_to_declare' do
      let(:application_form) { create(:application_form, :minimum_info, :with_safeguarding_issues_disclosed) }

      it 'returns the url' do
        expect(attributes[:safeguarding_issues_details_url])
          .to include("/provider/applications/#{application_choice.id}#criminal-convictions-and-professional-misconduct")
      end
    end

    context 'if the status is no_safeguarding_issues_to_declare' do
      it 'returns nil' do
        expect(attributes[:safeguarding_issues_details_url]).to be_nil
      end
    end

    context 'if the status is never_asked' do
      let(:application_form) { create(:application_form, :minimum_info, :with_safeguarding_issues_never_asked) }

      it 'returns nil' do
        expect(attributes[:safeguarding_issues_details_url]).to be_nil
      end
    end
  end

  describe '#recruited_at' do
    let!(:application_choice) { create(:application_choice, :with_completed_application_form, :recruited) }

    it 'includes the date the candidate was recruited' do
      expect(attributes[:recruited_at]).not_to be_nil
    end
  end

  describe 'compound ISO-3166 country codes' do
    let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form:) }
    let(:application_form) { create(:application_form, :minimum_info, :international_address, country: 'AE-AZ') }

    it 'returns domicile HESA code for unknown' do
      expect(attributes[:candidate][:domicile]).to eq('ZZ')
    end

    it 'returns a 2 character code for country' do
      expect(attributes[:contact_details][:country]).to eq('AE')
    end
  end

  describe '#anonymised' do
    let!(:application_choice) { create(:application_choice, :with_completed_application_form) }

    context 'when the application has been deleted' do
      it 'returns true' do
        application_choice.application_form.candidate.update!(email_address: "deleted-application-#{application_choice.application_form.support_reference}@example.com")
        expect(attributes[:anonymised]).to be true
      end
    end

    context 'when the application has not been deleted' do
      it 'returns false' do
        expect(attributes[:anonymised]).to be false
      end
    end
  end
end
