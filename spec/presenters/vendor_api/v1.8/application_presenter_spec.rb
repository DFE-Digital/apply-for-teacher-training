require 'rails_helper'

RSpec.describe VendorAPI::ApplicationPresenter do
  describe 'english language qualification' do
    context 'candidate intends to gain english language qualification' do
      describe '#attributes' do
        it 'returns correct response' do
          application_form = create(:application_form, :submitted)
          _english_proficiency = create(
            :english_proficiency,
            :no_qualification,
            no_qualification_details: 'I will take it next year',
            draft: false,
            application_form:,
          )
          application_choice = create(:application_choice, application_form:)
          result = described_class.new('1.8', application_choice).as_json

          expect(result.dig(:attributes, :candidate, :will_obtain_english_language_qualifications)).to be(true)
          expect(result.dig(:attributes, :candidate, :obtaining_english_language_qualification_details)).to eq(
            'I will take it next year',
          )
        end
      end
    end

    context 'candidate does not intend to gain english language qualification' do
      describe '#attributes' do
        it 'returns correct response' do
          application_form = create(:application_form, :submitted)
          _english_proficiency = create(
            :english_proficiency,
            :no_qualification,
            draft: false,
            application_form:,
          )
          application_choice = create(:application_choice, application_form:)
          result = described_class.new('1.8', application_choice).as_json

          expect(result.dig(:attributes, :candidate, :will_obtain_english_language_qualifications)).to be(false)
          expect(result.dig(:attributes, :candidate, :obtaining_english_language_qualification_details)).to be_nil
        end
      end
    end
  end

  describe 'visa expiry' do
    let(:visa_expired_at) { 1.year.from_now }

    context 'candidate does not have a visa' do
      describe '#attributes' do
        it 'does not return the visa expiry date or details' do
          application_form = create(:application_form, :submitted)
          application_choice = create(:application_choice, application_form:)
          result = described_class.new('1.8', application_choice).as_json

          expect(result.dig(:attributes, :candidate, :visa_expired_at)).to be_nil
          expect(result.dig(:attributes, :candidate, :visa_explanation)).to be_nil
          expect(result.dig(:attributes, :candidate, :visa_explanation_details)).to be_nil
        end
      end
    end

    context 'candidate has a visa which will expire' do
      describe '#attributes' do
        it 'returns the visa expiry date' do
          application_form = create(:application_form, :submitted, visa_expired_at:)
          application_choice = create(:application_choice, application_form:)
          result = described_class.new('1.8', application_choice).as_json

          expect(result.dig(:attributes, :candidate, :visa_expired_at)).to eq(visa_expired_at.iso8601)
        end
      end
    end

    context 'candidate has explained their plan to review their visa' do
      describe '#attributes' do
        it 'returns the visa explanation' do
          application_form = create(:application_form, :submitted, visa_expired_at:)
          application_choice = create(:application_choice, application_form:, visa_explanation: 'expires_after_course')
          result = described_class.new('1.8', application_choice).as_json

          expect(result.dig(:attributes, :candidate, :visa_expired_at)).to eq(visa_expired_at.iso8601)
          expect(result.dig(:attributes, :candidate, :visa_explanation)).to eq('expires_after_course')
          expect(result.dig(:attributes, :candidate, :visa_explanation_details)).to be_nil
        end
      end
    end

    context 'candidate has declared their plan to review their visa as "other"' do
      describe '#attributes' do
        it 'returns the visa explanation details' do
          application_form = create(:application_form, :submitted, visa_expired_at:)
          application_choice = create(
            :application_choice,
            application_form:,
            visa_explanation: 'other',
            visa_explanation_details: 'Work in progress',
          )
          result = described_class.new('1.8', application_choice).as_json

          expect(result.dig(:attributes, :candidate, :visa_expired_at)).to eq(visa_expired_at.iso8601)
          expect(result.dig(:attributes, :candidate, :visa_explanation)).to eq('other')
          expect(result.dig(:attributes, :candidate, :visa_explanation_details)).to eq('Work in progress')
        end
      end
    end
  end

  describe 'length of country residency' do
    context 'candidate does not declare their length of country residency' do
      describe '#attributes' do
        it 'does not return the country residency details' do
          application_form = create(:application_form, :submitted)
          application_choice = create(:application_choice, application_form:)
          result = described_class.new('1.8', application_choice).as_json

          expect(result.dig(:attributes, :candidate, :country_residency_date_from)).to be_nil
          expect(result.dig(:attributes, :candidate, :country_residency_since_birth)).to be_nil
        end
      end
    end

    context 'candidate has been a resident of their country since birth' do
      let(:country_residency_date_from) { 24.years.ago }

      describe '#attributes' do
        it 'return the country residency details' do
          application_form = create(
            :application_form,
            :submitted,
            country_residency_date_from:,
            country_residency_since_birth: true,
          )
          application_choice = create(:application_choice, application_form:)
          result = described_class.new('1.8', application_choice).as_json

          expect(result.dig(:attributes, :candidate, :country_residency_date_from)).to eq(country_residency_date_from.iso8601)
          expect(result.dig(:attributes, :candidate, :country_residency_since_birth)).to be(true)
        end
      end
    end

    context 'candidate has not been a resident of their country since birth' do
      let(:country_residency_date_from) { 2.years.ago }

      describe '#attributes' do
        it 'return the country residency details' do
          application_form = create(
            :application_form,
            :submitted,
            country_residency_date_from:,
            country_residency_since_birth: false,
          )
          application_choice = create(:application_choice, application_form:)
          result = described_class.new('1.8', application_choice).as_json

          expect(result.dig(:attributes, :candidate, :country_residency_date_from)).to eq(country_residency_date_from.iso8601)
          expect(result.dig(:attributes, :candidate, :country_residency_since_birth)).to be(false)
        end
      end
    end
  end
end
