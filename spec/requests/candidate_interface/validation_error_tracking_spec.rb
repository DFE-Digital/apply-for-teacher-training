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
      commit: t('save_and_continue'),
    }
  end

  def invalid_attributes
    {
      candidate_interface_contact_details_form: {
        phone_number: 'NOT A NUMBER',
      },
      commit: t('save_and_continue'),
    }
  end

  it 'does NOT create validation error when request is valid' do
    expect {
      patch candidate_interface_contact_information_edit_phone_number_url(valid_attributes)
    }.not_to(change { ValidationError.count })
  end

  it 'creates validation error when request is invalid' do
    expect {
      patch candidate_interface_contact_information_edit_phone_number_url(invalid_attributes)
    }.to(change { ValidationError.count }.by(1))
  end
end
