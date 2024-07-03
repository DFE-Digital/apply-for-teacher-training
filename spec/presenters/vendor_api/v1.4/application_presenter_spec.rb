require 'rails_helper'

RSpec.describe 'ApplicationPresenter' do
  let(:application_presenter) { VendorAPI::ApplicationPresenter }
  let(:version) { '1.4' }
  let(:application_json) { application_presenter.new(version, application_choice).as_json }
  let(:attributes) { application_json[:attributes] }
  let(:application_form) { create(:application_form, :submitted) }
  let(:application_choice) { create(:application_choice, application_form:) }

  describe 'qualifications' do
    context 'when the application has a other_uk_qualification_type qualification' do
      subject(:other_qualification) { attributes[:qualifications][:other_qualifications].first }

      before do
        create(
          :other_qualification,
          other_uk_qualification_type: 'Equivalency test',
          application_form: application_form,
        )
      end

      it 'returns the correct other_uk_qualification_type field' do
        expect(other_qualification[:other_uk_qualification_type]).to eq 'Equivalency test'
        expect(other_qualification).not_to have_key(:currently_completing_qualification)
        expect(other_qualification).not_to have_key(:missing_explanation)
      end
    end

    context 'when the application has a missing_and_currently_completing GCSE' do
      subject(:gcse) { attributes[:qualifications][:gcses].first }

      before do
        create(
          :gcse_qualification,
          currently_completing_qualification: true,
          missing_explanation: 'I will be taking an equivalency test in a few weeks',
          other_uk_qualification_type: 'Equivalency test',
          application_form: application_form,
        )
      end

      it 'returns the correct GCSEs fields' do
        expect(gcse[:currently_completing_qualification]).to be true
        expect(gcse[:missing_explanation]).to eq 'I will be taking an equivalency test in a few weeks'
        expect(gcse[:other_uk_qualification_type]).to eq 'Equivalency test'
      end
    end
  end
end
