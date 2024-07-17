require 'rails_helper'

RSpec.describe 'ApplicationPresenter' do
  let(:version) { '1.5' }
  let(:application_json) { VendorAPI::ApplicationPresenter.new(version, application_choice).as_json }

  subject(:sent_to_provider_at) { application_json.dig(:attributes, :sent_to_provider_at) }

  describe 'sent_to_provider_at' do
    let(:application_choice) {
      create(:application_choice,
             application_form: create(:application_form, :submitted),
             sent_to_provider_at: DateTime.new(2024, 7, 10, 12, 0))
    }

    it 'returns the date and time the application was sent to the provider' do
      expect(sent_to_provider_at).to eq('2024-07-10T13:00:00+01:00')
    end
  end
end
