require 'rails_helper'

RSpec.describe 'Entering a degree', :js do
  include CandidateHelper
  include CandidateEnteringDegreesHelper

  scenario 'Candidate enters a degree with university as free text' do
    given_i_am_signed_in_with_one_login
    when_i_view_the_degree_section

    and_i_answer_that_i_have_a_university_degree

    # Add country
    then_i_can_see_the_country_page
    when_i_choose_united_kingdom
    and_i_click_on_save_and_continue

    # Add degree level
    then_i_can_see_the_level_page
    when_i_choose_the_level
    and_i_click_on_save_and_continue

    # Add degree type
    then_i_can_see_the_type_page
    when_i_choose_the_type_of_degree
    and_i_click_on_save_and_continue

    # Add subject
    then_i_can_see_the_subject_page
    when_i_fill_in_the_subject
    and_i_click_on_save_and_continue

    # Add university
    then_i_can_see_the_university_page
    when_i_fill_in_the_university_with_free_text
    and_i_click_on_save_and_continue

    # Add completion
    then_i_can_see_the_completion_page
    when_i_choose_whether_degree_is_completed
    and_i_click_on_save_and_continue

    # Add grade
    then_i_can_see_the_grade_page
    when_i_select_the_grade
    and_i_click_on_save_and_continue

    # Add start year
    then_i_can_see_the_start_year_page
    when_i_fill_in_the_start_year
    and_i_click_on_save_and_continue

    # Add award year
    then_i_can_see_the_award_year_page
    when_i_fill_in_the_award_year
    and_i_click_on_save_and_continue

    # Review
    then_i_can_check_my_undergraduate_degree
    and_the_completed_section_radios_are_not_selected

    # Mark section as complete
    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_see_the_form
    and_that_the_section_is_completed
    when_i_click_on_degree
    then_i_can_check_my_answers_with_free_text_university
  end
end
