require 'rails_helper'

RSpec.describe VendorAPI::ApplicationPresenter do
  include Rails.application.routes.url_helpers

  let(:application_json) { described_class.new(version, application_choice).as_json }
  let(:version) { '1.7' }

  describe 'possible_undeclared_previous_teacher_training_details_url' do
    context 'when the candidate has possible undeclared previous teacher training' do
      let(:candidate) { create(:candidate) }
      let(:application_form) { create(:application_form, :submitted, candidate:) }
      let!(:possible_previous_teacher_training) do
        create(:possible_previous_teacher_training, candidate:)
      end
      let(:application_choice) { create(:application_choice, application_form:) }

      it 'includes the possible undeclared previous teacher training details URL in the JSON response' do
        expect(application_json.dig(:attributes, :possible_undeclared_previous_teacher_training_details_url)).to eq(provider_interface_application_choice_url(application_choice, anchor: 'previous_teacher_trainings'))
      end
    end

    context 'when the candidate does not have possible undeclared previous teacher training' do
      let(:candidate) { create(:candidate) }
      let(:application_form) { create(:application_form, :submitted, candidate:) }
      let(:application_choice) { create(:application_choice, application_form:) }

      it 'does not include the possible undeclared previous teacher training details URL in the JSON response' do
        expect(application_json.dig(:attributes, :possible_undeclared_previous_teacher_training_details_url)).to be_nil
      end
    end
  end

  describe '#api_application_states' do
    context 'when version is 1.7 or above' do
      let(:application_choice) { create(:application_choice, :interviewing) }

      it 'returns the correct mapping for interviewing' do
        expect(application_json.dig(:attributes, :status)).to eq('interviewing')
      end
    end

    context 'when version is 1.6 or below' do
      let(:version) { '1.6' }

      let(:application_choice) { create(:application_choice, :interviewing) }

      it 'returns the correct mapping for interviewing' do
        application_json = described_class.new(version, application_choice).as_json
        expect(application_json.dig(:attributes, :status)).to eq('awaiting_provider_decision')
      end
    end
  end
end
