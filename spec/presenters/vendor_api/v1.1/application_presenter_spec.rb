require 'rails_helper'

RSpec.describe VendorAPI::ApplicationPresenter do
  subject(:application_json) { described_class.new(version, application_choice).as_json }

  let(:version) { '1.1' }
  let(:attributes) { application_json[:attributes] }

  describe 'deferred offer' do
    context 'when the offer has been deferred' do
      let(:application_choice) do
        build_stubbed(:application_choice, :with_completed_application_form, :with_deferred_offer)
      end

      it 'returns the fields related to deferring an offer' do
        expect(attributes[:offer]).to include(
          {
            status_before_deferral: application_choice.status_before_deferral,
            offer_deferred_at: application_choice.offer_deferred_at.iso8601,
          },
        )
      end
    end

    context 'when the application is not in the offer state yet' do
      let(:application_choice) do
        build_stubbed(:application_choice, :with_completed_application_form, :awaiting_provider_decision)
      end

      it 'returns nil' do
        expect(attributes[:offer]).to eq(nil)
      end
    end

    context 'when the application has not been deferred' do
      let(:application_choice) do
        build_stubbed(:application_choice, :with_completed_application_form, :with_offer)
      end

      it 'returns the deferred fields with a nil value' do
        expect(attributes[:offer]).to include(
          {
            status_before_deferral: nil,
            offer_deferred_at: nil,
          },
        )
      end
    end
  end
end
