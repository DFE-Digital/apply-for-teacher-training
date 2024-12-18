require 'rails_helper'

RSpec.describe VendorAPI::ApplicationPresenter do
  let(:application_json) { described_class.new(version, application_choice).as_json }
  let(:version) { '1.6' }

  describe '#inactive' do
    context 'when the application choice is inactive' do
      let(:application_choice) { create(:application_choice, :inactive) }

      it 'returns the status as inactive' do
        expect(application_json.dig(:attributes, :inactive)).to be(true)
      end
    end
  end

  context 'when the application choice is not inactive' do
    %w[
      awaiting_provider_decision
      offer
      pending_conditions
      recruited
      rejected
      declined
      withdrawn
      conditions_not_met
      offer_deferred
    ].each do |status|
      it "returns the correct status #{status}" do
        application_choice = create(:application_choice, status)
        application_json = described_class.new('1.6', application_choice).as_json
        expect(application_json.dig(:attributes, :inactive)).to be(false)
      end
    end
  end
end
