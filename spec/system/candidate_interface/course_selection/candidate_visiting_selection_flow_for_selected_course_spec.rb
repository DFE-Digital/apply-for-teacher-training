require 'rails_helper'

RSpec.describe 'Selecting a course' do
  include CandidateHelper

  it 'Candidate is redirected when visiting later steps on a duplicate course selection' do
    given_i_am_signed_in_with_one_login

    and_there_is_one_course_option_with_both_study_modes_and_two_sites
    and_i_have_an_unsubmitted_application_to_the_course

    when_i_visit_the_site
    and_i_visit_the_study_mode_selection_for_my_existing_course_selection
    then_i_am_redirected_to_the_duplicate_course_selection_step

    when_i_visit_the_sites_selection_for_my_existing_course_selection
    then_i_am_redirected_to_the_duplicate_course_selection_step

    when_i_click_the_back_link
    then_i_am_on_my_applications_page

    when_i_come_from_find_and_arrive_on_confirm_selection_page
    then_i_am_redirected_to_the_duplicate_course_selection_step
  end

  def and_there_is_one_course_option_with_both_study_modes_and_two_sites
    provider = create(:provider, name: 'Gorse SCITT', code: '1N1')

    site = create(:site, provider:)
    @course_one = create(:course, :open, :with_both_study_modes, name: 'Primary', code: '2XT2', provider:)
    create(:course_option, site:, course: @course_one, study_mode: :full_time)
    create(:course_option, site:, course: @course_one, study_mode: :part_time)
  end

  def and_i_have_an_unsubmitted_application_to_the_course
    @application_one = create(:application_choice, :unsubmitted, course_option: @course_one.course_options.first, application_form: @current_candidate.current_application)
  end

  def when_i_visit_the_site
    visit candidate_interface_details_path
  end

  def and_i_visit_the_study_mode_selection_for_my_existing_course_selection
    visit candidate_interface_course_choices_course_study_mode_path(provider_id: @course_one.provider_id, course_id: @course_one.id)
  end

  def when_i_visit_the_sites_selection_for_my_existing_course_selection
    visit candidate_interface_course_choices_course_site_path(provider_id: @course_one.provider_id, course_id: @course_one.id, study_mode: :full_time)
  end

  def then_i_am_redirected_to_the_duplicate_course_selection_step
    expect(page).to have_current_path(candidate_interface_course_choices_duplicate_course_selection_path(@course_one.provider.id, @course_one.id))
  end

  def when_i_click_the_back_link
    click_link_or_button 'Back'
  end

  def then_i_am_on_my_applications_page
    expect(page).to have_current_path(candidate_interface_application_choices_path)
  end

  def when_i_come_from_find_and_arrive_on_confirm_selection_page
    visit candidate_interface_course_choices_course_confirm_selection_path(course_id: @course_one.id)
  end
end
