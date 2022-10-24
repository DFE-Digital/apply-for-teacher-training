require 'rails_helper'

RSpec.describe 'Candidate Interface - Redirects acepted offer' do
  include Devise::Test::IntegrationHelpers
  let(:candidate) { create(:candidate) }

  before { sign_in candidate }

  context 'when candidate accepted an offer' do
    context 'when new references is active and cycle year is 2023' do
      before do
        FeatureFlag.activate(:new_references_flow)
      end

      it 'redirects to the post offer dashboard' do
        application_form = create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: 2023, candidate:)
        create(:application_choice, :with_accepted_offer, application_form:)
        create(:application_choice, :with_withdrawn_offer, application_form:)
        create(:application_choice, :with_withdrawn_offer, application_form:)
        get candidate_interface_application_complete_path
        expect(response).to redirect_to(candidate_interface_application_offer_dashboard_path)
      end
    end

    context 'when new references is active and cycle year is 2022' do
      before do
        FeatureFlag.activate(:new_references_flow)
      end

      it 'redirects to the post offer dashboard' do
        application_form = create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: 2022, candidate:)
        create(:application_choice, :with_accepted_offer, application_form:)
        create(:application_choice, :with_withdrawn_offer, application_form:)
        create(:application_choice, :with_withdrawn_offer, application_form:)
        get candidate_interface_application_complete_path
        expect(response).not_to redirect_to(candidate_interface_application_offer_dashboard_path)
      end
    end

    context 'when new references is not active' do
      before do
        FeatureFlag.deactivate(:new_references_flow)
      end

      it 'does not redirect to the post offer dashboard' do
        application_form = create(:application_form, recruitment_cycle_year: 2022, candidate:)
        create(:application_choice, :with_accepted_offer, application_form:)
        create(:application_choice, :with_withdrawn_offer, application_form:)
        create(:application_choice, :with_withdrawn_offer, application_form:)
        get candidate_interface_application_complete_path
        expect(response).not_to redirect_to(candidate_interface_application_offer_dashboard_path)
      end
    end
  end
end
