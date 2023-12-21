require 'rails_helper'

RSpec.describe 'ApplicationPresenter' do
  let(:application_presenter) { VendorAPI::ApplicationPresenter }
  let(:version) { '1.4' }
  let(:application_json) { application_presenter.new(version, application_choice).as_json }
  let(:attributes) { application_json[:attributes] }
  let(:application_form) { create(:application_form, :submitted) }
  let(:application_choice) { create(:application_choice, application_form:) }

  describe '#GCSEs' do
    subject(:gcse) { attributes[:qualifications][:gcses].first }

    context 'when the application has a missing_and_currently_completing qualification' do
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
