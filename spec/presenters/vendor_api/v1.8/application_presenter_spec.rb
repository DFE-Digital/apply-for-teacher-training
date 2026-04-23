require 'rails_helper'

RSpec.describe VendorAPI::ApplicationPresenter do
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
