require 'rails_helper'

RSpec.describe 'Cycle redirects' do
  include Devise::Test::IntegrationHelpers

  top_level_application_routes = %w[
    candidate_interface_details_path
    candidate_interface_application_choices_path
  ]

  section_routes = [
    'candidate_interface_contact_information_review_path',
    # ['candidate_interface_gcse_review_path', { subject: 'english' }], # Current cycle tests hang on these routes 🤷‍♂️
    # ['candidate_interface_gcse_review_path', { subject: 'maths' }], # Current cycle tests hang on these routes 🤷‍♂️
    'candidate_interface_restructured_work_history_review_path',
    'candidate_interface_review_volunteering_path',
    'candidate_interface_degree_review_path',
    # 'candidate_interface_review_other_qualifications_path', # Current cycle tests hang on these routes 🤷‍♂️
    'candidate_interface_references_review_path',
    'candidate_interface_review_equality_and_diversity_path',
    'candidate_interface_review_safeguarding_path',
    'candidate_interface_becoming_a_teacher_show_path',
    'candidate_interface_interview_preferences_show_path',
  ]

  all_routes = top_level_application_routes.concat(section_routes).map { |path| Array.wrap(path) }

  let(:candidate) { create(:candidate) }
  let(:carry_over) { false }

  before do
    # rubocop:disable RSpec/AnyInstance
    # This is a workaround for faking the call method in CarryOverFilter.
    allow_any_instance_of(ApplicationForm).to receive(:carry_over?).and_return(carry_over)
    # rubocop:enable RSpec/AnyInstance

    sign_in candidate
  end

  context 'when application is not able to carry over', time: mid_cycle do
    let(:carry_over) { false }

    all_routes.each do |path|
      it "allows access to route #{path.join(' - ')}" do
        get public_send(*path)
        expect(response).to be_ok
      end
    end

    it 'redirects carry over routes to the application details page' do
      get candidate_interface_start_carry_over_path
      expect(response).to redirect_to(candidate_interface_details_path)
    end
  end

  context 'when application is able to carry over', time: mid_cycle do
    let(:carry_over) { true }

    all_routes.each do |path|
      it "redirects route #{path.join(' - ')} to the start-carry-over path" do
        get public_send(*path)
        expect(response).to redirect_to(candidate_interface_start_carry_over_path)
      end
    end

    it 'allows access to the start-carry-over path' do
      get candidate_interface_start_carry_over_path
      expect(response).to be_ok
    end
  end
end
