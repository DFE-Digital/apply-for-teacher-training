require 'rails_helper'

RSpec.describe 'Selecting a course' do
  include CandidateHelper

  scenario 'Candidate visits the course selection wizard via a URL', :with_cache do
    given_i_am_signed_in_with_one_login
    and_there_are_course_options
    when_i_visit_the_course_selection_step_via_a_url
    then_i_am_redirected_to_the_start_of_the_wizard

    when_i_visit_the_course_study_mode_step_via_a_url
    then_i_am_redirected_to_the_start_of_the_wizard

    when_i_visit_the_course_site_step_via_a_url
    then_i_am_redirected_to_the_start_of_the_wizard
  end

private

  def and_there_are_course_options
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    @course_one = create(:course, :open, name: 'Primary', code: '2XT2', provider: @provider)
    @course_two = create(:course, :open, name: 'Secondary', code: '2XP2', provider: @provider)
    create(:course_option, course: @course_one)
    create(:course_option, course: @course_two)
  end

  def when_i_visit_the_course_selection_step_via_a_url
    visit candidate_interface_course_choices_which_course_are_you_applying_to_path(@provider)
  end

  def then_i_am_redirected_to_the_start_of_the_wizard
    expect(page).to have_current_path(candidate_interface_course_choices_do_you_know_the_course_path)
    expect(page).to have_element(:h1, text: 'Do you know which course you want to apply to?')
  end

  def when_i_visit_the_course_study_mode_step_via_a_url
    visit candidate_interface_course_choices_course_study_mode_path(@provider, @course_one)
  end

  def when_i_visit_the_course_site_step_via_a_url
    visit candidate_interface_course_choices_course_site_path(@provider, @course_one, @course_one.study_mode)
  end
end
