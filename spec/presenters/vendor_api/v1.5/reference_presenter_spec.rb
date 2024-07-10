require 'rails_helper'

RSpec.describe 'ReferencePresenter' do
  subject(:reference_schema) { reference_presenter.new(version, reference, application_accepted: application_accepted).schema }

  let(:reference_presenter) { VendorAPI::ReferencePresenter }
  let(:version) { '1.5' }

  context 'when the reference has been provided and the application has been accepted' do
    let(:reference) { create(:reference, :feedback_provided, feedback_provided_at: Time.zone.local(2024, 7, 10, 12, 0)) }
    let(:application_accepted) { true }

    it 'includes the feedback provided at attribute as a timestamp' do
      expect(reference_schema).to have_key(:feedback_provided_at)
      expect(reference_schema[:feedback_provided_at]).to eq('2024-07-10T12:00:00+01:00')
    end
  end

  context 'when the reference has not been provided and the application has not been accepted' do
    let(:reference) { create(:reference, :feedback_requested, feedback_provided_at: Time.zone.local(2024, 7, 10, 12, 0)) }
    let(:application_accepted) { false }

    it 'includes the feedback provided at attribute as nil' do
      expect(reference_schema).to have_key(:feedback_provided_at)
      expect(reference_schema[:feedback_provided_at]).to be_nil
    end
  end

  context 'when the reference has been provided and the application has not been accepted' do
    let(:reference) { create(:reference, :feedback_provided, feedback_provided_at: Time.zone.local(2024, 7, 10, 12, 0)) }
    let(:application_accepted) { false }

    it 'includes the feedback provided at attribute as nil' do
      expect(reference_schema).to have_key(:feedback_provided_at)
      expect(reference_schema[:feedback_provided_at]).to be_nil
    end
  end

  context 'when the reference has not been provided and the application has been accepted' do
    let(:reference) { create(:reference, :feedback_requested, feedback_provided_at: Time.zone.local(2024, 7, 10, 12, 0)) }
    let(:application_accepted) { true }

    it 'includes the feedback provided at attribute as nil' do
      expect(reference_schema).to have_key(:feedback_provided_at)
      expect(reference_schema[:feedback_provided_at]).to be_nil
    end
  end
end
