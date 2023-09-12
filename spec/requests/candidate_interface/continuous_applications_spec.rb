require 'rails_helper'

RSpec.describe 'continuous applications' do
  include Devise::Test::IntegrationHelpers
  let(:candidate) { create(:candidate) }
  let(:continuous_applications_routes) do
    [
      candidate_interface_continuous_applications_details_path,
      candidate_interface_continuous_applications_choices_path,
    ]
  end

  before { sign_in candidate }

  context 'when continuous applications', :continuous_applications do
    it 'be successful' do
      continuous_applications_routes.each do |path|
        get path
        expect(response).to be_ok
      end
    end
  end

  context 'when not continuous applications', continuous_applications: false do
    it 'be not found' do
      continuous_applications_routes.each do |path|
        get path
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
