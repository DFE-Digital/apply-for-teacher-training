require 'rails_helper'

RSpec.describe 'Edit courses on continuous applications' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }
  let(:application_form) { create(:application_form, candidate:) }
  let(:current_course) { application_choice.current_course }
  let(:paths) do
    [
      candidate_interface_edit_course_choices_which_course_are_you_applying_to_path(application_choice.id),
      candidate_interface_edit_course_choices_course_site_path(application_choice.id, current_course.id, current_course.study_mode),
      candidate_interface_edit_course_choices_course_study_mode_path(application_choice.id, current_course.id),
    ]
  end

  before do
    sign_in candidate
  end

  context 'when application is unsubmitted', time: mid_cycle do
    let(:application_choice) { create(:application_choice, :unsubmitted, application_form:) }

    it 'renders successfully' do
      paths.each do |path|
        get path
        expect(response).to be_ok
      end
    end
  end

  context 'when application is submitted', time: mid_cycle do
    let(:application_choice) do
      create(:application_choice, :awaiting_provider_decision, application_form:)
    end

    it 'redirects to "your applications" tab' do
      paths.each do |path|
        get path
        expect(response).to redirect_to(candidate_interface_application_choices_path)
      end
    end
  end
end
