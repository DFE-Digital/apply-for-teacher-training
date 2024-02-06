require 'rails_helper'

RSpec.describe 'Submit to continuous apps' do
  include Devise::Test::IntegrationHelpers
  let(:choice) { create(:application_choice, :unsubmitted, application_form:) }
  let(:candidate) { application_form.candidate }

  before { sign_in candidate }

  context 'when submitting to current cycle' do
    let(:application_form) { create(:application_form, :completed, submitted_at: nil) }

    before do
      post candidate_interface_continuous_applications_submit_course_choice_path(choice.id)
    end

    it 'be successful' do
      expect(response).to redirect_to(candidate_interface_continuous_applications_choices_path)
      follow_redirect!
      expect(response.body).to include(I18n.t('application_form.submit_application_success.title'))
    end

    it 'changes to awaiting provider decision' do
      expect(choice.reload).to be_awaiting_provider_decision
    end
  end

  context 'when old cycles trying to cheat and submit into the new cycle' do
    let(:application_form) do
      create(:application_form, :completed, submitted_at: nil, recruitment_cycle_year: CycleTimetable.previous_year)
    end

    it 'be successful' do
      post candidate_interface_continuous_applications_submit_course_choice_path(choice.id)
      expect(response).to redirect_to(candidate_interface_start_carry_over_path)
    end

    it 'does not change choice status' do
      expect(choice.reload).to be_unsubmitted
    end
  end
end
