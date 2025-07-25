require 'rails_helper'

RSpec.describe 'Redirects when reviewing before submission' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }

  before do
    sign_in candidate
  end

  context 'when the application choice is submitted' do
    it 'redirects to application choices' do
      application_form = create(:completed_application_form, candidate:)
      application_choice = create(:application_choice, :awaiting_provider_decision, application_form:)
      get candidate_interface_course_choices_course_review_and_submit_path(application_choice.id)
      expect(response).to redirect_to(candidate_interface_application_choices_path)
    end
  end

  context 'when the application is not ready to submit', time: mid_cycle do
    it 'redirects to reviews course choice' do
      application_form = create(:application_form, :minimum_info, candidate:)
      application_choice = create(:application_choice, :unsubmitted, application_form:)
      get candidate_interface_course_choices_course_review_and_submit_path(application_choice.id)
      expect(response).to redirect_to(candidate_interface_course_choices_course_review_path(application_choice.id))
    end
  end

  context 'when the application is not ready to submit and the deadline passes', time: mid_cycle do
    it 'redirects to reviews course choice' do
      application_form = create(:application_form, :minimum_info, candidate:)
      application_choice = create(:application_choice, :unsubmitted, application_form:)
      travel_temporarily_to(after_apply_deadline) do
        get candidate_interface_course_choices_course_review_and_submit_path(application_choice.id)
        expect(response).to redirect_to(candidate_interface_application_choices_path)
      end
    end
  end
end
