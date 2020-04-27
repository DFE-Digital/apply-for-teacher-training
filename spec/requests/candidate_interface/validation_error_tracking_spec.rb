require 'rails_helper'

RSpec.describe 'Candidate interface - validation error tracking', type: :request do
  include Devise::Test::IntegrationHelpers

  def candidate
    @candidate ||= create :candidate
  end

  before { sign_in candidate }

  def valid_attributes
    {
      candidate_interface_contact_details_form: {
        phone_number: '01234 567890',
      },
      commit: 'Save and continue',
    }
  end

  def invalid_attributes
    {
      candidate_interface_contact_details_form: {
        phone_number: 'NOT A NUMBER',
      },
      commit: 'Save and continue',
    }
  end

  context 'when feature flag is NOT enabled' do
    it 'does NOT create validation error when request is valid' do
      expect {
        post candidate_interface_contact_details_update_base_url(valid_attributes)
      }.not_to(change { ValidationError.count })
    end

    it 'does NOT create validation error when request is invalid' do
      expect {
        post candidate_interface_contact_details_update_base_url(invalid_attributes)
      }.not_to(change { ValidationError.count })
    end
  end

  context 'when feature flag is enabled' do
    before do
      FeatureFlag.activate('track_validation_errors')
    end

    it 'does NOT create validation error when request is valid' do
      expect {
        post candidate_interface_contact_details_update_base_url(valid_attributes)
      }.not_to(change { ValidationError.count })
    end

    it 'creates validation error when request is invalid' do
      expect {
        post candidate_interface_contact_details_update_base_url(invalid_attributes)
      }.to(change { ValidationError.count }.by(1))
    end
  end
end
