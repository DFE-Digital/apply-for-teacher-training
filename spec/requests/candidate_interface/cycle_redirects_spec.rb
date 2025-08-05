require 'rails_helper'

RSpec.describe 'Cycle redirects' do
  include Devise::Test::IntegrationHelpers

  let(:candidate) { create(:candidate) }
  let(:continuous_applications_routes) do
    [
      candidate_interface_details_path,
      candidate_interface_application_choices_path,
    ]
  end

  before { sign_in candidate }

  context 'when continuous applications', time: mid_cycle do
    before { create(:application_form, candidate:) }

    context 'when accessing continuous applications routes' do
      it 'be successful' do
        continuous_applications_routes.each do |path|
          get path
          expect(response).to be_ok
        end
      end
    end

    context 'when accessing the carry over route', time: mid_cycle do
      it 'redirects to the application details' do
        get candidate_interface_start_carry_over_path
        expect(response).to redirect_to(candidate_interface_details_path)
      end
    end
  end

  context 'when not continuous applications', time: mid_cycle do
    context 'when submitted' do
      before { create(:application_form, :completed, :pre_continuous_applications, candidate:) }

      it 'redirects to the application complete page' do
        continuous_applications_routes.each do |path|
          get path
          expect(response).to redirect_to(candidate_interface_start_carry_over_path)
        end
      end
    end

    context 'when trying to access sections under your details', time: mid_cycle do
      before { create(:application_form, :completed, :pre_continuous_applications, candidate:) }

      let(:section_routes) do
        [
          candidate_interface_contact_information_review_path,
          candidate_interface_gcse_review_path(subject: 'english'),
          candidate_interface_gcse_review_path(subject: 'maths'),
          candidate_interface_restructured_work_history_review_path,
          candidate_interface_review_volunteering_path,
          candidate_interface_degree_review_path,
          candidate_interface_review_other_qualifications_path,
          candidate_interface_references_review_path,
          candidate_interface_review_equality_and_diversity_path,
          candidate_interface_review_safeguarding_path,
          candidate_interface_becoming_a_teacher_show_path,
          candidate_interface_interview_preferences_show_path,
        ]
      end

      it 'redirects to the complete page' do
        section_routes.each do |path|
          get path
          expect(response.redirect_url).to include(candidate_interface_start_carry_over_path)
        end
      end
    end

    context 'when unsubmitted', time: mid_cycle do
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
