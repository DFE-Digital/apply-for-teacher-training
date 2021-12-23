require 'rails_helper'

RSpec.describe VendorAPI::ApplicationPresenter do
  let(:version) { '1.0' }
  let(:application_json) { described_class.new(version, application_choice).as_json }
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

      described_class.new(version, application_choice).serialized_json
      described_class.new(version, non_uk_application_choice).serialized_json

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

      described_class.new(version, application_choice).serialized_json
      described_class.new(version, application_choice).serialized_json

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
      described_class.new(version, application_choice).as_json

      expect(Rails.cache).to have_received(:fetch).with(CacheKey.generate("#{application_choice.cache_key_with_version}as_json"), expires_in: 1.day)
    end
  end

  describe '#serialized_json' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form: application_form) }

    it 'returns a valid JSON string' do
      serialized_json = described_class.new(version, application_choice).serialized_json
      expect(serialized_json).to be_a(String)
      expect(JSON.parse(serialized_json)['attributes']).to be_a(Hash)
    end

    it 'caches the serialized JSON string' do
      allow(FeatureFlag).to receive(:feature_statuses).and_return({})
      allow(Rails.cache).to receive(:fetch)

      described_class.new(version, application_choice).serialized_json

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
