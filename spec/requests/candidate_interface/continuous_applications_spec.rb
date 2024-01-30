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

  context 'when continuous applications' do
    before { create(:application_form, :continuous_applications, candidate:) }

    it 'be successful' do
      continuous_applications_routes.each do |path|
        get path
        expect(response).to be_ok
      end
    end
  end

  context 'when not continuous applications' do
    context 'when submitted' do
      before { create(:application_form, :completed, :pre_continuous_applications, candidate:) }

      it 'redirects to the application complete page' do
        continuous_applications_routes.each do |path|
          get path
          expect(response).to redirect_to(candidate_interface_application_complete_path)
        end
      end
    end

    context 'when unsubmitted' do
      before { create(:application_form, :minimum_info, :pre_continuous_applications, submitted_at: nil, candidate:) }

      it 'redirects to the carry over page' do
        continuous_applications_routes.each do |path|
          get path
          expect(response).to redirect_to(candidate_interface_start_carry_over_path)
        end
      end
    end
  end
end
