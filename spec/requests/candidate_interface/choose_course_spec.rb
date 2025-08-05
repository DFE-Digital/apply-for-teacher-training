require 'rails_helper'

RSpec.describe 'continuous applications redirects' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }

  before do
    sign_in candidate
  end

  context 'when cycle is over' do
    it 'redirects the user when trying to add a course from find' do
      TestSuiteTimeMachine.travel_permanently_to(after_apply_deadline + 1.day)
      provider = create(:provider, code: '8N5', name: 'Snape University')
      course = create(:course, name: 'Potions', provider:)

      get candidate_interface_course_choices_course_confirm_selection_path(course.id)

      expect(response).to redirect_to(candidate_interface_application_choices_path)
    end
  end
end
