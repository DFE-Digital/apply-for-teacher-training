require 'rails_helper'

RSpec.describe 'ReferencePresenter' do
  subject(:reference_schema) { reference_presenter.new(version, reference, application_accepted: application_accepted).schema }

  let(:reference_presenter) { VendorAPI::ReferencePresenter }
  let(:version) { '1.3' }

  context 'when the reference has not been provided and the application has not been accepted' do
    let(:reference) { create(:reference, :feedback_requested) }
    let(:application_accepted) { false }

    it 'includes the reference received attribute as false' do
      expect(reference_schema).to have_key(:reference_received)
      expect(reference_schema[:reference_received]).to be(false)
    end
  end

  context 'when the reference has been provided and the application has not been accepted' do
    let(:reference) { create(:reference, :feedback_provided) }
    let(:application_accepted) { false }

    it 'includes the reference received attribute as true' do
      expect(reference_schema).to have_key(:reference_received)
      expect(reference_schema[:reference_received]).to be(false)
    end
  end

  context 'when the reference has not been provided and the application has been accepted' do
    let(:reference) { create(:reference, :feedback_requested) }
    let(:application_accepted) { true }

    it 'includes the reference received attribute as false' do
      expect(reference_schema).to have_key(:reference_received)
      expect(reference_schema[:reference_received]).to be(false)
    end
  end

  context 'when the reference has been provided and the application has been accepted' do
    let(:reference) { create(:reference, :feedback_provided) }
    let(:application_accepted) { true }

    it 'includes the reference received attribute as true' do
      expect(reference_schema).to have_key(:reference_received)
      expect(reference_schema[:reference_received]).to be(true)
    end
  end
end
